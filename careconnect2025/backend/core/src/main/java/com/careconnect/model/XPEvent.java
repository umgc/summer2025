package com.careconnect.model;

public class XPEvent {
    private String eventName;
    private int xpPoints;

    public XPEvent(String eventName, int xpPoints) {
        this.eventName = eventName;
        this.xpPoints = xpPoints;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public int getXpPoints() {
        return xpPoints;
    }

    public void setXpPoints(int xpPoints) {
        this.xpPoints = xpPoints;
    }
}
