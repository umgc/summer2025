package com.careconnect.security.service;

import com.careconnect.dto.*;
import com.careconnect.model.SummaryMetric;
import com.careconnect.model.WearableMetric;
import com.careconnect.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.lowagie.text.*;
import com.careconnect.exception.AppException;
import com.lowagie.text.pdf.*;
import java.util.Comparator;
import java.io.ByteArrayOutputStream;
import java.util.List;
import java.util.Map;
import java.time.Instant;
import java.util.stream.Collectors;
import java.time.*;


@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AnalyticsService {

    private final SymptomEntryRepository symptomRepo;     // ← NEW
    private final WearableMetricRepository wearableRepo;
    private final SummaryMetricRepository summaryRepo;
    private final ExportSigner exportSigner;

    /* ---------------- Dashboard ---------------- */

    public DashboardDTO getDashboard(Long patientId, Period period) {
     Instant to   = Instant.now();
        Instant from = to.minus(period);

        SummaryMetric agg = summaryRepo
        .findTopByPatient_UserIdAndPeriodStartAndPeriodEndOrderByCreatedAtDesc(
            patientId, from, to
        );

        double adherence;
        double avgHr;

        if (agg != null &&
            agg.getGeneratedAt().isAfter(Instant.now().minus(Period.ofDays(1)))) {

            adherence = agg.getAdherenceRate();
            avgHr     = agg.getAvgHeartRate();

        } else {
            long completed = symptomRepo.countCompleted(patientId, from, to);
            long total     = symptomRepo.countTotal(patientId, from, to);
            adherence      = total == 0 ? 0 : (completed * 100.0) / total;

            Double hr = wearableRepo.avgForPeriod(
                    patientId, WearableMetric.MetricType.HEART_RATE, from, to);
            avgHr = hr == null ? 0 : hr;
        }

        /* Additional vitals */
        double avgSpo2   = avgOrZero(patientId, WearableMetric.MetricType.SPO2,             from, to);
        double avgSys    = avgOrZero(patientId, WearableMetric.MetricType.BLOOD_PRESSURE_SYS, from, to);
        double avgDia    = avgOrZero(patientId, WearableMetric.MetricType.BLOOD_PRESSURE_DIA, from, to);
        double avgWeight = avgOrZero(patientId, WearableMetric.MetricType.WEIGHT,            from, to);

        return DashboardDTO.builder()
                .periodStart(from)
                .periodEnd(to)
                .adherenceRate(round1(adherence))
                .avgHeartRate(round0(avgHr))
                .avgSpo2(round1(avgSpo2))
                .avgSystolic(round0(avgSys))
                .avgDiastolic(round0(avgDia))
                .avgWeight(round1(avgWeight))
                .build();
    }

    /* ---------------- Vitals series ---------------- */

  public List<VitalSampleDTO> getVitals(Long patientId, Period period) {
    // Instant to   = Instant.now();
    Instant to = Instant.parse("2025-06-27T08:00:00Z");
    Instant from = to.minus(period);

    return wearableRepo.findByPatient_IdAndRecordedAtBetween(patientId, from, to)
            .stream()
            .collect(Collectors.groupingBy(WearableMetric::getRecordedAt))
            .entrySet().stream()
            .map(e -> toDTO(patientId, e.getKey(), e.getValue()))
            .sorted(Comparator.comparing(VitalSampleDTO::timestamp))
            .toList();
    }

    /* ---------------- Exports ---------------- */

    public ExportLinkDTO createSignedExportLink(String path) {
        return exportSigner.sign(path);
    }

    /* ---------------- Helpers ---------------- */

    private VitalSampleDTO toDTO(Long pid, Instant ts, List<WearableMetric> list) {
        Map<WearableMetric.MetricType, Double> map = list.stream()
                .collect(Collectors.toMap(WearableMetric::getMetric,
                                          WearableMetric::getMetricValue,
                                          (a, b) -> b)); // last wins

return VitalSampleDTO.builder()
        .patientId(pid)
        .timestamp(ts)
        .heartRate(map.get(WearableMetric.MetricType.HEART_RATE))
        .spo2(map.get(WearableMetric.MetricType.SPO2))
        .systolic(doubleToInt(map.get(WearableMetric.MetricType.BLOOD_PRESSURE_SYS)))
        .diastolic(doubleToInt(map.get(WearableMetric.MetricType.BLOOD_PRESSURE_DIA)))
        .weight(map.get(WearableMetric.MetricType.WEIGHT))
        .build();
    }

    private double avgOrZero(Long pid, WearableMetric.MetricType type,
                             Instant from, Instant to) {

        Double v = wearableRepo.avgForPeriod(pid, type, from, to);
        return v == null ? 0 : v;
    }

    private double round1(double v) { return Math.round(v * 10) / 10.0; }
    private double round0(double v) { return Math.round(v); }

    private Integer doubleToInt(Double d) { return d == null ? null : d.intValue(); }


    public byte[] exportVitalsCsv(Long patientId, Period period) {
    List<VitalSampleDTO> vitals = getVitals(patientId, period);

    StringBuilder sb = new StringBuilder();
    sb.append("timestamp,heartRate,spo2,systolic,diastolic,weight\n");
    for (VitalSampleDTO v : vitals) {
        sb.append(v.timestamp()).append(",")
          .append(v.heartRate()).append(",")
          .append(v.spo2()).append(",")
          .append(v.systolic()).append(",")
          .append(v.diastolic()).append(",")
          .append(v.weight()).append("\n");
    }
    return sb.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8);
}

public byte[] exportVitalsPdf(Long patientId, Period period) {
    List<VitalSampleDTO> vitals = getVitals(patientId, period);

    try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
        Document document = new Document();
        PdfWriter.getInstance(document, baos);
        document.open();

        document.add(new Paragraph("Vitals Report"));
        document.add(new Paragraph("Patient ID: " + patientId));
        document.add(new Paragraph("Period: Last " + period.getDays() + " days"));
        document.add(new Paragraph(" "));

        PdfPTable table = new PdfPTable(6);
        table.addCell("Timestamp");
        table.addCell("Heart Rate");
        table.addCell("SpO2");
        table.addCell("Systolic");
        table.addCell("Diastolic");
        table.addCell("Weight");

        for (VitalSampleDTO v : vitals) {
            table.addCell(String.valueOf(v.timestamp()));
            table.addCell(String.valueOf(v.heartRate()));
            table.addCell(String.valueOf(v.spo2()));
            table.addCell(String.valueOf(v.systolic()));
            table.addCell(String.valueOf(v.diastolic()));
            table.addCell(String.valueOf(v.weight()));
        }

        document.add(table);
        document.close();
        return baos.toByteArray();
    } catch (Exception e) {
        throw new RuntimeException("Failed to generate PDF", e);
    }
}

}