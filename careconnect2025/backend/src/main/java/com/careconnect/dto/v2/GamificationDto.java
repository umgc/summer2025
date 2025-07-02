package com.careconnect.dto.v2;

public class GamificationDto {

    private String userId;
    private String achievement;
    private int points;

    public GamificationDto(String userId, String achievement, int points) {
        this.userId = userId;
        this.achievement = achievement;
        this.points = points;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getAchievement() {
        return achievement;
    }

    public void setAchievement(String achievement) {
        this.achievement = achievement;
    }

    public int getPoints() {
        return points;
    }

    public void setPoints(int points) {
        this.points = points;
    }
}
