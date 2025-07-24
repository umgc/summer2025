package com.careconnect.dto;

import com.careconnect.model.Gender;
import java.util.List;

/**
 * DTO for updating patient profile information
 * This includes optional fields that can be updated after registration
 */
public class PatientProfileUpdateDTO {
    
    private String firstName;
    private String lastName;
    private String phone;
    private String dob;
    private Gender gender;
    private AddressDto address;
    private String relationship;
    
    // Allergies are managed separately through the allergy endpoints
    // but can be included here for bulk profile updates if needed
    private List<AllergyDTO> allergies;
    
    public PatientProfileUpdateDTO() {}
    
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
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getDob() {
        return dob;
    }
    
    public void setDob(String dob) {
        this.dob = dob;
    }
    
    public Gender getGender() {
        return gender;
    }
    
    public void setGender(Gender gender) {
        this.gender = gender;
    }
    
    public AddressDto getAddress() {
        return address;
    }
    
    public void setAddress(AddressDto address) {
        this.address = address;
    }
    
    public String getRelationship() {
        return relationship;
    }
    
    public void setRelationship(String relationship) {
        this.relationship = relationship;
    }
    
    public List<AllergyDTO> getAllergies() {
        return allergies;
    }
    
    public void setAllergies(List<AllergyDTO> allergies) {
        this.allergies = allergies;
    }
}
