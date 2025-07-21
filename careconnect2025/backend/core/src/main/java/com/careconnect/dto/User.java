package com.careconnect.dto;

public class User {
	private Long id;
	private String name;
	private String email;
	private String password;
	private boolean emailVerified;
	private com.careconnect.security.Role role;
	private String status;

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public boolean isActive() {
		return "ACTIVE".equalsIgnoreCase(status);
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public com.careconnect.security.Role getRole() {
		return role;
	}

	public void setRole(com.careconnect.security.Role role) {
		this.role = role;
	}
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

public boolean isEmailVerified() {
	return emailVerified;
}

public void setEmailVerified(boolean emailVerified) {
	this.emailVerified = emailVerified;
}

}