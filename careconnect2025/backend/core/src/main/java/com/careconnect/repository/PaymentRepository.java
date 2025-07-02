package com.careconnect.repository;

import com.careconnect.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    Payment findByStripeSessionId(String sessionId);
}