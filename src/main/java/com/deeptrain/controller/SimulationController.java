package com.deeptrain.controller;

import com.deeptrain.service.SimulationService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/simulation")
public class SimulationController {

    private final SimulationService simulationService;

    public SimulationController(SimulationService simulationService) {
        this.simulationService = simulationService;
    }

    @PostMapping("/run")
    public String runSimulation(@RequestBody String scenarioId) {
        return simulationService.runScenario(scenarioId);
    }
}
