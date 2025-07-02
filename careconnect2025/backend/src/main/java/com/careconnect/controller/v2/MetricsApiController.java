package com.careconnect.controller.v2;


import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.careconnect.dto.v2.Metrics;
import com.careconnect.service.v2.FitbitService;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@RestController
@RequestMapping("/v2/api")
@RequiredArgsConstructor
public class MetricsApiController {

    private final FitbitService fitbitService = null;
    

    @GetMapping("/metrics/today")
    public Metrics today() {
        return fitbitService.getTodayMetrics();
    }
    
    @GetMapping("/metrics")
    public String metrics() {
        return "metrics";         
    }
}
