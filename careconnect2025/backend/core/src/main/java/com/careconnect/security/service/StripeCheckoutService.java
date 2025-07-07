package com.careconnect.service;

import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import com.careconnect.repository.PaymentRepository;
import com.careconnect.repository.UserRepository;
import com.careconnect.model.User;
import com.careconnect.model.Payment;
import com.careconnect.model.Subscription;
//import com.stripe.model.SubscriptionCreateParams;
//import com.stripe.model.Subscription as StripeSubscription;
import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class StripeCheckoutService {
	@Autowired
    private PaymentRepository paymentRepository;
	@Autowired
    private UserRepository userRepository;

    public Session createCheckoutSession(String plan, long amount, String successUrl, String cancelUrl) throws StripeException {
        SessionCreateParams params = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.SUBSCRIPTION)
                .setSuccessUrl(successUrl + "?session_id={CHECKOUT_SESSION_ID}")
                .setCancelUrl(cancelUrl)
                .addLineItem(SessionCreateParams.LineItem.builder()
                        .setQuantity(1L)
                        .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                                .setCurrency("usd")
                                .setRecurring(SessionCreateParams.LineItem.PriceData.Recurring.builder().setInterval(SessionCreateParams.LineItem.PriceData.Recurring.Interval.MONTH).build())
                                .setUnitAmount(amount)
                                .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder().setName(plan).build())
                                .build())
                        .build())
                .build();

        return Session.create(params);
    }

        public void saveCheckoutSession(Long userId, String plan, long amount, Session session) {
        User user = userRepository.findById(userId).orElseThrow();
        Payment payment = Payment.builder()
            .user(user)
            .amountCents((int) amount)
            .status("PENDING")
            .stripeSessionId(session.getId())
            .stripePaymentIntentId(session.getPaymentIntent())
            .build();
        paymentRepository.save(payment);
    }
}
