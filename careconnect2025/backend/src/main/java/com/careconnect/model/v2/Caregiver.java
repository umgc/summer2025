package com.careconnect.model.v2;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonBackReference;

@Entity
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Caregiver {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String firstName;
    private String lastName;
    private String dob;

    private String email;
    private String phone;

    @Embedded
    private ProfessionalInfo professional;

    @Embedded
    private Address address;

    private String caregiverType; 

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "user_id")
    private User user;

    @OneToMany(mappedBy = "caregiver")
    @JsonIgnore
    private List<Patient> patients;

    public String getCaregiverType() {
    return caregiverType;
    }

    public void setCaregiverType(String caregiverType) {
        this.caregiverType = caregiverType;
    }
}