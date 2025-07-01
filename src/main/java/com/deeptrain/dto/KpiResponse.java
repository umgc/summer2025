package com.deeptrain.dto;

import lombok.Data;

@Data

public class KpiResponse {
    private String cpi;
    private String spi;
    private String accuracyRate;

    public KpiResponse(String cpi, String spi, String accuracyRate) {
        this.cpi = cpi;
        this.spi = spi;
        this.accuracyRate = accuracyRate;
    }

    
}
