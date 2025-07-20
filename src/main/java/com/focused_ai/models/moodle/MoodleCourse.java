package com.focused_ai.models.moodle;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class MoodleCourse {
    private int id;
    private String fullname;
}