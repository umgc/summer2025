package com.careconnect.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import com.careconnect.security.SessionAuthenticationFilter;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    @Autowired
    private SessionAuthenticationFilter sessionAuthenticationFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        // http
        //         .csrf(csrf -> csrf.disable())
        //         .authorizeHttpRequests(auth -> auth
        //                 .requestMatchers(
        //                         "/uploads/**",
        //                         "/api/auth/register",
        //                         "/api/auth/login",
        //                         "/api/auth/verify/**",
        //                         "/api/auth/check",
        //                         "/api/auth/**", "/api/gamification/**"
        //                 ).permitAll()
        //                 .anyRequest().authenticated()
        //         )
        //         .addFilterBefore(sessionAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
        //         .formLogin(form -> form.disable())
        //         .httpBasic(httpBasic -> httpBasic.disable());

        // return http.build();
            http
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
            .anyRequest().permitAll()
        )
        .addFilterBefore(sessionAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
        .formLogin(form -> form.disable())
        .httpBasic(httpBasic -> httpBasic.disable());

    return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

}
