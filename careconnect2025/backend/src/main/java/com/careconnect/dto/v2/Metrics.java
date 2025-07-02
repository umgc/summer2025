package com.careconnect.dto.v2;


import com.fasterxml.jackson.databind.JsonNode;

/**
 * Immutable snapshot of today’s Fitbit data (serialized to JSON automatically).
 */
public record Metrics(
        int steps,
        int calories,
        int restingHeartRate,
        int sleepMinutes,
        double weight) {

    public static Metrics from(JsonNode steps, JsonNode calories,
                               JsonNode heart, JsonNode sleep,
                               JsonNode weight) {

        int s  = steps.path("activities-steps").get(0).path("value").asInt();
        int c  = calories.path("activities-calories").get(0).path("value").asInt();
        int hr = heart.path("activities-heart").get(0)
                      .path("value").path("restingHeartRate").asInt();
        int sl = sleep.path("summary").path("totalMinutesAsleep").asInt();
        double w = weight.path("weight").size() > 0
                 ? weight.path("weight").get(0).path("weight").asDouble()
                 : 0.0;

        return new Metrics(s, c, hr, sl, w);
    }
}