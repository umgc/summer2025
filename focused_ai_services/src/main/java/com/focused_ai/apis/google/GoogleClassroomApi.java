package com.focused_ai.apis.google;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import com.focused_ai.models.CourseList;
import com.focused_ai.models.StudentList;
import com.focused_ai.models.TeacherList;
import com.focused_ai.models.UserProfile;

import reactor.core.publisher.Mono;

@Service
public class GoogleClassroomApi {
    private final WebClient webClient;
    private final String googleClassroomAPI = "https://classroom.googleapis.com";

    public GoogleClassroomApi() {
        this.webClient = WebClient.builder()
            .baseUrl(googleClassroomAPI)
            .defaultHeader("Content-Type", "application/json")
            .build();
    }

    public Mono<UserProfile> getUserProfile(String accessToken) {
        return webClient.get()
            .uri("/v1/userProfiles/me")
            .header("Authorization", "Bearer " + accessToken)
            .retrieve()
            .bodyToMono(UserProfile.class);
    }

    public Mono<CourseList> getCourses(String accessToken) {
        return webClient.get()
            .uri("/v1/courses")
            .header("Authorization", "Bearer " + accessToken)
            .retrieve()
            .bodyToMono(CourseList.class);
    }

    public Mono<TeacherList> getCourseTeachers(String courseId, String accessToken) {
        return webClient.get()
            .uri("/v1/courses/{courseId}/teachers", courseId)
            .header("Authorization", "Bearer " + accessToken)
            .retrieve()
            .bodyToMono(TeacherList.class);
    }

    public Mono<StudentList> getCourseStudents(String courseId, String accessToken) {
        return webClient.get()
            .uri("/v1/courses/{courseId}/students", courseId)
            .header("Authorization", "Bearer " + accessToken)
            .retrieve()
            .bodyToMono(StudentList.class);
    }
}
