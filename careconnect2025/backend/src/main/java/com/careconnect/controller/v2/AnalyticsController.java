package com.careconnect.controller.v2;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import com.careconnect.dto.v2.DashboardDTO;
import com.careconnect.dto.v2.ExportLinkDTO;
import com.careconnect.dto.v2.VitalSampleDTO;
import com.careconnect.service.v2.AnalyticsService;
import org.springframework.context.annotation.Profile;

import java.time.Period;
import java.util.List;
import java.util.concurrent.*;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

	@Autowired
    private AnalyticsService analyticsService;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();

    @GetMapping("/dashboard")
    public DashboardDTO dashboard(
            @RequestParam Long patientId,
            @RequestParam(defaultValue = "7") int days) {
        if (days < 1) days = 1;
        return analyticsService.getDashboard(patientId, Period.ofDays(days));
    }

    // @GetMapping("/export/csv")
    // public ExportLinkDTO exportCsv(@RequestParam Long patientId,
    //                                @RequestParam String from,
    //                                @RequestParam String to) {
    //     String path = "/exports/csv/" + patientId + "/" + from + "_" + to + ".csv";
    //     return analyticsService.createSignedExportLink(path);
    // }

    @GetMapping("/export/vitals/csv")
    public ResponseEntity<byte[]> exportVitalsCsv(
        @RequestParam Long patientId,
        @RequestParam(defaultValue = "7") int days) {
    if (days < 1) days = 1;
    byte[] csv = analyticsService.exportVitalsCsv(patientId, Period.ofDays(days));
    return ResponseEntity.ok()
            .header("Content-Disposition", "attachment; filename=\"vitals.csv\"")
            .contentType(org.springframework.http.MediaType.parseMediaType("text/csv"))
            .body(csv);
    }

    // @GetMapping("/export/pdf")
    // public ExportLinkDTO exportPdf(@RequestParam Long patientId,
    //                                @RequestParam String from,
    //                                @RequestParam String to) {
    //     String path = "/exports/pdf/" + patientId + "/" + from + "_" + to + ".pdf";
    //     return analyticsService.createSignedExportLink(path);
    // }

    @GetMapping("/export/vitals/pdf")
    public ResponseEntity<byte[]> exportVitalsPdf(
        @RequestParam Long patientId,
        @RequestParam(defaultValue = "7") int days) {
    if (days < 1) days = 1;
    byte[] pdf = analyticsService.exportVitalsPdf(patientId, Period.ofDays(days));
    return ResponseEntity.ok()
            .header("Content-Disposition", "attachment; filename=\"vitals.pdf\"")
            .contentType(org.springframework.http.MediaType.APPLICATION_PDF)
            .body(pdf);
}

    @GetMapping(value = "/live", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter live(@RequestParam Long patientId) {
        SseEmitter emitter = new SseEmitter(30 * 60 * 1000L); // 30 min
        executor.submit(() -> {
            try {
                while (true) {
                    DashboardDTO dto = analyticsService.getDashboard(patientId, Period.ofDays(1));
                    emitter.send(dto);
                    Thread.sleep(2000);
                }
            } catch (Exception e) {
                emitter.completeWithError(e);
            }
        });
        return emitter;
    }

    @GetMapping("/vitals")
    public List<VitalSampleDTO> vitals(
            @RequestParam Long patientId,
            @RequestParam(defaultValue = "7") int days) {
        if (days < 1) days = 1;
        return analyticsService.getVitals(patientId, Period.ofDays(days));
    }
}