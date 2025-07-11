package com.focused_ai.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Course {
    private int id;
    private String fullname;

    // Constructors
    public Course() {
    }

    public Course(int id, String fullname) {
        this.id = id;
        this.fullname = fullname;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFullname() {
        return fullname;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }
}