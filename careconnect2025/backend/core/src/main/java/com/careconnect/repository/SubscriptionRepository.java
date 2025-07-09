package com.careconnect.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.careconnect.model.Subscription;

import java.util.Optional;

public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {
    Optional<Subscription> findByStripeSubscriptionId(String stripeId);
}
