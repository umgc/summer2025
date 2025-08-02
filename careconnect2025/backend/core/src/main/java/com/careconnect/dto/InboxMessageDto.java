package com.careconnect.dto;

import java.time.LocalDateTime;

public class InboxMessageDto {
    private Long messageId;
    private Long peerId;
    private String peerName;
    private String peerEmail;
    private String content;
    private LocalDateTime timestamp;

    // Default constructor
    public InboxMessageDto() {}

    public InboxMessageDto(Long messageId, Long peerId, String peerName, String peerEmail,
                           String content, LocalDateTime timestamp) {
        this.messageId = messageId;
        this.peerId = peerId;
        this.peerName = peerName;
        this.peerEmail = peerEmail;
        this.content = content;
        this.timestamp = timestamp;
    }

    // Getters and Setters

    public Long getMessageId() {
        return messageId;
    }

    public void setMessageId(Long messageId) {
        this.messageId = messageId;
    }

    public Long getPeerId() {
        return peerId;
    }

    public void setPeerId(Long peerId) {
        this.peerId = peerId;
    }

    public String getPeerName() {
        return peerName;
    }

    public void setPeerName(String peerName) {
        this.peerName = peerName;
    }

    public String getPeerEmail() {
        return peerEmail;
    }

    public void setPeerEmail(String peerEmail) {
        this.peerEmail = peerEmail;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}