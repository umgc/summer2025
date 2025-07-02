package com.careconnect.repository.v2;


import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.Repository;
import org.springframework.context.annotation.Profile;
import com.careconnect.model.v2.WearableMetric;

import org.springframework.data.repository.query.Param; 

import java.time.Instant;
import java.util.List;

@Profile("v2")
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