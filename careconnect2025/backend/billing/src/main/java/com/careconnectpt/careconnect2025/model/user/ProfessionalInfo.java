package com.careconnectpt.careconnect2025.model.user;


import jakarta.persistence.Embeddable;
import lombok.*;

@Embeddable
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ProfessionalInfo {
    private String licenseNumber;
    private String issuingState;
    private int yearsExperience;
	public String getLicenseNumber() {
		return licenseNumber;
	}
	public void setLicenseNumber(String licenseNumber) {
		this.licenseNumber = licenseNumber;
	}
	public String getIssuingState() {
		return issuingState;
	}
	public void setIssuingState(String issuingState) {
		this.issuingState = issuingState;
	}
	public int getYearsExperience() {
		return yearsExperience;
	}
	public void setYearsExperience(int yearsExperience) {
		this.yearsExperience = yearsExperience;
	}

}