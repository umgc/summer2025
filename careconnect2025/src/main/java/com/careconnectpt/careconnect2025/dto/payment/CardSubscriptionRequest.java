package com.careconnectpt.careconnect2025.dto.payment;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record CardSubscriptionRequest(
        @Email String email,
        @NotBlank String name,
        @NotBlank String priceId,
        @NotBlank String paymentMethodId
) {}