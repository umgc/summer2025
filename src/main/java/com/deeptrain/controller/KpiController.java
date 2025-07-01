package com.deeptrain.controller;

import com.deeptrain.service.KpiService;
import com.deeptrain.dto.KpiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/kpi")
public class KpiController {

    @Autowired
    private KpiService kpiService;

    @GetMapping
    public KpiResponse getKpis() {
        return kpiService.getCurrentKpis();
    }
}
