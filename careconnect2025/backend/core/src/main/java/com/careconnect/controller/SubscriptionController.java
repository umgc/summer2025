package com.careconnect.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.careconnect.dto.SubscriptionCancelRequestDTO;
import org.springframework.web.bind.annotation.RequestBody;
import com.careconnect.service.SubscriptionService;
import com.stripe.model.SubscriptionCollection;
import org.springframework.beans.factory.annotation.Value;
import java.util.Map;
import org.springframework.web.bind.annotation.RequestParam;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/v1/api/subscriptions")
public class SubscriptionController {

    private SubscriptionService subscriptionService;
    private String stripeWebhookSecret="sk_test_51RXvh6ELoozGI1YxqEoWg79VsZc2zKRrNC3dmlULVkc";


    public SubscriptionController(
        SubscriptionService subscriptionService
        // @Value("${stripe.webhook-secret}") String stripeWebhookSecret
    ) {
        this.subscriptionService = subscriptionService;
        // this.stripeWebhookSecret = stripeWebhookSecret; 
    }
	
    @GetMapping("/plans")
    public ResponseEntity<String> listPlans() { return ResponseEntity.ok("Available plans"); }
    
    @PostMapping("/")
    public ResponseEntity<String> createSubscription() { return ResponseEntity.ok("Subscription created"); }
    
    @PostMapping("/create")
    public ResponseEntity<?> createCheckoutSession(
            HttpServletRequest request,
            @RequestParam String plan,
            @RequestParam Long userId) {
        return subscriptionService.createCheckoutSession(request, plan, userId);
    }

    @PutMapping("/{id}/payment-method")
    public ResponseEntity<String> updatePayment(@PathVariable String id) { return ResponseEntity.ok("Payment updated: " + id); }
    

    @GetMapping("/stripe/{customerId}/subscriptions")
    public ResponseEntity<SubscriptionCollection> getStripeCustomerSubscriptions(@PathVariable String customerId) {
        SubscriptionCollection subs = subscriptionService.listCustomerSubscriptions(customerId);
        return ResponseEntity.ok(subs);
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<?> cancelSubscription(@RequestBody SubscriptionCancelRequestDTO dto) {
        subscriptionService.cancelSubscription(dto.getSubscriptionId());
        return ResponseEntity.ok().body("Subscription cancelled");
    }   
@PostMapping("/webhook/stripe")
public ResponseEntity<String> handleStripeWebhook(HttpServletRequest request) {
    try {
        String payload = request.getReader().lines().reduce("", (acc, line) -> acc + line);
        String sigHeader = request.getHeader("Stripe-Signature");
        String endpointSecret = stripeWebhookSecret; 

        String result = subscriptionService.handleStripeWebhook(payload, sigHeader, endpointSecret);
        return ResponseEntity.ok(result);
    } catch (Exception e) {
        return ResponseEntity.badRequest().body("Webhook error: " + e.getMessage());
    }
}
}