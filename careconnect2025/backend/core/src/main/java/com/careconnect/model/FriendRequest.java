package com.careconnect.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Entity
@Getter
@Setter
public class FriendRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long fromUserId;
    private Long toUserId;

    private String status; // pending, accepted, rejected

    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;
}
