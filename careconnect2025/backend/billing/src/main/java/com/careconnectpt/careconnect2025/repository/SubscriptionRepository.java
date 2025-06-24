package com.careconnectpt.careconnect2025.repository;

import com.careconnectpt.careconnect2025.model.payment.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {
    Optional<Subscription> findByStripeSubscriptionId(String stripeId);
}
