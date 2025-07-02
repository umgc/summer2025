package com.careconnect.repository.v2;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.context.annotation.Profile;
import com.careconnect.model.v2.Payment;
import org.springframework.stereotype.Repository;

@Profile("v2")
@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    Payment findByStripeSessionId(String sessionId);
}