package com.deeptrain.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.deeptrain.dto.NodeBlockDto;
import com.deeptrain.service.ScenarioService;

@RestController
@RequestMapping("/api/scenario")
public class ScenarioController {

    @Autowired
    private ScenarioService scenarioService;

    @PostMapping("/{domain}/save")
    public List<NodeBlockDto> saveScenario(@PathVariable String domain, @RequestBody List<NodeBlockDto> nodes) {
        return scenarioService.saveScenario(domain, nodes);
    }

    @GetMapping("/{domain}/load")
    public List<NodeBlockDto> loadScenario(@PathVariable String domain) {
        return scenarioService.loadScenario(domain);
    }
    @GetMapping("/id/{scenarioId}")
public ResponseEntity<List<NodeBlockDto>> getById(@PathVariable String scenarioId) {
    List<NodeBlockDto> blocks = scenarioService.loadScenario(scenarioId);
    return ResponseEntity.ok(blocks);
}
}