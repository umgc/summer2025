package com.focused_ai.services;

public class LoginRequest {
    private String moodleUrl;
    private String username;
    private String password;
    
    public String getMoodleUrl() {
        return moodleUrl;
    }
    
    public void setMoodleUrl(String moodleUrl) {
        this.moodleUrl = moodleUrl;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
}