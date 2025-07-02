package com.careconnect.model.v2;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class GamificationProgress {
	@Id
	private String id;
    private int points;
    private int level;
    private String badge;

    public GamificationProgress(int points, int level, String badge) {
        this.points = points;
        this.level = level;
        this.badge = badge;
    }

    public String getId() {
		return id;
	}



	public void setId(String id) {
		this.id = id;
	}



	public int getPoints() {
        return points;
    }

    public void setPoints(int points) {
        this.points = points;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public String getBadge() {
        return badge;
    }

    public void setBadge(String badge) {
        this.badge = badge;
    }
}
