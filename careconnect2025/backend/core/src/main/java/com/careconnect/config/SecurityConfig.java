package com.careconnect.config;

import com.careconnect.security.JwtAuthenticationFilter;
import com.careconnect.security.JwtTokenProvider;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http,
                                    JwtTokenProvider jwt,
                                    UserDetailsService uds,
                                    CorsConfigurationSource corsConfigurationSource) throws Exception {

        JwtAuthenticationFilter jwtFilter = new JwtAuthenticationFilter(jwt, uds);

        return http
            .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource))
            .sessionManagement(sm -> sm
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .httpBasic(basic -> basic
                .authenticationEntryPoint((req, res, e) ->
                    res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Basic Authentication Required")))
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((req, res, e) ->
                    res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized")))
            .authorizeHttpRequests(auth -> auth
                /* ---------- Swagger/OpenAPI documentation - MUST BE FIRST --------------- */
                .requestMatchers(
                        "/swagger-ui/**",
                        "/swagger-ui.html",
                        "/v3/api-docs/**",
                        "/v3/api-docs.yaml",
                        "/v3/api-docs",
                        "/swagger-resources/**",
                        "/webjars/**",
                        "/swagger-ui/index.html",
                        "/api-docs/**",
                        "/configuration/ui",
                        "/configuration/security"
                ).permitAll()

                /* ---------- public API endpoints ------------------------ */
                .requestMatchers(
                        "/v1/api/auth/**",
                        "/api/v1/auth/**",  // Support both URL patterns
                        "/api/auth/**",     // Support auth endpoints under /api/auth/
                        "/v1/api/users/reset-password",  // Allow password reset (current)
                        "/v1/api/users/setup-password",
                        "/v1/api/caregivers/**",
                        "/v1/api/subscriptions/**",
                        "/v1/api/email-test/**",  // Allow email testing endpoints
                        "/v1/api/test/**"  // Allow test endpoints (health check, swagger info)
                ).permitAll()

                /* ---------- public static assets ------------------------ */
                .requestMatchers(
                        "/", "/index.html", "/favicon.ico", "/static/**"
                ).permitAll()

                /* ---------- patient endpoints require auth -------------- */
                .requestMatchers(
                        "/v1/api/patients/**"
                ).authenticated()

                /* ---------- family member endpoints require auth -------- */
                .requestMatchers(
                        "/v1/api/family-members/**"
                ).authenticated()

                /* ---------- every other URL requires a valid JWT -------- */
                .anyRequest().authenticated())
            .build();
    }

    @Bean
    public org.springframework.security.crypto.password.PasswordEncoder passwordEncoder() {
        return new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder();
    }
}
