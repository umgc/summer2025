package com.careconnectpt.careconnect2025.service;

import com.careconnectpt.careconnect2025.dto.payment.CardSubscriptionRequest;
import com.careconnectpt.careconnect2025.dto.payment.SubscriptionResponse;
//import com.careconnectpt.careconnect2025.model.payment.Subscription;
//import com.careconnectpt.careconnect2025.model.user.User;
import com.careconnectpt.careconnect2025.repository.SubscriptionRepository;
import com.careconnectpt.careconnect2025.repository.UserRepository;
import com.stripe.exception.StripeException;
import com.stripe.model.Customer;
import com.stripe.model.PaymentMethod;
//import com.stripe.model.SubscriptionCreateParams;
//import com.stripe.model.Subscription as StripeSubscription;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

//import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class StripeService {

    private final SubscriptionRepository subs = null;
    private final UserRepository users = null;

    @Transactional
    public SubscriptionResponse createCardSubscription(CardSubscriptionRequest req) throws StripeException {
        // 1. Ensure Stripe Customer exists
        Customer customer = Customer.list(Map.of("email", req.email(), "limit", 1L))
                .getData().stream().findFirst().orElse(null);
        if (customer == null) {
            customer = Customer.create(Map.of(
                    "email", req.email(),
                    "name", req.name()
            ));
        }

        // 2. Attach PM to customer
        PaymentMethod pm = PaymentMethod.retrieve(req.paymentMethodId());
        pm.attach(Map.of("customer", customer.getId()));

        // 3. Create subscription
//        SubscriptionCreateParams subParams = SubscriptionCreateParams.builder()
//                .setCustomer(customer.getId())
//                .addItem(SubscriptionCreateParams.Item.builder().setPrice(req.priceId()).build())
//                .addPaymentSettingsPaymentMethodType(SubscriptionCreateParams.PaymentSettings.PaymentMethodType.CARD)
//                .setPaymentSettings(
//                        SubscriptionCreateParams.PaymentSettings.builder()
//                                .setSaveDefaultPaymentMethod(SubscriptionCreateParams.PaymentSettings.SaveDefaultPaymentMethod.ON_SUBSCRIPTION)
//                                .build())
//                .setDefaultPaymentMethod(req.paymentMethodId())
//                .build();
//
//        StripeSubscription subscription = StripeSubscription.create(subParams);
//
//        // 4. Persist locally
//        User user = users.findByEmail(req.email()).orElse(null);
//        Subscription subEntity = new Subscription();
//        subEntity.setStripeSubscriptionId(subscription.getId());
//        subEntity.setStripeCustomerId(customer.getId());
//        subEntity.setPriceId(req.priceId());
//        subEntity.setUser(user);
//        subs.save(subEntity);
//
//        String clientSecret = subscription.getLatestInvoiceObject()
//                .getPaymentIntentObject().getClientSecret();
//        return new SubscriptionResponse(subscription.getId(), clientSecret);
        return null;
    }
}