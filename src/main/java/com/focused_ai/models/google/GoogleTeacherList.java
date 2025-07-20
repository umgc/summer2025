package com.focused_ai.models.google;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class GoogleTeacherList {
    private List<GoogleTeacher> teachers;
}