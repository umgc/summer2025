package com.focused_ai.models.moodle;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class MoodleUserProfile {
    private String id;
    private String username;
}