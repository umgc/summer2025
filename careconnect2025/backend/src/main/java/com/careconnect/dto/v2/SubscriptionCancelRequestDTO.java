package com.careconnect.dto.v2;

import lombok.Data;

@Data
public class SubscriptionCancelRequestDTO {
    private Long subscriptionId;

	public Long getSubscriptionId() {
		return this.subscriptionId;
	}
}