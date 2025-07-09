package com.careconnect.repository;

import com.careconnect.model.WearableMetric;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.Instant;
import java.util.List;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface WearableMetricRepository
        extends JpaRepository<WearableMetric, Long> {

    /** Average of a metric over a time-window */
    @Query("""
           SELECT AVG(w.metricValue)                       
           FROM   WearableMetric w
           WHERE  w.patient.id = :pid                 
             AND  w.metric        = :metric
             AND  w.recordedAt    BETWEEN :from AND :to
           """)
    Double avgForPeriod(@Param("pid")    Long                    patientId,
                        @Param("metric") WearableMetric.MetricType metric,
                        @Param("from")   Instant                 from,
                        @Param("to")     Instant                 to);
	
List<WearableMetric> findByPatient_IdAndRecordedAtBetween(Long patientId, Instant from, Instant to);
}
