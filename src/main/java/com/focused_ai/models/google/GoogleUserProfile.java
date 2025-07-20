package com.focused_ai.models.google;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class GoogleUserProfile {
    private String id;
    private String emailAddress;
}