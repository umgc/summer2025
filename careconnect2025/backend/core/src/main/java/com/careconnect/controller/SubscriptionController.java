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
import com.careconnect.dto.SubscriptionResponseDTO;
import com.careconnect.model.Plan;
import org.springframework.web.bind.annotation.RequestBody;
import com.careconnect.service.SubscriptionService;
import com.careconnect.service.SubscriptionEnrichmentService;
import com.stripe.model.SubscriptionCollection;
import org.springframework.beans.factory.annotation.Value;
import java.util.Map;
import java.util.List;
import com.careconnect.model.Subscription;
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
    private final SubscriptionEnrichmentService subscriptionEnrichmentService;
    @Value("${stripe.webhook-secret}")
    private String stripeWebhookSecret;
    

    public SubscriptionController(
        SubscriptionService subscriptionService,
        StripeService stripeService,
        SubscriptionEnrichmentService subscriptionEnrichmentService
        // @Value("${stripe.webhook-secret}") String stripeWebhookSecret
    ) {
        this.subscriptionService = subscriptionService;
        this.stripeService = stripeService;
        this.subscriptionEnrichmentService = subscriptionEnrichmentService;
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
    
    @PostMapping("/plans")
    public ResponseEntity<?> createPlan(
            @RequestParam String code,
            @RequestParam String name,
            @RequestParam Integer priceCents,
            @RequestParam String billingPeriod,
            @RequestParam(required = false) Boolean isActive) {
        
        Plan plan = subscriptionService.createPlan(code, name, priceCents, billingPeriod, isActive);
        return ResponseEntity.ok(plan);
    }
    
    @GetMapping("/plans/{planId}")
    public ResponseEntity<?> getPlan(@PathVariable String planId) {
        Plan plan = subscriptionService.getPlan(Long.parseLong(planId));
        return ResponseEntity.ok(plan);
    }
    
    @PostMapping("/plans/{planId}/sync-with-stripe")
    public ResponseEntity<?> syncPlanWithStripe(
            @PathVariable String planId,
            @RequestParam(defaultValue = "true") boolean createIfMissing) {
        try {
            Plan plan = subscriptionService.syncPlanWithStripe(Long.parseLong(planId), createIfMissing);
            return ResponseEntity.ok(plan);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/sync-from-stripe/{stripeSubscriptionId}")
    public ResponseEntity<?> syncSubscriptionFromStripe(@PathVariable String stripeSubscriptionId) {
        try {
            Subscription subscription = subscriptionService.syncSubscriptionFromStripe(stripeSubscriptionId);
            return ResponseEntity.ok(subscription);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/stripe/{customerId}/subscriptions")
    public ResponseEntity<String> getStripeCustomerSubscriptions(@PathVariable String customerId) {
        String subs = stripeService.listSubscriptions(customerId);
        return ResponseEntity.ok(subs);
    }
    
    @GetMapping("/sync-all-from-stripe/{customerId}")
    public ResponseEntity<?> syncAllCustomerSubscriptions(@PathVariable String customerId) {
        try {
            List<Subscription> subscriptions = subscriptionService.syncAllSubscriptionsForCustomer(customerId);
            return ResponseEntity.ok(subscriptions);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
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
            @RequestParam(required = false) Long amount,
            @RequestParam(required = false) String stripeCustomerId) {
        return subscriptionService.createCheckoutSession(request, plan, userId, amount, stripeCustomerId);
    }

    // @PutMapping("/{id}/payment-method")
    // public ResponseEntity<String> updatePayment(@PathVariable String id) { return ResponseEntity.ok("Payment updated: " + id); }
    @PostMapping("/{id}/cancel")
    public ResponseEntity<?> cancelSubscription(@PathVariable String id) {
        Map<String, Object> result = stripeService.cancelSubscription(id);
        return ResponseEntity.ok().body(result);
    }
    
    /**
     * Creates a subscription directly with a Stripe customer ID and price ID
     * 
     * @param customerId The Stripe customer ID (starts with "cus_")
     * @param priceId Either a Stripe price ID (starts with "price_") or a Stripe plan ID (starts with "plan_")
     * @return The created subscription
     */
    @PostMapping("/create-direct")
    public ResponseEntity<?> createSubscriptionDirect(
            @RequestParam(required = false) String customerId,
            @RequestParam(required = false) String priceId,
            @RequestBody(required = false) Map<String, String> requestBody) {
        
        try {
            // Get parameters from either request params or request body
            String finalCustomerId = customerId;
            String finalPriceId = priceId;
            
            // If they're not in request params, try to get from request body
            if ((finalCustomerId == null || finalPriceId == null) && requestBody != null) {
                finalCustomerId = requestBody.getOrDefault("customerId", customerId);
                finalPriceId = requestBody.getOrDefault("priceId", priceId);
            }
            
            // Validate that we have the required parameters
            if (finalCustomerId == null || finalCustomerId.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Customer ID is required"));
            }
            
            if (finalPriceId == null || finalPriceId.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Price ID is required"));
            }
            
            System.out.println("Creating subscription with customerId: " + finalCustomerId + " and priceId: " + finalPriceId);
            
            Map<String, Object> result = stripeService.createSubscription(finalCustomerId, finalPriceId);
            return ResponseEntity.ok().body(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    /**
     * Creates a subscription for a user by their user ID and a price ID
     * 
     * @param userId The CareConnect user ID
     * @param priceId Either a Stripe price ID (starts with "price_") or a Stripe plan ID (starts with "plan_")
     * @return The created subscription
     */
    @PostMapping("/create-direct-for-user")
    public ResponseEntity<?> createSubscriptionDirectForUser(
            @RequestParam Long userId,
            @RequestParam String priceId) {
        try {
            Subscription subscription = subscriptionService.createSubscriptionDirectly(userId, priceId);
            return ResponseEntity.ok().body(Map.of(
                "message", "Subscription created successfully",
                "subscription", subscription
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
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

@GetMapping("/user/{userId}")
public ResponseEntity<?> getUserSubscriptions(@PathVariable Long userId) {
    try {
        List<SubscriptionResponseDTO> subscriptionDTOs = subscriptionEnrichmentService.getEnrichedUserSubscriptions(userId);
        return ResponseEntity.ok(subscriptionDTOs);
    } catch (Exception e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
    }
}

@GetMapping("/user/{userId}/active")
public ResponseEntity<?> getUserActiveSubscriptions(@PathVariable Long userId) {
    try {
        List<SubscriptionResponseDTO> subscriptionDTOs = subscriptionEnrichmentService.getEnrichedActiveUserSubscriptions(userId);
        return ResponseEntity.ok(subscriptionDTOs);
    } catch (Exception e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
    }
}

@PostMapping("/user/{userId}/sync-from-stripe")
public ResponseEntity<?> syncUserSubscriptionsFromStripe(@PathVariable Long userId) {
    try {
        List<Subscription> subscriptions = subscriptionService.syncUserSubscriptionsFromStripe(userId);
        // Use enrichment service to add plan details
        List<SubscriptionResponseDTO> subscriptionDTOs = subscriptionEnrichmentService.enrichSubscriptions(subscriptions);
        return ResponseEntity.ok(Map.of(
            "message", "Successfully synced subscriptions from Stripe",
            "count", subscriptions.size(),
            "subscriptions", subscriptionDTOs
        ));
    } catch (Exception e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
    }
}

    @PostMapping("/upgrade-or-downgrade")
    public ResponseEntity<?> upgradeOrDowngradeSubscription(
            @RequestParam String oldSubscriptionId,
            @RequestParam String newPriceId) {
        try {
            Map<String, Object> result = stripeService.upgradeOrDowngradeSubscription(oldSubscriptionId, newPriceId);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}