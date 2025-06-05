package com.careconnectpt.careconnect2025.config;

import com.careconnectpt.careconnect2025.security.JwtAuthenticationFilter;
import com.careconnectpt.careconnect2025.security.JwtTokenProvider;
import com.careconnectpt.careconnect2025.security.Role;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }

    @Bean
    public AuthenticationProvider authenticationProvider(UserDetailsService uds, PasswordEncoder encoder) {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(uds);
        provider.setPasswordEncoder(encoder);
        return provider;
    }

    @Bean
    public SecurityFilterChain filterChain(org.springframework.security.config.annotation.web.builders.HttpSecurity http,
                                           JwtTokenProvider jwtTokenProvider,
                                           UserDetailsService uds) throws Exception {
        http.csrf(cs -> cs.disable())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(req -> req
                    .requestMatchers("/api/auth/**", "/v3/api-docs/**", "/swagger-ui/**", "/api/health").permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/gamification/me").hasAnyRole(Role.PATIENT.name(), Role.CAREGIVER.name())
                    .anyRequest().authenticated())
            .authenticationProvider(authenticationProvider(uds, passwordEncoder()))
            .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider, uds), UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager();
    }
}