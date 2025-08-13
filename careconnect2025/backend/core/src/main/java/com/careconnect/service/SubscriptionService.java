package com.careconnect.service;

import com.careconnect.model.Payment;
import com.careconnect.model.Plan;
import com.careconnect.model.Subscription;
import com.careconnect.model.User;
import com.careconnect.repository.PaymentRepository;
import com.careconnect.repository.PlanRepository;
import com.careconnect.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.careconnect.repository.SubscriptionRepository;
import com.stripe.model.checkout.Session;
import com.stripe.Stripe;
import java.util.Map;
import java.util.HashMap;
import java.util.List;

import java.util.Optional;
import java.util.ArrayList;
import com.stripe.model.Event;
import com.stripe.net.Webhook;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.exception.StripeException;
import com.google.gson.JsonSyntaxException;
import java.util.List;

import com.stripe.model.SubscriptionCollection;
import com.stripe.param.SubscriptionListParams;
import com.stripe.exception.StripeException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Value;

@Service
@RequiredArgsConstructor
public class SubscriptionService {
    private final SubscriptionRepository subscriptionRepository;
    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final PlanRepository planRepository;
    private final StripeCheckoutService stripeCheckoutService;

    @Value("${stripe.secret-key}")
    private String stripeSecretKey;

    @Value("${frontend.base-url}")
    private String frontendBaseUrl;
    
    /**
     * Create a plan in the database
     */
    public Plan createPlan(String code, String name, Integer priceCents, String billingPeriod, Boolean isActive) {
        return stripeCheckoutService.createPlan(code, name, priceCents, billingPeriod, isActive);
    }
    
    /**
     * Get a plan by ID
     */
    public Plan getPlan(Long planId) {
        return planRepository.findById(planId)
            .orElseThrow(() -> new IllegalArgumentException("Plan not found with ID: " + planId));
    }
    
    /**
     * Find or create a plan by its Stripe price ID
     */
    @Transactional
    public Plan findOrCreatePlanByStripeId(String stripePriceId, String nickname, Integer amount) {
        // First try to find the plan by code (Stripe price ID)
        Plan plan = planRepository.findByCode(stripePriceId);
        
        // If plan doesn't exist, create it
        if (plan == null) {
            plan = new Plan();
            plan.setCode(stripePriceId);
            plan.setName(nickname != null ? nickname : "Plan " + stripePriceId);
            plan.setPriceCents(amount);
            plan.setBillingPeriod("MONTH"); // Default to monthly
            plan.setIsActive(true);
            plan = planRepository.save(plan);
        }
        
        return plan;
    }
    
    /**
     * Sync a plan with Stripe - ensure the plan has a valid Stripe price ID
     * @param planId The ID of the plan to sync
     * @param createIfMissing Whether to create the price in Stripe if it doesn't exist
     * @return The updated plan
     */
    public Plan syncPlanWithStripe(Long planId, boolean createIfMissing) {
        Plan plan = getPlan(planId);
        
        // Check if the plan code is a valid Stripe price ID
        if (plan.getCode() == null || !plan.getCode().startsWith("price_")) {
            if (createIfMissing) {
                try {
                    // Set Stripe API key from environment
                    Stripe.apiKey = stripeSecretKey;
                    
                    // Create a product first
                    Map<String, Object> productParams = new HashMap<>();
                    productParams.put("name", plan.getName());
                    productParams.put("description", plan.getName() + " " + plan.getBillingPeriod() + " Subscription");
                    
                    com.stripe.model.Product product = com.stripe.model.Product.create(productParams);
                    
                    // Then create a price
                    Map<String, Object> priceParams = new HashMap<>();
                    priceParams.put("unit_amount", plan.getPriceCents());
                    priceParams.put("currency", "usd");
                    
                    Map<String, Object> recurringParams = new HashMap<>();
                    recurringParams.put("interval", plan.getBillingPeriod().toLowerCase());
                    priceParams.put("recurring", recurringParams);
                    
                    priceParams.put("product", product.getId());
                    
                    com.stripe.model.Price price = com.stripe.model.Price.create(priceParams);
                    
                    // Update plan with the price ID
                    plan.setCode(price.getId());
                    return planRepository.save(plan);
                } catch (Exception e) {
                    throw new RuntimeException("Failed to create price in Stripe: " + e.getMessage(), e);
                }
            } else {
                throw new IllegalArgumentException("Plan does not have a valid Stripe price ID");
            }
        }
        
        return plan;
    }

