package com.careconnectpt.careconnect2025.dto.payment;

import com.careconnectpt.careconnect2025.model.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "API view of a Stripe subscription")
public record SubscriptionDto(
        String id,
        String customerId,
        String priceId,
        String status,
        Long currentPeriodEnd) {}
