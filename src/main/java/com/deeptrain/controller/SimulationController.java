package com.deeptrain.controller;

import java.util.Map;

import com.deeptrain.dto.SimulationResponseDto;
import com.deeptrain.model.SimulationResponse;
import com.deeptrain.service.SimulationService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/simulation")
public class SimulationController {

    private final SimulationService simulationService;

    public SimulationController(SimulationService simulationService) {
        this.simulationService = simulationService;
    }

    // Endpoint to run a simulation based on scenario ID
    @PostMapping("/run")
    public ResponseEntity<String> runSimulation(@RequestBody String scenarioId) {
        String result = simulationService.runScenario(scenarioId);
        return ResponseEntity.ok(result);
    }

    // Load current simulation scenario
    @GetMapping("/load")
    public ResponseEntity<Map<String, String>> loadSimulation() {
        return ResponseEntity.ok(
            Map.of(
                "status", "ACTIVE",
                "event", "You see smoke coming from the dashboard. What do you do?"
            )
        );
    }

    // Submit user response to simulation and return evaluated result
    @PostMapping("/response")
    public ResponseEntity<SimulationResponse> submit(@RequestBody SimulationResponseDto dto) {
        SimulationResponse response = simulationService.submitResponse(dto);
        return ResponseEntity.ok(response);
    }
}