    public ResponseEntity<?> createCheckoutSession(
            HttpServletRequest request,
            String plan,
            Long userId,
            Long amount,
            String stripeCustomerId,
            String portal
    ) {
        try {
            String domain = request.getScheme() + "://" + request.getServerName() +
                    (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort());

            long finalAmount = (amount != null && amount > 0) ? amount :
                    switch (plan.toLowerCase()) {
                        case "premium" -> 3000L;
                        case "standard" -> 2000L;
                        default -> 2000L;
                    };

            String customerId = null;
            User user = null;
            if (userId != null && userId != 0) {
                user = userRepository.findById(userId)
                        .orElseThrow(() -> new IllegalArgumentException("User not found for id: " + userId));
                if (user.getStripeCustomerId() != null && !user.getStripeCustomerId().isEmpty()) {
                    customerId = user.getStripeCustomerId();
                } else if (stripeCustomerId != null && !stripeCustomerId.isEmpty()) {
                    customerId = stripeCustomerId;
                    user.setStripeCustomerId(stripeCustomerId);
                    userRepository.save(user);
                } else {
                    try {
                        Map<String, Object> customerParams = new HashMap<>();
                        customerParams.put("email", user.getEmail());
                        customerParams.put("name", user.getName());
                        Stripe.apiKey = stripeSecretKey;
                        com.stripe.model.Customer customer = com.stripe.model.Customer.create(customerParams);
                        customerId = customer.getId();
                        user.setStripeCustomerId(customerId);
                        userRepository.save(user);
                    } catch (Exception e) {
                        System.err.println("Failed to create Stripe customer: " + e.getMessage());
                    }
                }
            } else if (stripeCustomerId != null && !stripeCustomerId.isEmpty()) {
                customerId = stripeCustomerId;
            }

            com.stripe.param.checkout.SessionCreateParams.Builder paramsBuilder =
                    com.stripe.param.checkout.SessionCreateParams.builder()
                            .setMode(com.stripe.param.checkout.SessionCreateParams.Mode.SUBSCRIPTION);
                            
            // Set the success URL based on whether this is a portal update
            if (portal == "update") {
                paramsBuilder.setSuccessUrl(frontendBaseUrl + "/payment-success?portal=update");
            } else {
                paramsBuilder.setSuccessUrl(frontendBaseUrl + "/payment-success");
            }
            
            paramsBuilder.setCancelUrl(frontendBaseUrl + "/payment-cancel?registration=complete");

            if (customerId != null) {
                paramsBuilder.setCustomer(customerId);
            }
            if (userId != null) {
                paramsBuilder.setClientReferenceId(userId.toString());
            }
            paramsBuilder.addLineItem(
                    com.stripe.param.checkout.SessionCreateParams.LineItem.builder()
                            .setQuantity(1L)
                            .setPriceData(
                                    com.stripe.param.checkout.SessionCreateParams.LineItem.PriceData.builder()
                                            .setCurrency("usd")
                                            .setUnitAmount(finalAmount)
                                            .setRecurring(
                                                    com.stripe.param.checkout.SessionCreateParams.LineItem.PriceData.Recurring.builder()
                                                            .setInterval(com.stripe.param.checkout.SessionCreateParams.LineItem.PriceData.Recurring.Interval.MONTH)
                                                            .build()
                                            )
                                            .setProductData(
                                                    com.stripe.param.checkout.SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                            .setName(plan)
                                                            .build()
                                            )
                                            .build()
                            )
                            .build()
            );

            Session session = Session.create(paramsBuilder.build());

            // Only save payment info here, not subscription
//            if (userId != null && userId != 0) {
//                User paymentUser = user;
//                String stripeSessionId = session.getId();
//                Payment payment = Payment.builder()
//                        .user(paymentUser)
//                        .amountCents((int) finalAmount)
//                        .status("PENDING")
//                        .stripeSessionId(stripeSessionId)
//                        .stripePaymentIntentId(session.getPaymentIntent())
//                        .build();
//                paymentRepository.save(payment);
//            }

            return ResponseEntity.ok(Map.of("checkoutUrl", session.getUrl()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

//    public ResponseEntity<?> createCheckoutSession(
//    HttpServletRequest request,
//    String plan,
//    Long userId,
//    Long amount) {
//    try {
//        String domain = request.getScheme() + "://" + request.getServerName() +
//                (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort());
//
//        // Use the amount from the request if provided, otherwise use default pricing
//        long finalAmount;
//        if (amount != null && amount > 0) {
//            finalAmount = amount;
//        } else {
//            // Fallback to hardcoded pricing if amount not provided
//            finalAmount = switch (plan.toLowerCase()) {
//                case "premium" -> 3000L;
//                case "standard" -> 2000L;
//                default -> 2000L; // Default to standard pricing
//            };
//        }
//
//        // Check if the user exists and has a stripeCustomerId
//        String customerId = null;
//        User user = null;
//        if (userId != null && userId != 0) {
//            user = userRepository.findById(userId)
//                .orElseThrow(() -> new IllegalArgumentException("User not found for id: " + userId));
//
//            // Use existing Stripe customer ID if available
//            if (user.getStripeCustomerId() != null && !user.getStripeCustomerId().isEmpty()) {
//                customerId = user.getStripeCustomerId();
//                System.out.println("Using existing customer ID: " + customerId);
//            } else {
//                // Create a new Stripe customer if needed
//                try {
//                    Map<String, Object> customerParams = new HashMap<>();
//                    customerParams.put("email", user.getEmail());
//                    customerParams.put("name", user.getName());
//
//                    Stripe.apiKey = stripeSecretKey;
//                    com.stripe.model.Customer customer = com.stripe.model.Customer.create(customerParams);
//                    customerId = customer.getId();
//
//                    // Save the customer ID to the user
//                    user.setStripeCustomerId(customerId);
//                    userRepository.save(user);
//                    System.out.println("Created and saved new Stripe customer ID: " + customerId);
//                } catch (Exception e) {
//                    System.err.println("Failed to create Stripe customer: " + e.getMessage());
//                    // Continue without customer ID - Stripe will create one
//                }
//            }
//        }
//
//        // Build Stripe session params
//        com.stripe.param.checkout.SessionCreateParams.Builder paramsBuilder =
//            com.stripe.param.checkout.SessionCreateParams.builder()
//                .setMode(com.stripe.param.checkout.SessionCreateParams.Mode.SUBSCRIPTION)
//                .setSuccessUrl(frontendBaseUrl + "/login")
//                .setCancelUrl(frontendBaseUrl + "/payment-cancel?registration=complete");
//
//        // Add customer ID if available
//        if (customerId != null) {
//            paramsBuilder.setCustomer(customerId);
//        }
//
//        // Add client reference ID (userId) to help with webhook processing
//        if (userId != null) {
//            paramsBuilder.setClientReferenceId(userId.toString());
//        }
//
//        // Add line item
//        paramsBuilder.addLineItem(
//            com.stripe.param.checkout.SessionCreateParams.LineItem.builder()
//                .setQuantity(1L)
//                .setPriceData(
//                    com.stripe.param.checkout.SessionCreateParams.LineItem.PriceData.builder()
//                        .setCurrency("usd")
//                        .setUnitAmount(finalAmount)
//                        .setRecurring(
//                            com.stripe.param.checkout.SessionCreateParams.LineItem.PriceData.Recurring.builder()
//                                .setInterval(com.stripe.param.checkout.SessionCreateParams.LineItem.PriceData.Recurring.Interval.MONTH)
//                                .build()
//                        )
//                        .setProductData(
//                            com.stripe.param.checkout.SessionCreateParams.LineItem.PriceData.ProductData.builder()
//                                .setName(plan + " Plan")
//                                .build()
//                        )
//                        .build()
//                )
//                .build()
//        );
//
//        Session session = Session.create(paramsBuilder.build());
//
//        // Save payment info only if user is logged in
//        if (userId != null && userId != 0) {
//            saveCheckoutSession(userId, plan, finalAmount, session);
//        }
//
//        return ResponseEntity.ok(Map.of("checkoutUrl", session.getUrl()));
//    } catch (Exception e) {
//        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
//    }
//}

    @Transactional
    public void cancelSubscription(Long subscriptionId) {
        Subscription sub = subscriptionRepository.findById(subscriptionId)
                .orElseThrow(() -> new IllegalArgumentException("Subscription not found"));

        // Cancel on Stripe side if Stripe subscription ID is present
        String stripeSubscriptionId = sub.getStripeSubscriptionId();
        if (stripeSubscriptionId != null && !stripeSubscriptionId.isEmpty()) {
            try {
                Stripe.apiKey = stripeSecretKey;
                com.stripe.model.Subscription stripeSub = com.stripe.model.Subscription.retrieve(stripeSubscriptionId);
                stripeSub.cancel();
            } catch (Exception e) {
                throw new RuntimeException("Failed to cancel subscription on Stripe: " + e.getMessage(), e);
            }
        }

        // Clear the subscription details and set status to CANCELLED
        sub.setStatus("CANCELLED");
        sub.setStripeSubscriptionId(null);
        sub.setStripeCustomerId(null);
        sub.setPriceId(null);
        sub.setPlan(null);
        sub.setCurrentPeriodEnd(null);
        
        subscriptionRepository.save(sub);
    }

    /**
     * Cancel subscription by Stripe subscription ID and clear subscription details
     */
    @Transactional
    public void cancelSubscriptionByStripeId(String stripeSubscriptionId) {
        Optional<Subscription> subscriptionOpt = subscriptionRepository.findByStripeSubscriptionId(stripeSubscriptionId);
        if (subscriptionOpt.isPresent()) {
            Subscription sub = subscriptionOpt.get();
            
            // Cancel on Stripe side
            try {
                Stripe.apiKey = stripeSecretKey;
                com.stripe.model.Subscription stripeSub = com.stripe.model.Subscription.retrieve(stripeSubscriptionId);
                stripeSub.cancel();
            } catch (Exception e) {
                throw new RuntimeException("Failed to cancel subscription on Stripe: " + e.getMessage(), e);
            }

            // Clear the subscription details and set status to CANCELLED
            sub.setStatus("CANCELLED");
            sub.setStripeSubscriptionId(null);
            sub.setStripeCustomerId(null);
            sub.setPriceId(null);
            sub.setPlan(null);
            sub.setCurrentPeriodEnd(null);
            
            subscriptionRepository.save(sub);
        }
    }

    public void saveCheckoutSession(Long userId, String plan, long amount, Session session) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found for id: " + userId));

        // Check and save customer ID if it's missing
        String stripeCustomerId = session.getCustomer();
        if (stripeCustomerId != null && (user.getStripeCustomerId() == null || user.getStripeCustomerId().isEmpty())) {
            System.out.println("Updating user with Stripe customer ID: " + stripeCustomerId);
            user.setStripeCustomerId(stripeCustomerId);
            userRepository.save(user);
        }

        String stripeSubscriptionId = session.getSubscription();
        Subscription subscription = null;
        if (stripeSubscriptionId != null) {
            subscription = subscriptionRepository.findByStripeSubscriptionId(stripeSubscriptionId).orElse(null);
        }
        if (subscription == null) {
            subscription = new Subscription();
            subscription.setStripeSubscriptionId(stripeSubscriptionId);
            subscription.setUser(user);
            // If we have the customer ID from the session, use it
            if (stripeCustomerId != null) {
                subscription.setStripeCustomerId(stripeCustomerId);
            }
            subscription.setStatus("PENDING");
            // Set other fields as needed
            subscriptionRepository.save(subscription);
        }

        Payment payment = Payment.builder()
            .user(user)
            .subscription(subscription)
            .amountCents((int) amount)
            .status("PENDING")
            .stripeSessionId(session.getId())
            .stripePaymentIntentId(session.getPaymentIntent())
            .build();
        paymentRepository.save(payment);
    }

    public SubscriptionCollection listCustomerSubscriptions(String stripeCustomerId) {
        try {
            SubscriptionListParams params = SubscriptionListParams.builder()
                .setCustomer(stripeCustomerId)
                .build();
            return com.stripe.model.Subscription.list(params);
        } catch (StripeException e) {
            throw new RuntimeException("Failed to list subscriptions for customer: " + e.getMessage(), e);
        }
    }

    public String handleStripeWebhook(String payload, String sigHeader, String endpointSecret) {
            Event event;
            try {
                event = Webhook.constructEvent(payload, sigHeader, endpointSecret);
            } catch (JsonSyntaxException | SignatureVerificationException e) {
                throw new RuntimeException("Invalid Stripe webhook: " + e.getMessage());
            }

            System.out.println("Received Stripe webhook event: " + event.getType());
            switch (event.getType()) {
                case "checkout.session.completed" -> handleCheckoutSessionCompleted(event);
                case "checkout.session.async_payment_failed" -> handleAsyncPaymentFailed(event);
                case "checkout.session.async_payment_succeeded" -> handleAsyncPaymentSucceeded(event);
                case "checkout.session.expired" -> handleSessionExpired(event);
                case "customer.subscription.created" -> handleSubscriptionCreated(event);
                case "customer.subscription.updated" -> handleSubscriptionUpdated(event);
                case "customer.subscription.deleted" -> handleSubscriptionDeleted(event);
                case "invoice.paid" -> handleInvoicePaid(event);
                case "invoice.payment_failed" -> handleInvoicePaymentFailed(event);
                default -> {
                    System.out.println("Unhandled event type: " + event.getType());
                }
            }
            return "Webhook received";
        }

    private void handleCheckoutSessionCompleted(Event event) {
        // Extract the Session object from the event
        Session session = (Session) event.getDataObjectDeserializer().getObject().orElse(null);
        if (session == null) return;

        System.out.println("Processing checkout.session.completed event");
        String subscriptionId = session.getSubscription();
        String customerId = session.getCustomer();
        String clientReferenceId = session.getClientReferenceId(); // Could contain userId
        
        // Update payment record if we have one for this session
        if (session.getId() != null) {
            try {
                Payment payment = paymentRepository.findByStripeSessionId(session.getId());
                if (payment != null) {
                    payment.setStatus("COMPLETED");
                    paymentRepository.save(payment);
                    System.out.println("Updated payment record for session: " + session.getId());
                    
                    // If payment has a user, ensure their stripeCustomerId is set
                    if (payment.getUser() != null && customerId != null) {
                        User user = payment.getUser();
                        if (user.getStripeCustomerId() == null || user.getStripeCustomerId().isEmpty()) {
                            user.setStripeCustomerId(customerId);
                            userRepository.save(user);
                            System.out.println("Updated user " + user.getId() + " with stripe customer ID: " + customerId);
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("Error updating payment: " + e.getMessage());
            }
        }
        
        if (subscriptionId != null) {
            System.out.println("Processing subscription: " + subscriptionId + " for customer: " + customerId);
            
            // Check if we already have this subscription in our database
            Optional<Subscription> existingSub = subscriptionRepository.findByStripeSubscriptionId(subscriptionId);
            if (existingSub.isPresent()) {
                Subscription sub = existingSub.get();
                sub.setStatus("ACTIVE");
                // Ensure customer ID is set
                if (customerId != null && (sub.getStripeCustomerId() == null || sub.getStripeCustomerId().isEmpty())) {
                    sub.setStripeCustomerId(customerId);
                }
                subscriptionRepository.save(sub);
                System.out.println("Updated existing subscription: " + sub.getId());
            } else {
                // Create a new subscription record
                try {
                    // Get the subscription from Stripe
                    Stripe.apiKey = stripeSecretKey;
                    com.stripe.model.Subscription stripeSub = com.stripe.model.Subscription.retrieve(subscriptionId);
                    String stripeCustomerId = stripeSub.getCustomer();
                    
                    System.out.println("Found Stripe subscription with customer ID: " + stripeCustomerId);
                    
                    // Try to find user by stripe customer ID
                    User user = userRepository.findByStripeCustomerId(stripeCustomerId).orElse(null);
                    
                    // If user is null but we have a session ID, try to find by payment record
                    if (user == null && session.getId() != null) {
                        Payment payment = paymentRepository.findByStripeSessionId(session.getId());
                        if (payment != null && payment.getUser() != null) {
                            user = payment.getUser();
                            
                            // Update the user with the Stripe customer ID if needed
                            if (user.getStripeCustomerId() == null || user.getStripeCustomerId().isEmpty()) {
                                user.setStripeCustomerId(stripeCustomerId);
                                userRepository.save(user);
                                System.out.println("Updated user with Stripe customer ID from payment record");
                            }
                        }
                    }
                    
                    // If still no user but we have a client reference ID that might be a user ID
                    if (user == null && clientReferenceId != null) {
                        try {
                            Long userId = Long.parseLong(clientReferenceId);
                            Optional<User> userOpt = userRepository.findById(userId);
                            if (userOpt.isPresent()) {
                                user = userOpt.get();
                                
                                // Update the user with the Stripe customer ID if needed
                                if (user.getStripeCustomerId() == null || user.getStripeCustomerId().isEmpty()) {
                                    user.setStripeCustomerId(stripeCustomerId);
                                    userRepository.save(user);
                                    System.out.println("Updated user with Stripe customer ID from client reference ID");
                                }
                            }
                        } catch (NumberFormatException e) {
                            System.out.println("Client reference ID is not a valid user ID: " + clientReferenceId);
                        }
                    }
                    
                    if (user != null) {
                        System.out.println("Found user for customer ID: " + user.getId());
                        Subscription subscription = new Subscription();
                        subscription.setStripeSubscriptionId(subscriptionId);
                        subscription.setStripeCustomerId(stripeCustomerId);
                        subscription.setUser(user);
                        subscription.setStatus("ACTIVE");
                        subscription.setStartedAt(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodStart()));
                        subscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()));
                        
                        // Get the price ID and try to find a matching plan
                        if (stripeSub.getItems() != null && !stripeSub.getItems().getData().isEmpty()) {
                            String priceId = stripeSub.getItems().getData().get(0).getPrice().getId();
                            subscription.setPriceId(priceId);
                            
                            // Try to find matching plan by code
                            Plan plan = planRepository.findByCode(priceId);
                            if (plan != null) {
                                subscription.setPlan(plan);
                                System.out.println("Associated with plan: " + plan.getName());
                            }
                        }
                        
                        // Save the subscription
                        Subscription saved = subscriptionRepository.save(subscription);
                        System.out.println("Created new subscription with ID: " + saved.getId());
                    } else {
                        System.err.println("User not found for customer ID: " + stripeCustomerId);
                    }
                } catch (Exception e) {
                    System.err.println("Failed to create subscription from webhook: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        } else {
            System.out.println("No subscription ID found in the session");
        }
    }

        private void handleAsyncPaymentFailed(Event event) {
            Session session = (Session) event.getDataObjectDeserializer().getObject().orElse(null);
            if (session == null) return;
            
            String subscriptionId = session.getSubscription();
            if (subscriptionId != null) {
                subscriptionRepository.findByStripeSubscriptionId(subscriptionId)
                    .ifPresent(sub -> {
                        sub.setStatus("PAYMENT_FAILED");
                        subscriptionRepository.save(sub);
                    });
            }
        }

        private void handleAsyncPaymentSucceeded(Event event) {
            Session session = (Session) event.getDataObjectDeserializer().getObject().orElse(null);
            if (session == null) return;
            
            String subscriptionId = session.getSubscription();
            if (subscriptionId != null) {
                subscriptionRepository.findByStripeSubscriptionId(subscriptionId)
                    .ifPresent(sub -> {
                        sub.setStatus("ACTIVE");
                        subscriptionRepository.save(sub);
                    });
            }
        }

        private void handleSessionExpired(Event event) {
            Session session = (Session) event.getDataObjectDeserializer().getObject().orElse(null);
            if (session == null) return;
            
            String subscriptionId = session.getSubscription();
            if (subscriptionId != null) {
                subscriptionRepository.findByStripeSubscriptionId(subscriptionId)
                    .ifPresent(sub -> {
                        sub.setStatus("EXPIRED");
                        subscriptionRepository.save(sub);
                    });
            }
        }
        
        private void handleSubscriptionCreated(Event event) {
            com.stripe.model.Subscription stripeSub = (com.stripe.model.Subscription) event.getDataObjectDeserializer().getObject().orElse(null);
            if (stripeSub == null) return;
            
            String subscriptionId = stripeSub.getId();
            String customerId = stripeSub.getCustomer();
            
            // Check if we already have this subscription
            if (!subscriptionRepository.findByStripeSubscriptionId(subscriptionId).isPresent()) {
                try {
                    // Find user by stripe customer ID
                    User user = userRepository.findByStripeCustomerId(customerId).orElse(null);
                    if (user != null) {
                        System.out.println("Creating subscription record from subscription.created event");
                        Subscription subscription = new Subscription();
                        subscription.setStripeSubscriptionId(subscriptionId);
                        subscription.setStripeCustomerId(customerId);
                        subscription.setUser(user);
                        subscription.setStatus("ACTIVE");
                        subscription.setStartedAt(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodStart()));
                        subscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()));
                        
                        // Get the price ID
                        if (stripeSub.getItems() != null && !stripeSub.getItems().getData().isEmpty()) {
                            String priceId = stripeSub.getItems().getData().get(0).getPrice().getId();
                            subscription.setPriceId(priceId);
                            
                            // Try to find matching plan by code
                            Plan plan = planRepository.findByCode(priceId);
                            if (plan != null) {
                                subscription.setPlan(plan);
                            }
                        }
                        
                        // Save the subscription
                        subscriptionRepository.save(subscription);
                        System.out.println("Subscription saved with ID: " + subscription.getId());
                    } else {
                        System.err.println("User not found for customer ID: " + customerId);
                    }
                } catch (Exception e) {
                    System.err.println("Error handling subscription.created: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
        
        private void handleSubscriptionUpdated(Event event) {
            com.stripe.model.Subscription stripeSub = (com.stripe.model.Subscription) event.getDataObjectDeserializer().getObject().orElse(null);
            if (stripeSub == null) return;
            
            String subscriptionId = stripeSub.getId();
            subscriptionRepository.findByStripeSubscriptionId(subscriptionId)
                .ifPresent(subscription -> {
                    // Update subscription details
                    subscription.setStatus(stripeSub.getStatus());
                    subscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()));
                    
                    // Update price ID if it changed
                    if (stripeSub.getItems() != null && !stripeSub.getItems().getData().isEmpty()) {
                        String priceId = stripeSub.getItems().getData().get(0).getPrice().getId();
                        subscription.setPriceId(priceId);
                        
                        // Try to find matching plan by code
                        Plan plan = planRepository.findByCode(priceId);
                        if (plan != null) {
                            subscription.setPlan(plan);
                        }
                    }
                    
                    subscriptionRepository.save(subscription);
                });
        }
        
        private void handleInvoicePaid(Event event) {
            com.stripe.model.Invoice invoice = (com.stripe.model.Invoice) event.getDataObjectDeserializer().getObject().orElse(null);
            if (invoice == null || invoice.getSubscription() == null) return;
            
            String subscriptionId = invoice.getSubscription();
            subscriptionRepository.findByStripeSubscriptionId(subscriptionId)
                .ifPresent(subscription -> {
                    // Update subscription status to active
                    subscription.setStatus("ACTIVE");
                    subscriptionRepository.save(subscription);
                    
                    // Create payment record
                    try {
                        User user = subscription.getUser();
                        if (user != null) {
                            Payment payment = Payment.builder()
                                .user(user)
                                .subscription(subscription)
                                .amountCents(invoice.getAmountPaid().intValue())
                                .status("PAID")
                                .stripeInvoiceId(invoice.getId())
                                .attemptedAt(java.time.Instant.now())
                                .build();
                            paymentRepository.save(payment);
                        }
                    } catch (Exception e) {
                        System.err.println("Failed to create payment record: " + e.getMessage());
                    }
                });
        }
        
        private void handleInvoicePaymentFailed(Event event) {
            com.stripe.model.Invoice invoice = (com.stripe.model.Invoice) event.getDataObjectDeserializer().getObject().orElse(null);
            if (invoice == null || invoice.getSubscription() == null) return;
            
            String subscriptionId = invoice.getSubscription();
            subscriptionRepository.findByStripeSubscriptionId(subscriptionId)
                .ifPresent(subscription -> {
                    // Update subscription status to payment failed
                    subscription.setStatus("PAYMENT_FAILED");
                    subscriptionRepository.save(subscription);
                });
        }

        private void handleSubscriptionDeleted(Event event) {
            com.stripe.model.Subscription stripeSub = (com.stripe.model.Subscription) event.getDataObjectDeserializer().getObject().orElse(null);
            if (stripeSub == null) return;
            
            String subscriptionId = stripeSub.getId();
            System.out.println("Processing subscription deletion for: " + subscriptionId);
            
            subscriptionRepository.findByStripeSubscriptionId(subscriptionId)
                .ifPresent(subscription -> {
                    System.out.println("Found subscription record, clearing subscription details");
                    
                    // Clear the subscription details and set status to CANCELLED
                    subscription.setStatus("CANCELLED");
                    subscription.setStripeSubscriptionId(null);
                    subscription.setStripeCustomerId(null);
                    subscription.setPriceId(null);
                    subscription.setPlan(null);
                    subscription.setCurrentPeriodEnd(null);
                    
                    subscriptionRepository.save(subscription);
                    System.out.println("Subscription cleared and marked as cancelled");
                });
        }
        
        /**
         * Get all subscriptions for a user
         * Syncs with Stripe first to ensure data is up to date
         */
        @Transactional
        public List<Subscription> getUserSubscriptions(Long userId) {
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));
            
            // Only sync with Stripe if the user has a Stripe customer ID
            if (user.getStripeCustomerId() != null && !user.getStripeCustomerId().isEmpty()) {
                try {
                    // Sync subscriptions from Stripe before returning
                    syncAllSubscriptionsForCustomer(user.getStripeCustomerId());
                } catch (StripeException e) {
                    System.err.println("Warning: Failed to sync subscriptions from Stripe: " + e.getMessage());
                    // Continue with database records even if sync fails
                }
            }
                
            return subscriptionRepository.findByUser(user);
        }
        
    /**
     * Get all active subscriptions for a user
     * Syncs with Stripe first to ensure data is up to date
     */
    @Transactional
    public List<Subscription> getUserActiveSubscriptions(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));
        
        // Only sync with Stripe if the user has a Stripe customer ID
        if (user.getStripeCustomerId() != null && !user.getStripeCustomerId().isEmpty()) {
            try {
                // Sync subscriptions from Stripe before returning
                syncAllSubscriptionsForCustomer(user.getStripeCustomerId());
            } catch (StripeException e) {
                System.err.println("Warning: Failed to sync subscriptions from Stripe: " + e.getMessage());
                // Continue with database records even if sync fails
            }
        }
            
        return subscriptionRepository.findByUserAndStatus(user, "ACTIVE");
    }
    
    /**
     * API endpoint to manually refresh a user's subscriptions from Stripe
     * Returns the refreshed subscriptions
     */
    @Transactional
    public List<Subscription> refreshUserSubscriptionsFromStripe(Long userId) {
        try {
            return syncUserSubscriptionsFromStripe(userId);
        } catch (Exception e) {
            throw new RuntimeException("Failed to refresh subscriptions from Stripe: " + e.getMessage(), e);
        }
    }
    
    /**
     * Sync all subscriptions for a specific user by their user ID
     * This allows testing subscription association without webhooks
     */
    public List<Subscription> syncUserSubscriptionsFromStripe(Long userId) throws Exception {
        Stripe.apiKey = stripeSecretKey;
        
        // Get the user
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));
        
