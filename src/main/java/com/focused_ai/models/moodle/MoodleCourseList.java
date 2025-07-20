package com.focused_ai.models.moodle;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class MoodleCourseList {
    private List<MoodleCourse> courses;
}