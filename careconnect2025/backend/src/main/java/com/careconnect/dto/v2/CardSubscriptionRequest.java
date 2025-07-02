package com.careconnect.dto.v2;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record CardSubscriptionRequest(
        @Email String email,
        @NotBlank String name,
        @NotBlank String priceId,
        @NotBlank String paymentMethodId
) {}