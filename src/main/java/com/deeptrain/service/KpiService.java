package com.deeptrain.service;

import org.springframework.stereotype.Service;

import com.deeptrain.dto.KpiResponse;

@Service
public class KpiService {

    public KpiResponse getCurrentKpis() {
        // For demo purposes, return hardcoded values
        return new KpiResponse("1.13", "0.97", "89.5%");
    }
}
