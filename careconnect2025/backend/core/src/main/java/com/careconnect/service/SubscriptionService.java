package com.careconnect.service;

import com.careconnect.model.Payment;
import com.careconnect.model.Subscription;
import com.careconnect.model.User;
import com.careconnect.repository.PaymentRepository;
import com.careconnect.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.careconnect.repository.SubscriptionRepository;
import com.stripe.model.checkout.Session;
import com.stripe.Stripe;
import java.util.Map;
import com.stripe.model.Event;
import com.stripe.net.Webhook;
import com.stripe.exception.SignatureVerificationException;
import com.google.gson.JsonSyntaxException;

import com.stripe.model.SubscriptionCollection;
import com.stripe.param.SubscriptionListParams;
import com.stripe.exception.StripeException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Value;

@Service
@RequiredArgsConstructor
public class SubscriptionService {
    private final SubscriptionRepository subscriptionRepository;
    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository;

    @Value("${stripe.secret-key}")
    private String stripeSecretKey;

    @Value("${frontend.base-url}")
    private String frontendBaseUrl;

    public ResponseEntity<?> createCheckoutSession(
    HttpServletRequest request,
    String plan,
    Long userId,
    Long amount) {
    try {
        String domain = request.getScheme() + "://" + request.getServerName() +
                (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort());

        // Use the amount from the request if provided, otherwise use default pricing
        long finalAmount;
        if (amount != null && amount > 0) {
            finalAmount = amount;
        } else {
            // Fallback to hardcoded pricing if amount not provided
            finalAmount = switch (plan.toLowerCase()) {
                case "premium" -> 3000L;
                case "standard" -> 2000L;
                default -> 2000L; // Default to standard pricing
            };
        }

        // Build Stripe session params
        com.stripe.param.checkout.SessionCreateParams params =
            com.stripe.param.checkout.SessionCreateParams.builder()
                    .setMode(com.stripe.param.checkout.SessionCreateParams.Mode.SUBSCRIPTION)
                    .setSuccessUrl(frontendBaseUrl + "/login")
                    .setCancelUrl(frontendBaseUrl + "/payment-cancel?registration=complete")
                    .addLineItem(
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
                                                                    .setName(plan + " Plan")
                                                                    .build()
                                                    )
                                                    .build()
                                    )
                                    .build()
                    )
                    .build();

        Session session = Session.create(params);

        // Save payment info only if user is logged in
        if (userId != null && userId != 0) {
            saveCheckoutSession(userId, plan, finalAmount, session);
        }

        return ResponseEntity.ok(Map.of("checkoutUrl", session.getUrl()));
    } catch (Exception e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
    }
}

    @Transactional
    public void cancelSubscription(Long subscriptionId) {
        Subscription sub = subscriptionRepository.findById(subscriptionId)
                .orElseThrow(() -> new IllegalArgumentException("Subscription not found"));

        // Cancel on Stripe side if Stripe subscription ID is present
        String stripeSubscriptionId = sub.getStripeSubscriptionId();
        if (stripeSubscriptionId != null && !stripeSubscriptionId.isEmpty()) {
            try {
                com.stripe.model.Subscription stripeSub = com.stripe.model.Subscription.retrieve(stripeSubscriptionId);
                stripeSub.cancel();
            } catch (Exception e) {
                throw new RuntimeException("Failed to cancel subscription on Stripe: " + e.getMessage(), e);
            }
        }

        sub.setStatus("CANCELLED");
        subscriptionRepository.save(sub);
    }

    public void saveCheckoutSession(Long userId, String plan, long amount, Session session) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found for id: " + userId));

    String stripeSubscriptionId = session.getSubscription();
    Subscription subscription = null;
    if (stripeSubscriptionId != null) {
        subscription = subscriptionRepository.findByStripeSubscriptionId(stripeSubscriptionId).orElse(null);
    }
    if (subscription == null) {
        subscription = new Subscription();
        subscription.setStripeSubscriptionId(stripeSubscriptionId);
        subscription.setUser(user);
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

            switch (event.getType()) {
                case "checkout.session.completed" -> handleCheckoutSessionCompleted(event);
                case "checkout.session.async_payment_failed" -> handleAsyncPaymentFailed(event);
                case "checkout.session.async_payment_succeeded" -> handleAsyncPaymentSucceeded(event);
                case "checkout.session.expired" -> handleSessionExpired(event);
                default -> {
                    // Unhandled event type - logging disabled
                    // System.out.println("Unhandled event type: " + event.getType());
                }
            }
            return "Webhook received";
        }

    private void handleCheckoutSessionCompleted(Event event) {
        // Extract the Session object from the event
        Session session = (Session) event.getDataObjectDeserializer().getObject().orElse(null);
        if (session == null) return;

        subscriptionRepository.findByStripeSubscriptionId(session.getSubscription())
            .ifPresent(sub -> {
                sub.setStatus("ACTIVE");
                subscriptionRepository.save(sub);
            });
    }

        private void handleAsyncPaymentFailed(Event event) {
        }

        private void handleAsyncPaymentSucceeded(Event event) {
        }

        private void handleSessionExpired(Event event) {
        }
}