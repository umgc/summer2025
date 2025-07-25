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
    
    // Split name into first and last name for better usability
    private String firstName;
    private String lastName;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(name = "password_hash")
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private com.careconnect.security.Role role;

    @Builder.Default
    @Column(nullable = false)
    private Boolean isVerified = false;

    private String verificationToken;
    
    @Column(name = "stripe_customer_id")
    private String stripeCustomerId;

    private Timestamp createdAt;

    private Timestamp lastLogin;

    private String profileImageUrl;

    @Builder.Default
    @Column(nullable = false)
    private String status = "ACTIVE";

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(status);
    }

    // Explicit getter and setter methods for password fields
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    // Additional getters for compatibility
    public Long getId() { return id; }
    public String getName() { return name; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public String getEmail() { return email; }
    public com.careconnect.security.Role getRole() { return role; }
    public Boolean getIsVerified() { return isVerified; }
    public String getVerificationToken() { return verificationToken; }
    public String getStatus() { return status; }
    public String getProfileImageUrl() { return profileImageUrl; }
    public String getStripeCustomerId() { return stripeCustomerId; }
    
    // Additional setters for compatibility
    public void setId(Long id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public void setEmail(String email) { this.email = email; }
    public void setRole(com.careconnect.security.Role role) { this.role = role; }
    public void setIsVerified(Boolean isVerified) { this.isVerified = isVerified; }
    public void setVerificationToken(String verificationToken) { this.verificationToken = verificationToken; }
    public void setStatus(String status) { this.status = status; }
    public void setProfileImageUrl(String profileImageUrl) { this.profileImageUrl = profileImageUrl; }
    public void setStripeCustomerId(String stripeCustomerId) { this.stripeCustomerId = stripeCustomerId; }
}
