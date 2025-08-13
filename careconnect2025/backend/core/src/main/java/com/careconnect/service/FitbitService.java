package com.careconnect.service;

import org.springframework.stereotype.Service;

import com.careconnect.dto.Metrics;
import com.fasterxml.jackson.databind.JsonNode;

@Service
public class FitbitService {

    /*private final WebClient fitbitWebClient;
    
    public FitbitService(WebClient fitbitWebClient) {
        this.fitbitWebClient = fitbitWebClient;
    }

    public Metrics getTodayMetrics() {
        // TODO: Replace with synchronous HTTP client logic for all Fitbit API calls
        throw new UnsupportedOperationException("Synchronous Fitbit call not yet implemented");
    }

    private Metrics createMetricsFromJson(JsonNode steps, JsonNode calories, JsonNode heart, JsonNode sleep, JsonNode weight) {
        Metrics metrics = new Metrics();
        metrics.setMetricType("daily_summary");
        metrics.setSource("fitbit");
        metrics.setTimestamp(java.time.LocalDateTime.now());
        return metrics;
    }

    private Mono<JsonNode> call(String path) {
        return fitbitWebClient.get().uri(path).retrieve().bodyToMono(JsonNode.class);
    }*/
}
