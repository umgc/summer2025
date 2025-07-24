package com.careconnect.dto;

import com.careconnect.model.Gender;

public class CaregiverRegistration {

    private String firstName;
    private String lastName;
    private String dob;
    private Gender gender;
    private String email;
    private String phone;
    private ProfessionalInfoDto professional;
    private AddressDto address;
    private LoginRequest credentials;
    private String caregiverType;
    private String planId; 

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getDob() {
        return dob;
    }

    public void setDob(String dob) {
        this.dob = dob;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public ProfessionalInfoDto getProfessional() {
        return professional;
    }

    public void setProfessional(ProfessionalInfoDto professional) {
        this.professional = professional;
    }

    public AddressDto getAddress() {
        return address;
    }

    public void setAddress(AddressDto address) {
        this.address = address;
    }

    public LoginRequest getCredentials() {
        return credentials;
    }

    public void setCredentials(LoginRequest credentials) {
        this.credentials = credentials;
    }

    public String getCaregiverType() { 
        return caregiverType;
    }

    public void setCaregiverType(String caregiverType) { 
        this.caregiverType = caregiverType;
    }
    
    public String getPlanId() {
        return planId;
    }
    
    public void setPlanId(String planId) {
        this.planId = planId;
    }

    public Gender getGender() {
        return gender;
    }

    public void setGender(Gender gender) {
        this.gender = gender;
    }
}