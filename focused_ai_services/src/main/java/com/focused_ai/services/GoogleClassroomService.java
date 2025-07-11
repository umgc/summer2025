package com.focused_ai.services;

import com.focused_ai.apis.google.GoogleClassroomApi;
import com.focused_ai.models.Course;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class GoogleClassroomService {

    private final Map<String, GoogleTokenData> googleTokenCache = new ConcurrentHashMap<>();

    private static class GoogleTokenData {
        private String accessToken;
        private String refreshToken;
        private long expiryTime; // epoch milliseconds

        public GoogleTokenData(String accessToken, String refreshToken, long expiresInSeconds) {
            this.accessToken = accessToken;
            this.refreshToken = refreshToken;
            this.expiryTime = System.currentTimeMillis() + (expiresInSeconds * 1000);
        }

        public boolean isExpired() {
            return System.currentTimeMillis() >= expiryTime;
        }

        public boolean willExpireSoon() {
            // Consider token expiring soon if it has less than 5 minutes left
            return (expiryTime - System.currentTimeMillis()) < (5 * 60 * 1000);
        }
    }

    @Value("${google.client.id}")
    private String googleClientId;

    @Value("${google.client.secret}")
    private String googleClientSecret;

    private final WebClient webClient = WebClient.create();

    private final GoogleClassroomApi apiClient;

    private Map<String, String> exchangeAuthCode(String serverAuthCode) {
        try {
            // First, get raw response as string for debugging
            Map<String, Object> response = webClient.post()
                    .uri("https://oauth2.googleapis.com/token")
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .bodyValue(
                            "code=" + serverAuthCode +
                                    "&client_id=" + googleClientId +
                                    "&client_secret=" + googleClientSecret +
                                    "&redirect_uri=postmessage" +
                                    "&grant_type=authorization_code")
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            return Map.of(
                    "access_token", (String) response.get("access_token"),
                    "refresh_token", (String) response.get("refresh_token"),
                    "expires_in", String.valueOf(response.get("expires_in")));
        } catch (Exception e) {
            throw new RuntimeException("Failed to exchange auth code: " + e.getMessage());
        }
    }

    // Might get back to this, for now the user is logged out when their session expires
    // private GoogleTokenData refreshToken(String refreshToken) {
    //     try {
    //         Map<String, Object> response = webClient.post()
    //                 .uri("https://oauth2.googleapis.com/token")
    //                 .header("Content-Type", "application/x-www-form-urlencoded")
    //                 .bodyValue(
    //                         "refresh_token=" + refreshToken +
    //                                 "&client_id=" + googleClientId +
    //                                 "&client_secret=" + googleClientSecret +
    //                                 "&grant_type=refresh_token")
    //                 .retrieve()
    //                 .bodyToMono(Map.class)
    //                 .block();

    //         long expiresIn = Long.parseLong(String.valueOf(response.get("expires_in")));
    //         return new GoogleTokenData(
    //                 (String) response.get("access_token"),
    //                 refreshToken, // refresh token remains the same
    //                 expiresIn);
    //     } catch (Exception e) {
    //         throw new RuntimeException("Failed to refresh token: " + e.getMessage());
    //     }
    // }

    // Modify the storeAccessToken method
    public void storeGoogleTokenData(String userId, GoogleTokenData tokenData) {
        googleTokenCache.put(userId, tokenData);
    }

    public Map<String, String> googleAuthenticate(String serverAuthCode, String userId) {
        Map<String, String> tokenResponse = exchangeAuthCode(serverAuthCode);
        String accessToken = tokenResponse.get("access_token");
        String refreshToken = tokenResponse.get("refresh_token");
        long expiresIn = Long.parseLong(tokenResponse.get("expires_in"));

        GoogleTokenData tokenData = new GoogleTokenData(accessToken, refreshToken, expiresIn);
        System.out.println("we got the access token: " + accessToken);
        String role = googleAuthorize(accessToken).block();
        System.out.println("we got the role " + role);

        storeGoogleTokenData(userId, tokenData);

        return Map.of(
                "role", role);
    }

    public Mono<String> googleAuthorize(String accessToken) {
        return apiClient.getUserProfile(accessToken)
                .flatMap(userProfile -> {
                    return apiClient.getCourses(accessToken)
                            .flatMap(courseList -> {
                                if (courseList.getCourses() == null || courseList.getCourses().isEmpty()) {
                                    return Mono.just("unknown");
                                }

                                String firstCourseId = String.valueOf(courseList.getCourses().get(0).getId());

                                return apiClient.getCourseTeachers(firstCourseId, accessToken)
                                        .flatMap(teacherList -> {
                                            boolean isTeacher = teacherList.getTeachers().stream()
                                                    .anyMatch(
                                                            teacher -> teacher.getUserId().equals(userProfile.getId()));

                                            if (isTeacher) {
                                                return Mono.just("teacher");
                                            }

                                            return apiClient.getCourseStudents(firstCourseId, accessToken)
                                                    .map(studentList -> {
                                                        return studentList.getStudents().stream()
                                                                .anyMatch(student -> student.getUserId()
                                                                        .equals(userProfile.getId()))
                                                                                ? "student"
                                                                                : "unknown";
                                                    });
                                        });
                            });
                });
    }

    public List<Course> getCourses(String userId) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'getCourses'");
    }
}