        // Check if the user has a Stripe customer ID
        if (user.getStripeCustomerId() == null || user.getStripeCustomerId().isEmpty()) {
            // Try to find the customer ID in Stripe by email
            try {
                Map<String, Object> params = new HashMap<>();
                params.put("email", user.getEmail());
                params.put("limit", 1);
                
                com.stripe.model.CustomerCollection customers = com.stripe.model.Customer.list(params);
                if (!customers.getData().isEmpty()) {
                    // Found a matching customer by email
                    String customerId = customers.getData().get(0).getId();
                    user.setStripeCustomerId(customerId);
                    userRepository.save(user);
                    System.out.println("Updated user with Stripe customer ID found by email search: " + customerId);
                } else {
                    // Create a new customer in Stripe
                    Map<String, Object> customerParams = new HashMap<>();
                    customerParams.put("email", user.getEmail());
                    if (user.getName() != null) {
                        customerParams.put("name", user.getName());
                    }
                    
                    com.stripe.model.Customer customer = com.stripe.model.Customer.create(customerParams);
                    String customerId = customer.getId();
                    
                    user.setStripeCustomerId(customerId);
                    userRepository.save(user);
                    System.out.println("Created new Stripe customer and updated user: " + customerId);
                }
            } catch (Exception e) {
                throw new Exception("Failed to find or create Stripe customer for user: " + e.getMessage());
            }
        }
        
