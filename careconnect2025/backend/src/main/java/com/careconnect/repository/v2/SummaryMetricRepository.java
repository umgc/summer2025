package com.careconnect.repository.v2;

import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.Repository;
import org.springframework.context.annotation.Profile;
import com.careconnect.model.v2.SummaryMetric;


import java.time.Instant;
import java.util.List;

@Profile("v2")
@Repository
public interface SummaryMetricRepository extends JpaRepository<SummaryMetric, Long> {
    SummaryMetric findTopByPatient_UserIdAndPeriodStartAndPeriodEndOrderByCreatedAtDesc(
        Long patientId, Instant periodStart, Instant periodEnd
    );
}
