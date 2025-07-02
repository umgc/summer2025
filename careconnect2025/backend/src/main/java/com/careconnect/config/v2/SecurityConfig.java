package com.careconnect.config.v2;

import com.careconnect.security.v2.CustomOAuth2UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.client.web.reactive.function.client.ServletOAuth2AuthorizedClientExchangeFilterFunction;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    private final CustomOAuth2UserService customOAuth2UserService;

    public SecurityConfig(CustomOAuth2UserService customOAuth2UserService) {
        this.customOAuth2UserService = customOAuth2UserService;
    }

    // @Bean
    // public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    // 	http
    //     .csrf(cs -> cs.disable())
    //     .headers(h -> h.frameOptions().disable())
    //       .authorizeHttpRequests(auth -> auth
    //         .requestMatchers(
    //             "/*.html",
    //             "/css/**",
    //             "/js/**",
    //             "/v1/api/public/**",      
    //             "/v1/api/auth/login",
    //             "/v1/api/caregivers"
    //         ).permitAll()
    //         .anyRequest().authenticated()
    //     )
    //     .oauth2Login(oauth -> oauth
    //         .userInfoEndpoint(ui -> ui.userService(customOAuth2UserService))
    //         .defaultSuccessUrl("/dashboard.html", true)
    //     )
    //     .httpBasic(Customizer.withDefaults())
    //     .logout(log -> log.logoutSuccessUrl("/"));

    //     return http.build();
    // }

   /** ──────────────────────  DEV-ONLY: allow everything  ───────────────────── */
   @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
        .csrf(cs -> cs.disable())
        .headers(headers -> headers.frameOptions(frameOptions -> frameOptions.disable()))        .authorizeHttpRequests(auth -> auth
            .anyRequest().permitAll() 
        )
        .oauth2Login(Customizer.withDefaults())
        .httpBasic(Customizer.withDefaults())
        .logout(log -> log.logoutSuccessUrl("/"));
    return http.build();
}
    @Bean
    public PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }

    @Bean
    public InMemoryUserDetailsManager userDetailsService() { return new InMemoryUserDetailsManager(); }
    
    /**
     * Registers a WebClient that automatically attaches the access token
     * for the logged-in user (and refreshes it when expired).
     */
    @Bean
    public WebClient fitbitWebClient(
        OAuth2AuthorizedClientManager manager) {

      ServletOAuth2AuthorizedClientExchangeFilterFunction oauth =
          new ServletOAuth2AuthorizedClientExchangeFilterFunction(manager);
      oauth.setDefaultOAuth2AuthorizedClient(true);
     return WebClient.builder()
        	        .baseUrl("https://api.fitbit.com")
        	        .apply(oauth.oauth2Configuration())   
        	        .build();
    }
}
