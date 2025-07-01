package com.deeptrain.model;



public class DeepSeekResponse {
    private boolean correct;
    private String feedback;
    private int score;

    public DeepSeekResponse() {}

    public DeepSeekResponse(boolean correct, String feedback, int score) {
        this.correct = correct;
        this.feedback = feedback;
        this.score = score;
    }

    public boolean isCorrect() {
        return correct;
    }

    public void setCorrect(boolean correct) {
        this.correct = correct;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }
}
