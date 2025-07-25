package com.careconnect.service;

import com.careconnect.dto.SubscriptionResponseDTO;
import com.careconnect.model.Plan;
import com.careconnect.model.Subscription;
import com.careconnect.model.User;
import com.careconnect.repository.PlanRepository;
import com.careconnect.repository.SubscriptionRepository;
import com.careconnect.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class SubscriptionEnrichmentService {

    private final SubscriptionRepository subscriptionRepository;
    private final UserRepository userRepository;
    private final PlanRepository planRepository;
    
    @Autowired
    private StripeService stripeService;
    
    // Configurable sets of price IDs for different plan types
    private final Set<String> premiumPlanPriceIds;
    private final Set<String> standardPlanPriceIds;

    public SubscriptionEnrichmentService(
            SubscriptionRepository subscriptionRepository,
            UserRepository userRepository,
            PlanRepository planRepository,
            @Value("${subscription.premium-price-ids:price_1RmqWxELoozGI1YxQql5rsvN}") String premiumPriceIdsValue,
            @Value("${subscription.standard-price-ids:price_standard}") String standardPriceIdsValue) {
        this.subscriptionRepository = subscriptionRepository;
        this.userRepository = userRepository;
        this.planRepository = planRepository;
        
        // Initialize the price ID sets from the configured values
        this.premiumPlanPriceIds = new HashSet<>(Arrays.asList(premiumPriceIdsValue.split(",")));
        this.standardPlanPriceIds = new HashSet<>(Arrays.asList(standardPriceIdsValue.split(",")));
        
        System.out.println("Configured premium plan price IDs: " + this.premiumPlanPriceIds);
        System.out.println("Configured standard plan price IDs: " + this.standardPlanPriceIds);
    }

    /**
     * Retrieves all active subscriptions directly from Stripe using the customer ID
     * 
     * @param customerId Stripe customer ID
     * @return List of active subscription IDs
     */
    private Set<String> getStripeActiveSubscriptionIds(String customerId) {
        Set<String> activeSubscriptionIds = new HashSet<>();
        
        if (customerId == null || customerId.isEmpty()) {
            System.out.println("No Stripe customer ID available");
            return activeSubscriptionIds;
        }
        
        try {
            // Get active subscriptions for this customer from Stripe
            String stripeResponse = stripeService.getCustomerActiveSubscriptions(customerId);
            if (stripeResponse == null || stripeResponse.isEmpty()) {
                System.out.println("No response from Stripe for customer: " + customerId);
                return activeSubscriptionIds;
            }
            
            // Parse the response to get subscription IDs
            ObjectMapper mapper = new ObjectMapper();
            JsonNode responseJson = mapper.readTree(stripeResponse);
            
            if (responseJson.has("data") && responseJson.get("data").isArray()) {
                JsonNode subscriptions = responseJson.get("data");
                for (JsonNode sub : subscriptions) {
                    if (sub.has("id")) {
                        String subId = sub.get("id").asText();
                        activeSubscriptionIds.add(subId);
                        System.out.println("Found active Stripe subscription: " + subId);
                    }
                }
            }
            
            System.out.println("Found " + activeSubscriptionIds.size() + " active subscriptions in Stripe for customer: " + customerId);
        } catch (Exception e) {
            System.out.println("Error getting active subscriptions from Stripe: " + e.getMessage());
        }
        
        return activeSubscriptionIds;
    }
    
    @Transactional(readOnly = false)
    public List<SubscriptionResponseDTO> getEnrichedUserSubscriptions(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));
                
        // Get active subscriptions directly from Stripe using customer ID
        Set<String> activeStripeSubscriptions = new HashSet<>();
        if (user.getStripeCustomerId() != null && !user.getStripeCustomerId().isEmpty()) {
            activeStripeSubscriptions = getStripeActiveSubscriptionIds(user.getStripeCustomerId());
            System.out.println("Found " + activeStripeSubscriptions.size() + " active subscriptions in Stripe for user " + userId);
        }
        
        // Get existing subscriptions for this user
        List<Subscription> subscriptions = subscriptionRepository.findByUser(user);
        System.out.println("Found " + subscriptions.size() + " subscriptions in database for user " + userId);
        
        // Since we only support one subscription per user, if we have an active subscription in Stripe
        // and a non-active subscription in the database, update the database subscription
        if (!activeStripeSubscriptions.isEmpty() && subscriptions.size() > 0) {
            String activeStripeSubscriptionId = activeStripeSubscriptions.iterator().next(); // Get first active subscription
            System.out.println("Found active Stripe subscription: " + activeStripeSubscriptionId);
            
            // Check if the current subscription in DB is non-active or if the Stripe ID doesn't match
            Subscription existingSubscription = subscriptions.get(0);
            if (!existingSubscription.getStatus().equalsIgnoreCase("ACTIVE") || 
                !activeStripeSubscriptionId.equals(existingSubscription.getStripeSubscriptionId())) {
                String updateReason = !existingSubscription.getStatus().equalsIgnoreCase("ACTIVE") ? 
                    "subscription in DB is not active" : 
                    "active Stripe subscription ID differs from DB record";
                System.out.println("Updating DB record: " + updateReason);
                
                try {
                    // Get details of the active subscription from Stripe
                    String stripeSubData = stripeService.getSubscription(activeStripeSubscriptionId);
                    ObjectMapper mapper = new ObjectMapper();
                    JsonNode stripeSubJson = mapper.readTree(stripeSubData);
                    
                    // Update the existing subscription with the active one's details
                    existingSubscription.setStripeSubscriptionId(activeStripeSubscriptionId);
                    existingSubscription.setStatus("ACTIVE");
                    
                    // Get price ID if available
                    if (stripeSubJson.has("items") && stripeSubJson.get("items").has("data") && 
                        stripeSubJson.get("items").get("data").size() > 0) {
                        JsonNode item = stripeSubJson.get("items").get("data").get(0);
                        if (item.has("price") && item.get("price").has("id")) {
                            String priceId = item.get("price").get("id").asText();
                            existingSubscription.setPriceId(priceId);
                        }
                    }
                    
                    // Get dates
                    if (stripeSubJson.has("current_period_start")) {
                        existingSubscription.setStartedAt(java.time.Instant.ofEpochSecond(
                            stripeSubJson.get("current_period_start").asLong()));
                    }
                    if (stripeSubJson.has("current_period_end")) {
                        existingSubscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(
                            stripeSubJson.get("current_period_end").asLong()));
                    }
                    
                    // Find plan
                    List<Plan> premiumPlans = planRepository.findByName("Premium Plan");
                    if (!premiumPlans.isEmpty()) {
                        existingSubscription.setPlan(premiumPlans.get(0));
                    }
                    
                    // Save the updated subscription
                    subscriptionRepository.save(existingSubscription);
                    System.out.println("Successfully updated subscription record with active subscription from Stripe");
                } catch (Exception e) {
                    System.err.println("Failed to update subscription: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        } else if (!activeStripeSubscriptions.isEmpty() && subscriptions.isEmpty()) {
            // If there's an active subscription in Stripe but none in the database, create a new one
            String activeStripeSubscriptionId = activeStripeSubscriptions.iterator().next();
            System.out.println("No subscription in database but found active subscription in Stripe. Creating new record.");
            
            try {
                // Get details of the active subscription from Stripe
                String stripeSubData = stripeService.getSubscription(activeStripeSubscriptionId);
                ObjectMapper mapper = new ObjectMapper();
                JsonNode stripeSubJson = mapper.readTree(stripeSubData);
                
                // Create a new subscription
                Subscription newSubscription = new Subscription();
                newSubscription.setUser(user);
                newSubscription.setStripeSubscriptionId(activeStripeSubscriptionId);
                newSubscription.setStripeCustomerId(user.getStripeCustomerId());
                newSubscription.setStatus("ACTIVE");
                
                // Get price ID if available
                if (stripeSubJson.has("items") && stripeSubJson.get("items").has("data") && 
                    stripeSubJson.get("items").get("data").size() > 0) {
                    JsonNode item = stripeSubJson.get("items").get("data").get(0);
                    if (item.has("price") && item.get("price").has("id")) {
                        String priceId = item.get("price").get("id").asText();
                        newSubscription.setPriceId(priceId);
                    }
                }
                
                // Get dates
                if (stripeSubJson.has("current_period_start")) {
                    newSubscription.setStartedAt(java.time.Instant.ofEpochSecond(
                        stripeSubJson.get("current_period_start").asLong()));
                }
                if (stripeSubJson.has("current_period_end")) {
                    newSubscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(
                        stripeSubJson.get("current_period_end").asLong()));
                }
                
                // Find plan
                List<Plan> premiumPlans = planRepository.findByName("Premium Plan");
                if (!premiumPlans.isEmpty()) {
                    newSubscription.setPlan(premiumPlans.get(0));
                }
                
                // Save the new subscription
                subscriptionRepository.save(newSubscription);
                
                // Refresh subscriptions list after creating the new one
                subscriptions = subscriptionRepository.findByUser(user);
                System.out.println("Successfully created new subscription record from active Stripe subscription");
            } catch (Exception e) {
                System.err.println("Failed to create subscription: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        // Debug information
        System.out.println("Processing " + subscriptions.size() + " subscriptions for user " + userId);
        for (Subscription sub : subscriptions) {
            System.out.println("Subscription ID: " + sub.getId() + ", PriceId: " + sub.getPriceId() + ", StripeId: " + sub.getStripeSubscriptionId());
            
            // Check if this subscription is active in Stripe based on customer's active subscriptions
            if (sub.getStripeSubscriptionId() != null && !sub.getStripeSubscriptionId().isEmpty()) {
                if (activeStripeSubscriptions.contains(sub.getStripeSubscriptionId())) {
                    // If Stripe says it's active, set it to ACTIVE regardless of local status
                    System.out.println("  Subscription is ACTIVE according to Stripe's active subscriptions list");
                    if (!"ACTIVE".equals(sub.getStatus())) {
                        System.out.println("  Updating status from " + sub.getStatus() + " to ACTIVE");
                        sub.setStatus("ACTIVE");
                        subscriptionRepository.save(sub);
                    }
                } else {
                    // If it's not in Stripe's active list, do an individual check for the exact status
                    try {
                        String stripeSubData = stripeService.getSubscription(sub.getStripeSubscriptionId());
                        // Parse the JSON response from Stripe
                        ObjectMapper mapper = new ObjectMapper();
                        JsonNode stripeSubJson = mapper.readTree(stripeSubData);
                        
                        // Get the status from Stripe
                        String stripeStatus = stripeSubJson.has("status") ? stripeSubJson.get("status").asText() : null;
                        System.out.println("  Stripe subscription status: " + stripeStatus);
                        
                        // Update the subscription status if it doesn't match
                        if (stripeStatus != null && !stripeStatus.equalsIgnoreCase(sub.getStatus())) {
                            System.out.println("  Status mismatch! Stripe: " + stripeStatus + ", Local: " + sub.getStatus());
                            System.out.println("  Updating database with Stripe status: " + stripeStatus);
                            // Update the database with the current Stripe status
                            sub.setStatus(stripeStatus.toUpperCase());
                            try {
                                subscriptionRepository.save(sub);
                                System.out.println("  Successfully updated subscription status in database");
                            } catch (Exception e) {
                                System.out.println("  Failed to update subscription status: " + e.getMessage());
                                e.printStackTrace();
                            }
                        }
                    } catch (Exception e) {
                        System.out.println("  Error checking Stripe status: " + e.getMessage());
                        // Continue with local status if Stripe check fails
                    }
                }
            }
            
            // Check if there's a plan with this priceId
            Plan plan = planRepository.findByCode(sub.getPriceId());
            if (plan != null) {
                System.out.println("  Found matching plan: " + plan.getId() + " - " + plan.getName());
            } else {
                System.out.println("  No matching plan found for priceId: " + sub.getPriceId());
                // Let's try a more flexible search
                List<Plan> plans = planRepository.findAll();
                System.out.println("  Available plans: " + plans.size());
                for (Plan p : plans) {
                    System.out.println("    - Plan: " + p.getId() + ", Code: " + p.getCode() + ", Name: " + p.getName());
                }
                
                // Note that we can't create mappings here because we're in a read-only transaction
                System.out.println("  Creating mapping for this price ID if needed");
                
                // Try to create a mapping for this price ID
                if (premiumPlanPriceIds.contains(sub.getPriceId())) {
                    List<Plan> premiumPlans = planRepository.findByName("Premium Plan");
                    if (!premiumPlans.isEmpty()) {
                        Plan mappedPlan = createOrUpdatePlanMapping(sub.getPriceId(), premiumPlans.get(0));
                        if (mappedPlan != null) {
                            System.out.println("  Successfully created plan mapping to Premium Plan");
                        }
                    }
                } else if (standardPlanPriceIds.contains(sub.getPriceId())) {
                    List<Plan> standardPlans = planRepository.findByName("Standard Plan");
                    if (!standardPlans.isEmpty()) {
                        Plan mappedPlan = createOrUpdatePlanMapping(sub.getPriceId(), standardPlans.get(0));
                        if (mappedPlan != null) {
                            System.out.println("  Successfully created plan mapping to Standard Plan");
                        }
                    }
                } else {
                    // Default to premium plan for unknown price IDs
                    List<Plan> premiumPlans = planRepository.findByName("Premium Plan");
                    if (!premiumPlans.isEmpty()) {
                        Plan mappedPlan = createOrUpdatePlanMapping(sub.getPriceId(), premiumPlans.get(0));
                        if (mappedPlan != null) {
                            System.out.println("  Successfully created plan mapping to Premium Plan (default)");
                        }
                    }
                }
            }
        }
        
        return enrichSubscriptions(subscriptions);
    }
    
    /**
     * Create plan mappings for all missing subscriptions. This should be called from
     * a separate writable transaction context.
     */
    @Transactional
    public void createMissingPlanMappings(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));
                
        List<Subscription> subscriptions = subscriptionRepository.findByUser(user);
        List<Plan> allPlans = planRepository.findAll();
        
        // Find premium and standard plans by name
        Plan premiumPlan = findPlanByName(allPlans, "Premium Plan");
        Plan standardPlan = findPlanByName(allPlans, "Standard Plan");
        
        for (Subscription subscription : subscriptions) {
            if (subscription.getPlan() == null && subscription.getPriceId() != null) {
                // Check if we already have a plan mapping
                Plan existingMapping = planRepository.findByCode(subscription.getPriceId());
                
                if (existingMapping == null) {
                    System.out.println("Creating mapping for subscription: " + subscription.getId() + 
                                     " with priceId: " + subscription.getPriceId());
                                     
                    // Determine which plan type this price ID corresponds to
                    if (premiumPlanPriceIds.contains(subscription.getPriceId()) && premiumPlan != null) {
                        createOrUpdatePlanMapping(subscription.getPriceId(), premiumPlan);
                    } else if (standardPlanPriceIds.contains(subscription.getPriceId()) && standardPlan != null) {
                        createOrUpdatePlanMapping(subscription.getPriceId(), standardPlan);
                    } else if (premiumPlan != null) {
                        // Default to premium plan
                        createOrUpdatePlanMapping(subscription.getPriceId(), premiumPlan);
                    } else if (standardPlan != null) {
                        // Fallback to standard plan
                        createOrUpdatePlanMapping(subscription.getPriceId(), standardPlan);
                    }
                }
            }
        }
    }
    
    @Transactional
    public List<SubscriptionResponseDTO> getEnrichedActiveUserSubscriptions(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));
                
        // First get active subscriptions directly from Stripe
        Set<String> activeStripeSubscriptions = new HashSet<>();
        if (user.getStripeCustomerId() != null && !user.getStripeCustomerId().isEmpty()) {
            activeStripeSubscriptions = getStripeActiveSubscriptionIds(user.getStripeCustomerId());
        }
        
        // Get all subscriptions for the user
        List<Subscription> allSubscriptions = subscriptionRepository.findByUser(user);
        
        // Create a final copy of the activeStripeSubscriptions for use in the lambda
        final Set<String> finalActiveStripeSubscriptions = new HashSet<>(activeStripeSubscriptions);
        
        // Filter subscriptions based on status: keep locally active ones plus ones active in Stripe
        List<Subscription> activeSubscriptions = allSubscriptions.stream()
            .filter(sub -> 
                // Keep if locally marked as active
                "ACTIVE".equalsIgnoreCase(sub.getStatus()) ||
                // Or if active in Stripe
                (sub.getStripeSubscriptionId() != null && 
                 !sub.getStripeSubscriptionId().isEmpty() && 
                 finalActiveStripeSubscriptions.contains(sub.getStripeSubscriptionId()))
            )
            .collect(Collectors.toList());
        
        System.out.println("Found " + activeSubscriptions.size() + " active subscriptions out of " + 
                           allSubscriptions.size() + " total for user " + userId);
        
        // Mark subscriptions as active if they're in the Stripe active list
        for (Subscription sub : activeSubscriptions) {
            if (sub.getStripeSubscriptionId() != null && 
                finalActiveStripeSubscriptions.contains(sub.getStripeSubscriptionId()) &&
                !"ACTIVE".equalsIgnoreCase(sub.getStatus())) {
                System.out.println("Updating subscription " + sub.getId() + " status to ACTIVE based on Stripe");
                sub.setStatus("ACTIVE");
                subscriptionRepository.save(sub);
            }
        }
        
        return enrichSubscriptions(activeSubscriptions);
    }

    @Transactional(readOnly = false)
    public List<SubscriptionResponseDTO> enrichSubscriptions(List<Subscription> subscriptions) {
        // First, get all plans to avoid multiple database calls
        List<Plan> allPlans = planRepository.findAll();
        System.out.println("Found " + allPlans.size() + " plans in total");
        
        // Map plans by code for quick lookup
        Map<String, Plan> plansByCode = new HashMap<>();
        for (Plan plan : allPlans) {
            plansByCode.put(plan.getCode(), plan);
            System.out.println("Plan " + plan.getId() + ": " + plan.getName() + " (Code: " + plan.getCode() + ")");
        }
        
        // Find premium and standard plans by name
        final Plan premiumPlan = findPlanByName(allPlans, "Premium Plan");
        final Plan standardPlan = findPlanByName(allPlans, "Standard Plan");
        
        return subscriptions.stream()
                .map(subscription -> {
                    // Check with Stripe for subscription status before creating the DTO
                    checkAndUpdateSubscriptionStatus(subscription);
                    
                    SubscriptionResponseDTO dto = new SubscriptionResponseDTO(subscription);
                    System.out.println("Processing subscription: " + subscription.getId() + " with priceId: " + subscription.getPriceId());
                    
                    // If the subscription is linked to a plan in the database, use that
                    if (subscription.getPlan() != null) {
                        System.out.println("  Subscription already has a plan: " + subscription.getPlan().getName());
                        // Plan data is already set by the constructor
                        return dto;
                    }
                    
                    // Otherwise, try to find the plan by the Stripe price ID
                    if (subscription.getPriceId() != null) {
                        // Look up plan by code using our pre-loaded map
                        Plan plan = plansByCode.get(subscription.getPriceId());
                        
                        if (plan != null) {
                            System.out.println("  Found plan by code: " + plan.getName());
                            dto.setPlanId(plan.getId());
                            dto.setPlanName(plan.getName());
                            dto.setPlanCode(plan.getCode());
                            dto.setPriceCents(plan.getPriceCents());
                        } else {
                            // Check against configured premium price ID
                            if (premiumPlanPriceIds.contains(subscription.getPriceId())) {
                                System.out.println("  Matched premium price ID: " + subscription.getPriceId());
                                
                                // If we have a Premium Plan in the database, use its details
                                if (premiumPlan != null) {
                                    // Use the premium plan info for this subscription (without creating a new record)
                                    System.out.println("  Using existing Premium Plan");
                                    dto.setPlanId(premiumPlan.getId());
                                    dto.setPlanName(premiumPlan.getName());
                                    dto.setPlanCode(premiumPlan.getCode());
                                    dto.setPriceCents(premiumPlan.getPriceCents());
                                } else {
                                    // If there's no Premium Plan, just set the name without creating a record
                                    System.out.println("  No Premium Plan in database, using default values");
                                    dto.setPlanName("Premium Plan");
                                    dto.setPriceCents(3000);  // $30.00
                                }
                            } else if (standardPlanPriceIds.contains(subscription.getPriceId())) {
                                System.out.println("  Matched standard price ID: " + subscription.getPriceId());
                                
                                // If we have a Standard Plan in the database, use its details
                                if (standardPlan != null) {
                                    // Use the standard plan info for this subscription (without creating a new record)
                                    System.out.println("  Using existing Standard Plan");
                                    dto.setPlanId(standardPlan.getId());
                                    dto.setPlanName(standardPlan.getName());
                                    dto.setPlanCode(standardPlan.getCode());
                                    dto.setPriceCents(standardPlan.getPriceCents());
                                } else {
                                    // If there's no Standard Plan, just set the name without creating a record
                                    System.out.println("  No Standard Plan in database, using default values");
                                    dto.setPlanName("Standard Plan");
                                    dto.setPriceCents(2000);  // $20.00
                                }
                            } else if (premiumPlan != null) {
                                // Default to Premium Plan for unknown price IDs
                                System.out.println("  Unknown priceId " + subscription.getPriceId() + ", defaulting to Premium Plan");
                                dto.setPlanId(premiumPlan.getId());
                                dto.setPlanName(premiumPlan.getName());
                                dto.setPlanCode(premiumPlan.getCode());
                                dto.setPriceCents(premiumPlan.getPriceCents());
                            }
                        }
                    }
                    
                    return dto;
                })
                .collect(Collectors.toList());
    }
    
    /**
     * Helper method to find a plan by name from a list of plans
     */
    private Plan findPlanByName(List<Plan> plans, String name) {
        for (Plan plan : plans) {
            if (name.equals(plan.getName())) {
                return plan;
            }
        }
        return null;
    }
    
    /**
     * Check if there are any active subscriptions in Stripe that aren't in our database
     * and add them
     * 
     * @param user The user to check subscriptions for
     * @param activeStripeSubscriptionIds Set of active subscription IDs from Stripe
     */
    private void addMissingSubscriptionsFromStripe(User user, Set<String> activeStripeSubscriptionIds) {
        if (activeStripeSubscriptionIds.isEmpty()) {
            return;
        }
        
        try {
            // First get all subscription IDs we already have in the database for this user
            List<Subscription> existingSubscriptions = subscriptionRepository.findByUser(user);
            Set<String> existingStripeIds = existingSubscriptions.stream()
                    .filter(s -> s.getStripeSubscriptionId() != null)
                    .map(Subscription::getStripeSubscriptionId)
                    .collect(Collectors.toSet());
            
            // Find which active subscriptions from Stripe aren't in our database
            Set<String> missingSubscriptionIds = new HashSet<>(activeStripeSubscriptionIds);
            missingSubscriptionIds.removeAll(existingStripeIds);
            
            if (missingSubscriptionIds.isEmpty()) {
                return; // Nothing to do
            }
            
            System.out.println("Found " + missingSubscriptionIds.size() + " active subscriptions in Stripe not in database");
            
            // For each missing subscription, fetch details from Stripe and create a record
            for (String stripeSubscriptionId : missingSubscriptionIds) {
                try {
                    System.out.println("Creating record for Stripe subscription: " + stripeSubscriptionId);
                    
                    // Get subscription details from Stripe
                    String stripeSubData = stripeService.getSubscription(stripeSubscriptionId);
                    if (stripeSubData == null || stripeSubData.isEmpty()) {
                        System.out.println("  No data returned from Stripe for subscription: " + stripeSubscriptionId);
                        continue;
                    }
                    
                    ObjectMapper mapper = new ObjectMapper();
                    JsonNode stripeSubJson = mapper.readTree(stripeSubData);
                    
                    // Extract necessary details
                    String stripeStatus = stripeSubJson.has("status") ? stripeSubJson.get("status").asText() : "active";
                    String stripeCustomerId = stripeSubJson.has("customer") ? stripeSubJson.get("customer").asText() : user.getStripeCustomerId();
                    long startDate = stripeSubJson.has("current_period_start") ? stripeSubJson.get("current_period_start").asLong() : System.currentTimeMillis() / 1000;
                    long endDate = stripeSubJson.has("current_period_end") ? stripeSubJson.get("current_period_end").asLong() : startDate + (30 * 24 * 60 * 60);
                    
                    // Get the price ID
                    String priceId = null;
                    if (stripeSubJson.has("items") && stripeSubJson.get("items").has("data") && 
                        stripeSubJson.get("items").get("data").isArray() && 
                        stripeSubJson.get("items").get("data").size() > 0) {
                        JsonNode firstItem = stripeSubJson.get("items").get("data").get(0);
                        if (firstItem.has("price") && firstItem.get("price").has("id")) {
                            priceId = firstItem.get("price").get("id").asText();
                        }
                    }
                    
                    // Create the subscription record
                    Subscription newSubscription = new Subscription();
                    newSubscription.setUser(user);
                    newSubscription.setStripeSubscriptionId(stripeSubscriptionId);
                    newSubscription.setStripeCustomerId(stripeCustomerId);
                    newSubscription.setPriceId(priceId);
                    newSubscription.setStatus(stripeStatus.toUpperCase());
                    newSubscription.setStartedAt(java.time.Instant.ofEpochSecond(startDate));
                    newSubscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(endDate));
                    
                    // Try to find matching plan by priceId
                    if (priceId != null) {
                        Plan plan = planRepository.findByCode(priceId);
                        if (plan != null) {
                            newSubscription.setPlan(plan);
                        } else if (premiumPlanPriceIds.contains(priceId)) {
                            // Look for premium plan by name
                            List<Plan> premiumPlans = planRepository.findByName("Premium Plan");
                            if (!premiumPlans.isEmpty()) {
                                newSubscription.setPlan(premiumPlans.get(0));
                            }
                        } else if (standardPlanPriceIds.contains(priceId)) {
                            // Look for standard plan by name
                            List<Plan> standardPlans = planRepository.findByName("Standard Plan");
                            if (!standardPlans.isEmpty()) {
                                newSubscription.setPlan(standardPlans.get(0));
                            }
                        }
                    }
                    
                    // Save the subscription
                    subscriptionRepository.save(newSubscription);
                    System.out.println("  Created new subscription record with ID: " + newSubscription.getId());
                    
                } catch (Exception e) {
                    System.err.println("Error creating subscription record for " + stripeSubscriptionId + ": " + e.getMessage());
                }
            }
        } catch (Exception e) {
            System.err.println("Error checking for missing subscriptions: " + e.getMessage());
        }
    }
    
    /**
     * Creates or updates a mapping between a Stripe price ID and a plan
     * @param priceId The Stripe price ID
     * @param basePlan The plan to base the mapping on
     * @return The created or updated plan
     */
    private Plan createOrUpdatePlanMapping(String priceId, Plan basePlan) {
        // Check if a mapping already exists
        Plan existingMapping = planRepository.findByCode(priceId);
        if (existingMapping != null) {
            System.out.println("  Mapping already exists for " + priceId + ": " + existingMapping.getName());
            return existingMapping;
        }
        
        // Create a new plan with the same details but with the price ID as code
        Plan newMapping = new Plan();
        newMapping.setCode(priceId);
        newMapping.setName(basePlan.getName());
        newMapping.setPriceCents(basePlan.getPriceCents());
        newMapping.setBillingPeriod(basePlan.getBillingPeriod());
        newMapping.setIsActive(true);
        
        Plan savedMapping = planRepository.save(newMapping);
        System.out.println("  Created new plan mapping: " + savedMapping.getId() + " for price " + priceId);
        return savedMapping;
    }
    
    /**
     * Check the subscription status with Stripe and update the status in the subscription object
     * Note: This doesn't persist changes to the database (used in read-only transactions)
     * 
     * @param subscription The subscription to check
     */
    private void checkAndUpdateSubscriptionStatus(Subscription subscription) {
        // If we don't have a Stripe subscription ID, we can't do a direct check
        if (subscription.getStripeSubscriptionId() == null || subscription.getStripeSubscriptionId().isEmpty()) {
            System.out.println("  No Stripe subscription ID for subscription: " + subscription.getId());
            return;
        }
        
        try {
            // Get subscription data from Stripe
            String stripeSubData = stripeService.getSubscription(subscription.getStripeSubscriptionId());
            if (stripeSubData == null || stripeSubData.isEmpty()) {
                System.out.println("  No data returned from Stripe for subscription: " + subscription.getStripeSubscriptionId());
                return;
            }
            
            // Parse the JSON response
            ObjectMapper mapper = new ObjectMapper();
            JsonNode stripeSubJson = mapper.readTree(stripeSubData);
            
            // Get the status from Stripe
            if (stripeSubJson.has("status")) {
                String stripeStatus = stripeSubJson.get("status").asText();
                System.out.println("  Stripe status for " + subscription.getStripeSubscriptionId() + ": " + stripeStatus);
                
                // In Stripe, 'active' means the subscription is in good standing
                // Other statuses include: 'trialing', 'past_due', 'canceled', 'unpaid', 'incomplete', 'incomplete_expired'
                if ("active".equalsIgnoreCase(stripeStatus) || "trialing".equalsIgnoreCase(stripeStatus)) {
                    // Always set status to ACTIVE if Stripe says it's active, regardless of local status
                    subscription.setStatus("ACTIVE");
                } else if (!stripeStatus.equalsIgnoreCase(subscription.getStatus())) {
                    // If status is different, update to match Stripe
                    System.out.println("  Updating status from " + subscription.getStatus() + " to " + stripeStatus.toUpperCase());
                    subscription.setStatus(stripeStatus.toUpperCase());
                }
            } else {
                System.out.println("  No status field found in Stripe response for: " + subscription.getStripeSubscriptionId());
            }
        } catch (Exception e) {
            System.out.println("  Error checking subscription status with Stripe: " + e.getMessage());
            // We'll continue with the existing status if we couldn't check with Stripe
        }
    }
    
    /**
     * Check if a price ID should be considered as a specific plan type
     * @param priceId The Stripe price ID to check
     * @param planName The name of the plan to check for (e.g., "Premium Plan")
     * @return true if the price ID maps to the given plan type
     */
    private boolean isPlanPriceId(String priceId, String planName) {
        if (priceId == null) return false;
        
        if ("Premium Plan".equals(planName)) {
            return premiumPlanPriceIds.contains(priceId);
        } else if ("Standard Plan".equals(planName)) {
            return standardPlanPriceIds.contains(priceId);
        }
        
        return false;
    }
}
