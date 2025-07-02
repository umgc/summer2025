package com.careconnect.model.v2;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class Achievement {
	 @Id
    private String id;
    private String name;
    private String description;
    private int points;

    public Achievement(String id, String name, String description, int points) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.points = points;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getPoints() {
        return points;
    }

    public void setPoints(int points) {
        this.points = points;
    }
}
