package com.careconnect.model;


import com.careconnect.model.Plan;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.Instant;

@Entity
@Table(name = "subscriptions")
@Getter @Setter @NoArgsConstructor
public class Subscription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String stripeSubscriptionId;

    private String stripeCustomerId;

    private String priceId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id")
    private Plan plan;

    private String status; // ACTIVE, CANCELLED, etc.
    private Instant startedAt;
    private Instant currentPeriodEnd;
    
    // Explicit getter methods for compatibility
    public Long getId() { return id; }
    public String getStripeSubscriptionId() { return stripeSubscriptionId; }
    public String getStripeCustomerId() { return stripeCustomerId; }
    public String getPriceId() { return priceId; }
    public User getUser() { return user; }
    public Plan getPlan() { return plan; }
    public String getStatus() { return status; }
    public Instant getStartedAt() { return startedAt; }
    public Instant getCurrentPeriodEnd() { return currentPeriodEnd; }
    
    // Explicit setter methods for compatibility
    public void setId(Long id) { this.id = id; }
    public void setStripeSubscriptionId(String stripeSubscriptionId) { this.stripeSubscriptionId = stripeSubscriptionId; }
    public void setStripeCustomerId(String stripeCustomerId) { this.stripeCustomerId = stripeCustomerId; }
    public void setPriceId(String priceId) { this.priceId = priceId; }
    public void setUser(User user) { this.user = user; }
    public void setPlan(Plan plan) { this.plan = plan; }
    public void setStatus(String status) { this.status = status; }
    public void setStartedAt(Instant startedAt) { this.startedAt = startedAt; }
    public void setCurrentPeriodEnd(Instant currentPeriodEnd) { this.currentPeriodEnd = currentPeriodEnd; }
}
