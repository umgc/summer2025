package com.careconnect.security;

import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.Arrays;
import java.util.List;

@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String COOKIE_NAME = "AUTH";
    
    // Paths that should be excluded from JWT authentication
    private static final List<String> EXCLUDED_PATHS = Arrays.asList(
        "/swagger-ui",
        "/v3/api-docs",
        "/swagger-resources",
        "/webjars",
        "/v1/api/auth",
        "/api/v1/auth",
        "/v1/api/test",
        "/v1/api/caregivers",
        "/v1/api/subscriptions",
        "/v1/api/email-test"
    );

    private final JwtTokenProvider jwt;
    private final UserDetailsService uds;
    
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getRequestURI();
        return EXCLUDED_PATHS.stream().anyMatch(path::startsWith);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                    HttpServletResponse res,
                                    FilterChain chain)
            throws ServletException, IOException {

        /* ---------- 1. Find token (header or cookie) --------------------- */
        String token = resolveToken(req);

        /* ---------- 2. Validate & build Authentication ------------------- */
        if (token != null && jwt.validateToken(token)) {
            Claims claims = jwt.getClaims(token);
            String email  = claims.getSubject();

            UserDetails userDetails = uds.loadUserByUsername(email);
            UsernamePasswordAuthenticationToken auth =
                new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities());
            auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
            SecurityContextHolder.getContext().setAuthentication(auth);

            /* ---------- 3. Silent renew (<5 min left) -------------------- */
            if (jwt.needsRenewal(claims)) {
                String renewed = jwt.refresh(claims);
                ResponseCookie cookie = ResponseCookie.from(COOKIE_NAME, renewed)
                        .httpOnly(true).secure(true).sameSite("Lax").path("/")
                        .maxAge(Duration.ofHours(3))            // sliding-window cap
                        .build();
                res.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
            }
        }

        chain.doFilter(req, res);
    }

    private String resolveToken(HttpServletRequest req) {
        // a) Bearer header
        String header = req.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        // b) HttpOnly cookie
        if (req.getCookies() != null) {
            return Arrays.stream(req.getCookies())
                         .filter(c -> COOKIE_NAME.equals(c.getName()))
                         .findFirst()
                         .map(Cookie::getValue)
                         .orElse(null);
        }
        return null;
    }
}
