package com.deeptrain.service;

import com.deeptrain.dto.NodeBlockDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;


import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScenarioService {

    private final WebClient deepSeekClient;

    // Save not yet implemented: you can persist to DB later
    public List<NodeBlockDto> saveScenario(String domain, List<NodeBlockDto> nodes) {
        return nodes;
    }

    public List<NodeBlockDto> loadScenario(String domain) {
        try {
            return deepSeekClient.get()
                    .uri("/scenarios/{domain}", domain)
                    .retrieve()
                    .bodyToFlux(NodeBlockDto.class)
                    .collectList()
                    .block(); // Blocking for simplicity; consider reactive in future
        } catch (Exception e) {
            log.error("Failed to fetch scenario from DeepSeek for domain {}", domain, e);
            return List.of(); // Empty fallback
        }
    }

    public void clearScenario(String domain) {
        // Not applicable for remote fetch, but kept for compatibility
        log.info("Clear scenario is not implemented for DeepSeek-backed service.");
    }
}
