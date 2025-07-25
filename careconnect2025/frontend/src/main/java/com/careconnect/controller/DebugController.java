package com.careconnect.controller;

import com.careconnect.model.Plan;
import com.careconnect.repository.PlanRepository;
import com.careconnect.service.SubscriptionEnrichmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/v1/api/debug")
@RequiredArgsConstructor
public class DebugController {

    private final PlanRepository planRepository;
    private final SubscriptionEnrichmentService subscriptionEnrichmentService;
    
    @Value("${subscription.premium-price-ids:price_1RmqWxELoozGI1YxQql5rsvN}")
    private String premiumPriceIds;
    
    @Value("${subscription.standard-price-ids:price_standard}")
    private String standardPriceIds;

    @GetMapping("/plans")
    public ResponseEntity<?> getAllPlans() {
        List<Plan> plans = planRepository.findAll();
        return ResponseEntity.ok(Map.of(
            "plans", plans,
            "count", plans.size()
        ));
    }
    
    @GetMapping("/plans/match")
    public ResponseEntity<?> matchPlanToPrice() {
        // This is the price ID from your subscription
        String priceId = "price_1RmqWxELoozGI1YxQql5rsvN";
        
        // Try to find by exact code match
        Plan exactPlan = planRepository.findByCode(priceId);
        
        // Try to find by amount (3000 cents = Premium Plan)
        List<Plan> premiumPlans = planRepository.findByName("Premium Plan");
        Plan premiumPlan = premiumPlans.isEmpty() ? null : premiumPlans.get(0);
        
        // Also check Standard Plan
        List<Plan> standardPlans = planRepository.findByName("Standard Plan");
        Plan standardPlan = standardPlans.isEmpty() ? null : standardPlans.get(0);
        
        // Try to manually create a mapping
        Plan manualMapping = new Plan();
        manualMapping.setCode(priceId);
        manualMapping.setName("Premium Plan");
        manualMapping.setPriceCents(3000);
        manualMapping.setBillingPeriod("MONTH");
        manualMapping.setIsActive(true);
        
        // Check if the price ID is in the configured mappings
        boolean isPremiumPriceId = Arrays.asList(premiumPriceIds.split(",")).contains(priceId);
        boolean isStandardPriceId = Arrays.asList(standardPriceIds.split(",")).contains(priceId);
        
        return ResponseEntity.ok(Map.of(
            "priceId", priceId,
            "exactMatch", exactPlan != null ? exactPlan : "No match found",
            "premiumPlan", premiumPlan != null ? premiumPlan : "No Premium Plan found",
            "standardPlan", standardPlan != null ? standardPlan : "No Standard Plan found",
            "suggestedMapping", manualMapping,
            "isPremiumPriceId", isPremiumPriceId,
            "isStandardPriceId", isStandardPriceId,
            "configuredPremiumPriceIds", premiumPriceIds,
            "configuredStandardPriceIds", standardPriceIds
        ));
    }
    
    @GetMapping("/plans/create-mapping")
    public ResponseEntity<?> createPriceMapping() {
        String priceId = "price_1RmqWxELoozGI1YxQql5rsvN";
        
        // Check if mapping already exists
        Plan existingPlan = planRepository.findByCode(priceId);
        if (existingPlan != null) {
            return ResponseEntity.ok(Map.of(
                "message", "Mapping already exists",
                "plan", existingPlan
            ));
        }
        
        // Find or create Premium Plan
        List<Plan> premiumPlans = planRepository.findByName("Premium Plan");
        Plan premiumPlan;
        
        if (!premiumPlans.isEmpty()) {
            premiumPlan = premiumPlans.get(0);
            // Create a new plan with the same details but different code
            Plan newPlan = new Plan();
            newPlan.setCode(priceId);
            newPlan.setName(premiumPlan.getName());
            newPlan.setPriceCents(premiumPlan.getPriceCents());
            newPlan.setBillingPeriod(premiumPlan.getBillingPeriod());
            newPlan.setIsActive(true);
            
            Plan savedPlan = planRepository.save(newPlan);
            
            return ResponseEntity.ok(Map.of(
                "message", "Created new plan mapping based on existing Premium Plan",
                "originalPlan", premiumPlan,
                "newPlan", savedPlan
            ));
        } else {
            // Create new Premium Plan
            Plan newPlan = new Plan();
            newPlan.setCode(priceId);
            newPlan.setName("Premium Plan");
            newPlan.setPriceCents(3000);
            newPlan.setBillingPeriod("MONTH");
            newPlan.setIsActive(true);
            
            Plan savedPlan = planRepository.save(newPlan);
            
            return ResponseEntity.ok(Map.of(
                "message", "Created new Premium Plan",
                "plan", savedPlan
            ));
        }
    }
    
    @GetMapping("/config")
    public ResponseEntity<?> getConfiguration() {
        return ResponseEntity.ok(Map.of(
            "premiumPriceIds", premiumPriceIds,
            "standardPriceIds", standardPriceIds,
            "premiumPriceIdsList", Arrays.asList(premiumPriceIds.split(",")),
            "standardPriceIdsList", Arrays.asList(standardPriceIds.split(","))
        ));
    }
    
    /**
     * Debug endpoint to check subscription data for a user
     */
    @GetMapping("/subscriptions/user/{userId}")
    public ResponseEntity<?> getEnrichedUserSubscriptions(@PathVariable Long userId) {
        try {
            return ResponseEntity.ok(subscriptionEnrichmentService.getEnrichedUserSubscriptions(userId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "Failed to get subscriptions: " + e.getMessage()
            ));
        }
    }
    
    /**
     * Create missing plan mappings for a user's subscriptions.
     * This endpoint is separate from the normal subscription retrieval to avoid
     * read-only transaction errors.
     */
    @PostMapping("/subscriptions/user/{userId}/create-mappings")
    public ResponseEntity<?> createMissingSubscriptionPlanMappings(@PathVariable Long userId) {
        try {
            // This runs in a writable transaction
            subscriptionEnrichmentService.createMissingPlanMappings(userId);
            return ResponseEntity.ok(Map.of(
                "message", "Successfully created missing plan mappings for user " + userId
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "Failed to create plan mappings: " + e.getMessage()
            ));
        }
    }
}
