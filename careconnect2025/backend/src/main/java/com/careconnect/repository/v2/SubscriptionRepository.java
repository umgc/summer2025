package com.careconnect.repository.v2;

import org.springframework.data.jpa.repository.JpaRepository;

import com.careconnect.model.v2.Subscription;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Profile("v2")
@Repository
public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {
    Optional<Subscription> findByStripeSubscriptionId(String stripeId);
}
