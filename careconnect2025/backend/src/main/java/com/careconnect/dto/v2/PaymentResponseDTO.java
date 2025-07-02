package com.careconnect.dto.v2;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PaymentResponseDTO {
    private Long paymentId;
    private String status;
    private String stripeSessionId;
    private String stripePaymentIntentId;
}