        // Now that we have a customer ID, sync their subscriptions
        return syncAllSubscriptionsForCustomer(user.getStripeCustomerId());
    }
    
    /**
     * Sync all subscriptions for a customer from Stripe
     * This is useful for fixing missing subscription records
     */
    public List<Subscription> syncAllSubscriptionsForCustomer(String customerId) throws StripeException {
        System.out.println("Starting sync for customer: " + customerId);
        Stripe.apiKey = stripeSecretKey;
        
        try {
            // Find the user by Stripe customer ID
            User user = userRepository.findByStripeCustomerId(customerId).orElseThrow(() -> 
                new IllegalArgumentException("No user found with Stripe customer ID: " + customerId));
            
            System.out.println("Found user with ID: " + user.getId() + " and email: " + user.getEmail());
            
            // Get all subscriptions from Stripe
            Map<String, Object> params = new HashMap<>();
            params.put("customer", customerId);
            params.put("limit", 100); // Adjust as needed
            params.put("status", "all"); // Include all subscriptions, not just active ones
            
            com.stripe.model.SubscriptionCollection subscriptions = com.stripe.model.Subscription.list(params);
            
            System.out.println("Found " + subscriptions.getData().size() + " subscriptions in Stripe");
            
            if (subscriptions.getData().isEmpty()) {
                System.out.println("No subscriptions found for customer: " + customerId);
                return new ArrayList<>();
            }
            
            List<Subscription> result = new ArrayList<>();
            
            for (com.stripe.model.Subscription stripeSub : subscriptions.getData()) {
                System.out.println("Processing subscription: " + stripeSub.getId() + " with status: " + stripeSub.getStatus());
                
                // Check if we already have this subscription
                Optional<Subscription> existingSub = subscriptionRepository.findByStripeSubscriptionId(stripeSub.getId());
                Subscription subscription;
                
                if (existingSub.isPresent()) {
                    subscription = existingSub.get();
                    System.out.println("Updating existing subscription: " + subscription.getId());
                    
                    // Update subscription details
                    subscription.setStatus(stripeSub.getStatus());
                    subscription.setStripeCustomerId(customerId);
                    subscription.setStartedAt(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodStart()));
                    subscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()));
                } else {
                    System.out.println("Creating new subscription record for: " + stripeSub.getId());
                    subscription = new Subscription();
                    subscription.setStripeSubscriptionId(stripeSub.getId());
                    subscription.setStripeCustomerId(customerId);
                    subscription.setUser(user);
                    subscription.setStatus(stripeSub.getStatus());
                    subscription.setStartedAt(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodStart()));
                    subscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()));
                }
                
                // Try to find the matching plan
                if (stripeSub.getItems() != null && !stripeSub.getItems().getData().isEmpty()) {
                    String priceId = stripeSub.getItems().getData().get(0).getPrice().getId();
                    System.out.println("Found price ID: " + priceId);
                    subscription.setPriceId(priceId);
                    
                    // Try to find matching plan
                    Plan plan = planRepository.findByCode(priceId);
                    if (plan != null) {
                        System.out.println("Found matching plan: " + plan.getName());
                        subscription.setPlan(plan);
                    } else {
                        System.out.println("No matching plan found for price ID: " + priceId);
                    }
                }
                
                Subscription savedSubscription = subscriptionRepository.save(subscription);
                System.out.println("Saved subscription with ID: " + savedSubscription.getId());
                result.add(savedSubscription);
            }
            
            System.out.println("Sync completed, updated " + result.size() + " subscriptions");
            return result;
        } catch (Exception e) {
            System.err.println("Error in syncAllSubscriptionsForCustomer: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * Create a subscription directly without going through the checkout flow
     * This is useful for testing and manual operations
     */
    public Subscription createSubscriptionDirectly(Long userId, String priceId) throws Exception {
        Stripe.apiKey = stripeSecretKey;
        
        // Get the user
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));
        
        // Make sure the user has a Stripe customer ID
        String customerId = user.getStripeCustomerId();
        if (customerId == null || customerId.isEmpty()) {
            // Create a customer for this user
            Map<String, Object> customerParams = new HashMap<>();
            customerParams.put("email", user.getEmail());
            if (user.getName() != null) {
                customerParams.put("name", user.getName());
            }
            
            com.stripe.model.Customer customer = com.stripe.model.Customer.create(customerParams);
            customerId = customer.getId();
            
            user.setStripeCustomerId(customerId);
            userRepository.save(user);
            System.out.println("Created new customer for subscription: " + customerId);
        }
        
        // Create the subscription in Stripe
        Map<String, Object> item = new HashMap<>();
        Map<String, Object> items = new HashMap<>();
        items.put("price", priceId);
        
        Map<String, Object> params = new HashMap<>();
        params.put("customer", customerId);
        params.put("items", new Object[] { items });
        
        com.stripe.model.Subscription stripeSub = com.stripe.model.Subscription.create(params);
        
        // Create the subscription in our database
        Subscription subscription = new Subscription();
        subscription.setStripeSubscriptionId(stripeSub.getId());
        subscription.setStripeCustomerId(customerId);
        subscription.setUser(user);
        subscription.setStatus("ACTIVE");
        subscription.setStartedAt(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodStart()));
        subscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()));
        subscription.setPriceId(priceId);
        
        // Try to find a matching plan
        Plan plan = planRepository.findByCode(priceId);
        if (plan != null) {
            subscription.setPlan(plan);
        }
        
        return subscriptionRepository.save(subscription);
    }

    /**
     * Sync a subscription from Stripe into our database
     * This is useful for manually fixing missing subscription records
     */
    public Subscription syncSubscriptionFromStripe(String stripeSubscriptionId) throws StripeException {
        Stripe.apiKey = stripeSecretKey;
        
        // Check if we already have this subscription
        Optional<Subscription> existingSub = subscriptionRepository.findByStripeSubscriptionId(stripeSubscriptionId);
        if (existingSub.isPresent()) {
            // Update the existing subscription
            Subscription subscription = existingSub.get();
            
            // Get fresh data from Stripe
            com.stripe.model.Subscription stripeSub = com.stripe.model.Subscription.retrieve(stripeSubscriptionId);
            String customerId = stripeSub.getCustomer();
            
            // Update subscription details
            subscription.setStatus(stripeSub.getStatus());
            subscription.setStripeCustomerId(customerId);
            subscription.setStartedAt(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodStart()));
            subscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()));
            
            // Try to find the matching plan
            if (stripeSub.getItems() != null && !stripeSub.getItems().getData().isEmpty()) {
                String priceId = stripeSub.getItems().getData().get(0).getPrice().getId();
                subscription.setPriceId(priceId);
                
                // Try to find matching plan
                Plan plan = planRepository.findByCode(priceId);
                if (plan != null) {
                    subscription.setPlan(plan);
                }
            }
            
            return subscriptionRepository.save(subscription);
        } else {
            // Create a new subscription record
            com.stripe.model.Subscription stripeSub = com.stripe.model.Subscription.retrieve(stripeSubscriptionId);
            String customerId = stripeSub.getCustomer();
            
            // Find user by stripe customer ID
            User user = userRepository.findByStripeCustomerId(customerId).orElseThrow(() -> 
                new IllegalArgumentException("No user found with Stripe customer ID: " + customerId));
            
            Subscription subscription = new Subscription();
            subscription.setStripeSubscriptionId(stripeSubscriptionId);
            subscription.setStripeCustomerId(customerId);
            subscription.setUser(user);
            subscription.setStatus(stripeSub.getStatus());
            subscription.setStartedAt(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodStart()));
            subscription.setCurrentPeriodEnd(java.time.Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()));
            
            // Try to find the matching plan
            if (stripeSub.getItems() != null && !stripeSub.getItems().getData().isEmpty()) {
                String priceId = stripeSub.getItems().getData().get(0).getPrice().getId();
                subscription.setPriceId(priceId);
                
                // Try to find matching plan
                Plan plan = planRepository.findByCode(priceId);
                if (plan != null) {
                    subscription.setPlan(plan);
                }
            }
            
            return subscriptionRepository.save(subscription);
        }
    }
}