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
}