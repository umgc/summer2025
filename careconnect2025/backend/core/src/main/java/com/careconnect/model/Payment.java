package com.careconnect.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import com.careconnect.model.Subscription;
import com.careconnect.model.User;



@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subscription_id")
    private Subscription subscription;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    private Integer amountCents;
    private String status; // SUCCEEDED, FAILED
    private Instant attemptedAt;

    private String stripeSessionId;
    private String stripePaymentIntentId;
    private String stripeInvoiceId;
    public void setAmountCents(Integer amountCents) { this.amountCents = amountCents; }
    public void setStripeSessionId(String stripeSessionId) { this.stripeSessionId = stripeSessionId; }
    public void setStripePaymentIntentId(String stripePaymentIntentId) { this.stripePaymentIntentId = stripePaymentIntentId; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}