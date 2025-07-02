package com.careconnect.service.v2;


import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.careconnect.repository.v2.PaymentRepository;
import com.careconnect.model.v2.Payment;

import org.springframework.context.annotation.Profile;

@Profile("v2")
@Service
@RequiredArgsConstructor
public class PaymentService {
	@Autowired
    private PaymentRepository paymentRepository;

    public void savePayment(Payment payment) {
        paymentRepository.save(payment);
    }

    public Payment getByStripeSessionId(String sessionId) {
        return paymentRepository.findByStripeSessionId(sessionId);
    }
}