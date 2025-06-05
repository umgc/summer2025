package com.careconnectpt.careconnect2025.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.careconnectpt.careconnect2025.dto.payment.CardSubscriptionRequest;
import com.careconnectpt.careconnect2025.dto.payment.SubscriptionResponse;
import com.careconnectpt.careconnect2025.service.StripeService;
import com.stripe.exception.StripeException;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final StripeService stripeService = new StripeService();

    /**
     * Front‑end calls this after collecting a PaymentMethod via Stripe.js
     */
    @PostMapping("/subscribe")
    public ResponseEntity<SubscriptionResponse> subscribe(@Valid @RequestBody CardSubscriptionRequest req)
            throws StripeException {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(stripeService.createCardSubscription(req));
    }

    /**
     * Stripe webhook endpoint to handle events (invoice.payment_succeeded, etc.)
     */
    @PostMapping("/webhook")
    public ResponseEntity<Void> webhook(@RequestHeader("Stripe-Signature") String sig, @RequestBody String payload) {
        // TODO: verify signature and process events
        return ResponseEntity.ok().build();
    }
}
