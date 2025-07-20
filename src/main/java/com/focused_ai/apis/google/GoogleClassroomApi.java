package com.focused_ai.apis.google;

import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import com.focused_ai.models.google.GoogleCourseList;
import com.focused_ai.models.google.GoogleStudentList;
import com.focused_ai.models.google.GoogleTeacherList;
import com.focused_ai.models.google.GoogleUserProfile;

@Service
public class GoogleClassroomApi {
    private final RestTemplate restTemplate;
    private final String googleClassroomAPI = "https://classroom.googleapis.com";

    @Value("${GOOGLE_CLIENT_ID}")
    private String googleClientId;

    @Value("${GOOGLE_CLIENT_SECRET}")
    private String googleClientSecret;

    public GoogleClassroomApi() {
        this.restTemplate = new RestTemplate();
    }

    @SuppressWarnings("unchecked")
    public Map<String, String> exchangeAuthCode(String serverAuthCode) {
        try {
            // Prepare headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

            // Prepare form data
            MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
            formData.add("code", serverAuthCode);
            formData.add("client_id", googleClientId);
            formData.add("client_secret", googleClientSecret);
            formData.add("redirect_uri", "postmessage");
            formData.add("grant_type", "authorization_code");

            HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(formData, headers);

            ResponseEntity<Map> response = restTemplate.exchange(
                    "https://oauth2.googleapis.com/token",
                    HttpMethod.POST,
                    requestEntity,
                    Map.class);

            Map<String, Object> responseBody = response.getBody();

            return Map.of(
                    "access_token", (String) responseBody.get("access_token"),
                    "refresh_token", (String) responseBody.get("refresh_token"),
                    "expires_in", String.valueOf(responseBody.get("expires_in")));
        } catch (Exception e) {
            throw new RuntimeException("Failed to exchange auth code: " + e.getMessage());
        }
    }

    public GoogleUserProfile getUserProfile(String accessToken) {
        HttpHeaders headers = createAuthHeaders(accessToken);
        HttpEntity<String> requestEntity = new HttpEntity<>(headers);

        ResponseEntity<GoogleUserProfile> response = restTemplate.exchange(
                googleClassroomAPI + "/v1/userProfiles/me",
                HttpMethod.GET,
                requestEntity,
                GoogleUserProfile.class);

        return response.getBody();
    }

    public GoogleCourseList getCourses(String accessToken) {
        HttpHeaders headers = createAuthHeaders(accessToken);
        HttpEntity<String> requestEntity = new HttpEntity<>(headers);

        ResponseEntity<GoogleCourseList> response = restTemplate.exchange(
                googleClassroomAPI + "/v1/courses",
                HttpMethod.GET,
                requestEntity,
                GoogleCourseList.class);

        return response.getBody();
    }

    public GoogleTeacherList getCourseTeachers(String courseId, String accessToken) {
        HttpHeaders headers = createAuthHeaders(accessToken);
        HttpEntity<String> requestEntity = new HttpEntity<>(headers);

        ResponseEntity<GoogleTeacherList> response = restTemplate.exchange(
                googleClassroomAPI + "/v1/courses/{courseId}/teachers",
                HttpMethod.GET,
                requestEntity,
                GoogleTeacherList.class,
                courseId);

        return response.getBody();
    }

    public GoogleStudentList getCourseStudents(String courseId, String accessToken) {
        HttpHeaders headers = createAuthHeaders(accessToken);
        HttpEntity<String> requestEntity = new HttpEntity<>(headers);

        ResponseEntity<GoogleStudentList> response = restTemplate.exchange(
                googleClassroomAPI + "/v1/courses/{courseId}/students",
                HttpMethod.GET,
                requestEntity,
                GoogleStudentList.class,
                courseId);

        return response.getBody();
    }

    private HttpHeaders createAuthHeaders(String accessToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(accessToken);
        return headers;
    }
}