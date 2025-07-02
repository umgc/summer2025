package com.careconnect.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Builder;
import java.sql.Timestamp;

@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
	@Column(nullable = false)
    // private String role; // "patient" or "caregiver"
    private com.careconnect.security.Role role;

    @Column(nullable = false)
    private Boolean isVerified = false;

    private String verificationToken;

    private Timestamp createdAt;

    private Timestamp lastLogin;

    private String profileImageUrl;


}
