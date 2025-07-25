package com.careconnect.service;


import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.careconnect.repository.PaymentRepository;
import com.careconnect.model.Payment;

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