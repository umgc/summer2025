package com.careconnect.dto;

public class LeaderboardEntry {
    private Long userId;
    private String name;
    private int xp;
    private int level;
    private String profileImageUrl;

    public LeaderboardEntry(Long userId, String name, int xp, int level, String profileImageUrl) {
        this.userId = userId;
        this.name = name;
        this.xp = xp;
        this.level = level;
        this.profileImageUrl = profileImageUrl;
    }

    public Long getUserId() { return userId; }
    public String getName() { return name; }
    public int getXp() { return xp; }
    public int getLevel() { return level; }
    public String getProfileImageUrl() { return profileImageUrl; }
}