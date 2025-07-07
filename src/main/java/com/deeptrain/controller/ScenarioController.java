package com.deeptrain.controller;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.deeptrain.dto.ScenarioDTO;
import com.deeptrain.model.Scenario;
import com.deeptrain.service.ScenarioService;

@RestController
@RequestMapping("/api/v1/scenarios")
@CrossOrigin(origins = "*")
public class ScenarioController {

    @Autowired
    private ScenarioService scenarioService;
/* 
    @PostMapping
    public ResponseEntity<Scenario> createScenario(@RequestBody ScenarioDTO dto) {
        Scenario saved = scenarioService.saveScenario(dto);
        return ResponseEntity.ok(saved);
    }
    @PostMapping("/scenario/save")
     public Scenario saveScenario(@RequestBody ScenarioDTO dto) {
    return scenarioService.saveScenario(dto);  // This will save Scenario to the DB
} */
@PostMapping("/save")
public ResponseEntity<Scenario> createScenario(@RequestBody ScenarioDTO dto) {
    Scenario saved = scenarioService.saveScenario(dto);
    return ResponseEntity.ok(saved);
}

    @GetMapping
    public ResponseEntity<List<Scenario>> getAllScenarios() {
        return ResponseEntity.ok(scenarioService.getAllScenarios());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Scenario> getScenarioById(@PathVariable Long id) {
        return scenarioService.getScenarioById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Scenario> updateScenario(@PathVariable Long id, @RequestBody ScenarioDTO dto) {
        return scenarioService.updateScenario(id, dto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteScenario(@PathVariable Long id) {
        scenarioService.deleteScenario(id);
        return ResponseEntity.noContent().build();
    }
}
