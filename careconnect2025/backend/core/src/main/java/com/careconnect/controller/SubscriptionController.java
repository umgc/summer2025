package com.careconnect.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.careconnect.dto.SubscriptionCancelRequestDTO;
import com.careconnect.dto.PlanDTO;
import org.springframework.web.bind.annotation.RequestBody;
import com.careconnect.service.SubscriptionService;
import com.stripe.model.SubscriptionCollection;
import org.springframework.beans.factory.annotation.Value;
import java.util.Map;
import java.util.List;
import org.springframework.web.bind.annotation.RequestParam;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.careconnect.service.StripeService;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/v1/api/subscriptions")
public class SubscriptionController {

    private SubscriptionService subscriptionService;
    private final StripeService stripeService;
    @Value("${stripe.webhook-secret}")
    private String stripeWebhookSecret;
    

    public SubscriptionController(
        SubscriptionService subscriptionService,
        StripeService stripeService
        // @Value("${stripe.webhook-secret}") String stripeWebhookSecret
    ) {
        this.subscriptionService = subscriptionService;
        this.stripeService = stripeService;
        // this.stripeWebhookSecret = stripeWebhookSecret; 
    }
	
    @GetMapping("/products")
    public ResponseEntity<String> listProducts() {
        String products = stripeService.listProducts();
        return ResponseEntity.ok(products);
    }
 
    @GetMapping("/plans")
    public ResponseEntity<List<PlanDTO>> listPlans() {
    List<PlanDTO> plans = stripeService.listPlans();
    return ResponseEntity.ok(plans);
    }
    
    @GetMapping("/stripe/{customerId}/subscriptions")
    public ResponseEntity<String> getStripeCustomerSubscriptions(@PathVariable String customerId) {
        String subs = stripeService.listSubscriptions(customerId);
        return ResponseEntity.ok(subs);
    }

    @GetMapping("/stripe/subscription/{subscriptionId}")
    public ResponseEntity<String> getSubscription(@PathVariable String subscriptionId) {
        String sub = stripeService.getSubscription(subscriptionId);
        return ResponseEntity.ok(sub);
    }

    @GetMapping("/stripe/subscriptions/search")
    public ResponseEntity<String> searchSubscriptions(@RequestParam String query) {
        String result = stripeService.searchSubscriptions(query);
        return ResponseEntity.ok(result);
    }
    
    @PostMapping("/create")
    public ResponseEntity<?> createCheckoutSession(
            HttpServletRequest request,
            @RequestParam String plan,
            @RequestParam(required = false, defaultValue = "0") Long userId,
            @RequestParam(required = false) Long amount) { 
        return subscriptionService.createCheckoutSession(request, plan, userId, amount);
    }

    // @PutMapping("/{id}/payment-method")
    // public ResponseEntity<String> updatePayment(@PathVariable String id) { return ResponseEntity.ok("Payment updated: " + id); }
    

    @PostMapping("/{id}/cancel")
    public ResponseEntity<?> cancelSubscription(@PathVariable String id) {
        String result = stripeService.cancelSubscription(id);
        return ResponseEntity.ok().body(result);
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