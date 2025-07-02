package com.careconnect.dto.v2;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import com.careconnect.model.v2.User;

// import io.swagger.v3.oas.annotations.media.Schema;

// @Schema(description = "API view of a Stripe subscription")
public record SubscriptionDto(
        String id,
        String customerId,
        String priceId,
        String status,
        Long currentPeriodEnd) {}
