package com.careconnect.service;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import com.careconnect.repository.PaymentRepository;
import com.careconnect.repository.UserRepository;
import com.careconnect.repository.CaregiverRepository;
import com.careconnect.repository.PlanRepository;
import com.careconnect.repository.SubscriptionRepository;
import com.careconnect.model.User;
import com.careconnect.model.Caregiver;
import com.careconnect.model.Payment;
import com.careconnect.model.Plan;
import com.careconnect.model.Subscription;
//import com.stripe.model.SubscriptionCreateParams;
//import com.stripe.model.Subscription as StripeSubscription;
import lombok.RequiredArgsConstructor;
import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class StripeCheckoutService {
    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final CaregiverRepository caregiverRepository;
    private final PlanRepository planRepository;
    private final SubscriptionRepository subscriptionRepository;

    public Session createCheckoutSession(String customerId, String plan, long amount, String successUrl, String cancelUrl) throws StripeException {
        // Check if the plan string is a Stripe price ID (starts with "price_")
        // If it is, use it directly. Otherwise, create a price on the fly.
        SessionCreateParams.Builder paramsBuilder = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.SUBSCRIPTION)
                .setSuccessUrl(successUrl + "?session_id={CHECKOUT_SESSION_ID}")
                .setCancelUrl(cancelUrl)
                .setCustomer(customerId);
                
        // Use different approach based on whether we have a price ID or need to create one
        if (plan.startsWith("price_")) {
            // Use existing price ID
            paramsBuilder.addLineItem(
                SessionCreateParams.LineItem.builder()
                    .setQuantity(1L)
                    .setPrice(plan) // Use the price ID directly
                    .build()
            );
        } else {
            // Create price data on the fly
            paramsBuilder.addLineItem(
                SessionCreateParams.LineItem.builder()
                    .setQuantity(1L)
                    .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                        .setCurrency("usd")
                        .setRecurring(SessionCreateParams.LineItem.PriceData.Recurring.builder().setInterval(SessionCreateParams.LineItem.PriceData.Recurring.Interval.MONTH).build())
                        .setUnitAmount(amount)
                        .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder().setName(plan).build())
                        .build())
                    .build()
            );
        }
        
        SessionCreateParams params = paramsBuilder.build();

        return Session.create(params);
    }

        public void saveCheckoutSession(Long userId, String plan, long amount, Session session) {
        User user = userRepository.findById(userId).orElseThrow();
        
        // Create payment record
        Payment payment = new Payment();
        payment.setUser(user);
        payment.setAmountCents((int) amount);
        payment.setStatus("PENDING");
        payment.setStripeSessionId(session.getId());
        payment.setStripePaymentIntentId(session.getPaymentIntent());
        paymentRepository.save(payment);
        
        // Create subscription record if this is a subscription mode checkout
        if (session.getMode().equals("subscription") && session.getSubscription() != null) {
            // Check if we have a subscription repository autowired
            if (subscriptionRepository != null) {
                Subscription subscription = new Subscription();
                subscription.setStripeSubscriptionId(session.getSubscription());
                subscription.setStripeCustomerId(user.getStripeCustomerId());
                subscription.setUser(user);
                subscription.setStatus("PENDING"); // Will be updated to ACTIVE by webhook
                subscription.setStartedAt(java.time.Instant.now());
                
                // Try to find a matching plan
                try {
                    // First try to find by name
                    List<Plan> matchingPlans = planRepository.findByName(plan);
                    if (!matchingPlans.isEmpty()) {
                        subscription.setPlan(matchingPlans.get(0));
                    }
                } catch (Exception e) {
                    // Just log the error, don't stop execution
                    System.err.println("Could not find matching plan: " + e.getMessage());
                }
                
                subscriptionRepository.save(subscription);
            }
        }
    }
    
    public Session createCheckoutSessionForUser(Long userId, String plan, long amount, String successUrl, String cancelUrl) throws StripeException {
        User user = userRepository.findById(userId).orElseThrow(() -> 
            new IllegalArgumentException("User not found with ID: " + userId));
        
        if (user.getStripeCustomerId() == null || user.getStripeCustomerId().isEmpty()) {
            throw new IllegalStateException("User does not have a Stripe customer ID");
        }
        
        return createCheckoutSession(user.getStripeCustomerId(), plan, amount, successUrl, cancelUrl);
    }
    
    /**
     * Creates a checkout session specifically for a caregiver.
     * This ensures we're fetching the correct caregiver by ID and using their associated Stripe customer ID.
     */
    public Session createCheckoutSessionForCaregiver(Long caregiverId, String plan, long amount, String successUrl, String cancelUrl) throws StripeException {
        // Find the caregiver
        Caregiver caregiver = caregiverRepository.findById(caregiverId)
            .orElseThrow(() -> new IllegalArgumentException("Caregiver not found with ID: " + caregiverId));
        
        // Get the associated user
        User user = caregiver.getUser();
        
        // Verify the user has a Stripe customer ID
        if (user.getStripeCustomerId() == null || user.getStripeCustomerId().isEmpty()) {
            throw new IllegalStateException("Caregiver does not have a Stripe customer ID. They may need to complete registration first.");
        }
        
        // Create the checkout session with the caregiver's Stripe customer ID
        return createCheckoutSession(user.getStripeCustomerId(), plan, amount, successUrl, cancelUrl);
    }
    
    /**
     * Get the Stripe customer ID for a specific caregiver
     * This is useful for checking subscription status or other Stripe operations
     */
    public String getCaregiverStripeCustomerId(Long caregiverId) {
        Caregiver caregiver = caregiverRepository.findById(caregiverId)
            .orElseThrow(() -> new IllegalArgumentException("Caregiver not found with ID: " + caregiverId));
        
        User user = caregiver.getUser();
        
        if (user.getStripeCustomerId() == null || user.getStripeCustomerId().isEmpty()) {
            throw new IllegalStateException("Caregiver does not have a Stripe customer ID");
        }
        
        return user.getStripeCustomerId();
    }
    
    /**
     * Get all active subscription plans
     */
    public List<Plan> getAvailablePlans() {
        return planRepository.findByIsActiveTrue();
    }
    
    /**
     * Create a checkout session for a specific plan
     * This uses the plan code from the database as the Stripe price ID
     */
    public Session createCheckoutSessionForPlan(Long caregiverId, String planId, String successUrl, String cancelUrl) throws StripeException {
        Plan plan = planRepository.findById(Long.parseLong(planId))
            .orElseThrow(() -> new IllegalArgumentException("Plan not found with ID: " + planId));
            
        String customerId = getCaregiverStripeCustomerId(caregiverId);
        
        // Create checkout session based on whether the plan code is a valid Stripe price ID
        SessionCreateParams.Builder paramsBuilder = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.SUBSCRIPTION)
                .setSuccessUrl(successUrl + "?session_id={CHECKOUT_SESSION_ID}")
                .setCancelUrl(cancelUrl)
                .setCustomer(customerId);
        
        if (plan.getCode() != null && plan.getCode().startsWith("price_")) {
            // Use the plan.code as a Stripe price ID
            paramsBuilder.addLineItem(SessionCreateParams.LineItem.builder()
                .setQuantity(1L)
                .setPrice(plan.getCode())
                .build());
        } else {
            // Fall back to creating a price on the fly
            paramsBuilder.addLineItem(SessionCreateParams.LineItem.builder()
                .setQuantity(1L)
                .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                    .setCurrency("usd")
                    .setRecurring(SessionCreateParams.LineItem.PriceData.Recurring.builder()
                        .setInterval(SessionCreateParams.LineItem.PriceData.Recurring.Interval.MONTH)
                        .build())
                    .setUnitAmount(plan.getPriceCents().longValue())
                    .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder()
                        .setName(plan.getName())
                        .build())
                    .build())
                .build());
        }
        
        SessionCreateParams params = paramsBuilder.build();
        Session session = Session.create(params);
        
        // Get the caregiver and user to store subscription info
        Caregiver caregiver = caregiverRepository.findById(caregiverId)
            .orElseThrow(() -> new IllegalArgumentException("Caregiver not found with ID: " + caregiverId));
            
        User user = caregiver.getUser();
        
        // Pre-create subscription in our database to track this checkout
        if (session.getMode().equals("subscription") && user != null) {
            Subscription subscription = new Subscription();
            subscription.setStripeSubscriptionId(session.getSubscription());
            subscription.setStripeCustomerId(customerId);
            subscription.setUser(user);
            subscription.setPlan(plan);
            subscription.setStatus("PENDING");
            subscription.setStartedAt(java.time.Instant.now());
            subscriptionRepository.save(subscription);
        }
        
        return session;
    }
    
    /**
     * Create a plan in the database and optionally in Stripe
     * @param code The code to use (will be a Stripe price ID if createInStripe is true)
     * @param name The name of the plan
     * @param priceCents The price in cents
     * @param billingPeriod The billing period (monthly, yearly, etc.)
     * @param isActive Whether the plan is active
     * @param createInStripe Whether to create the price in Stripe
     * @return The created Plan entity
     */
    public Plan createPlan(String code, String name, Integer priceCents, String billingPeriod, Boolean isActive, boolean createInStripe) {
        String finalCode = code;
        
        // Create the price in Stripe if requested
        if (createInStripe) {
            try {
                // Set Stripe API key directly from the service
                Stripe.apiKey = System.getenv("STRIPE_SECRET_KEY");
                
                // First create a product
                Map<String, Object> productParams = new HashMap<>();
                productParams.put("name", name);
                productParams.put("description", name + " " + billingPeriod + " Subscription");
                
                com.stripe.model.Product product = com.stripe.model.Product.create(productParams);
                
                // Then create a price
                Map<String, Object> priceParams = new HashMap<>();
                priceParams.put("unit_amount", priceCents);
                priceParams.put("currency", "usd");
                
                Map<String, Object> recurringParams = new HashMap<>();
                recurringParams.put("interval", billingPeriod.toLowerCase());
                priceParams.put("recurring", recurringParams);
                
                priceParams.put("product", product.getId());
                
                com.stripe.model.Price price = com.stripe.model.Price.create(priceParams);
                
                // Use the actual price ID as our code
                finalCode = price.getId();
                System.out.println("Created Stripe price: " + finalCode);
            } catch (Exception e) {
                System.err.println("Failed to create Stripe price: " + e.getMessage());
                // Continue with the provided code if Stripe creation fails
            }
        }
        
        Plan plan = new Plan();
        plan.setCode(finalCode);
        plan.setName(name);
        plan.setPriceCents(priceCents);
        plan.setBillingPeriod(billingPeriod);
        plan.setIsActive(isActive != null ? isActive : true); // Default to true if not specified
        return planRepository.save(plan);
    }
    
    /**
     * Create a plan in the database.
     * This doesn't create the product/price in Stripe - that should be done separately in the admin panel
     * or through another service method that creates Stripe products and prices
     */
    public Plan createPlan(String code, String name, Integer priceCents, String billingPeriod, Boolean isActive) {
        return createPlan(code, name, priceCents, billingPeriod, isActive, false);
    }
}
