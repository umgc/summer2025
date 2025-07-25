package com.careconnect.security;

import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.*;
import org.springframework.security.oauth2.core.user.*;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class CustomOAuth2UserService implements OAuth2UserService<OAuth2UserRequest, OAuth2User> {

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2UserService<OAuth2UserRequest, OAuth2User> delegate = new DefaultOAuth2UserService();
        OAuth2User oauthUser = delegate.loadUser(userRequest);

        String email = oauthUser.getAttribute("email");
        String role = determineRoleByEmail(email);

        return new DefaultOAuth2User(
            List.of(new SimpleGrantedAuthority("ROLE_" + role.toUpperCase())),
            oauthUser.getAttributes(),
            "email"
        );
    }

    private String determineRoleByEmail(String email) {
        if (email != null && email.contains("caregiver")) return "CAREGIVER";
        return "PATIENT";
    }
}
