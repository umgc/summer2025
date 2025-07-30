package com.careconnect.service;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

import com.careconnect.dto.Metrics;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class FitbitService {

    /*private final WebClient fitbitWebClient;
    
    public FitbitService(WebClient fitbitWebClient) {
        this.fitbitWebClient = fitbitWebClient;
    }

    public Metrics getTodayMetrics() {

        Mono<JsonNode> steps    = call("/1/user/-/activities/steps/date/today/1d.json");
        Mono<JsonNode> calories = call("/1/user/-/activities/calories/date/today/1d.json");
        Mono<JsonNode> heart    = call("/1/user/-/activities/heart/date/today/1d.json");
        Mono<JsonNode> sleep    = call("/1.2/user/-/sleep/date/today.json");
        Mono<JsonNode> weight   = call("/1/user/-/body/log/weight/date/today/1d.json");

        return Mono.zip(steps, calories, heart, sleep, weight)
                   .map(t -> createMetricsFromJson(t.getT1(), t.getT2(), t.getT3(), t.getT4(), t.getT5()))
                   .block();        
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
