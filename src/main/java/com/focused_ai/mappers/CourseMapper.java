package com.focused_ai.mappers;

import com.focused_ai.models.domain.*;
import com.focused_ai.models.google.*;
import com.focused_ai.models.moodle.*;
import org.springframework.stereotype.Component;
import java.util.stream.Collectors;

@Component
public class CourseMapper {

    public Course fromGoogle(GoogleCourse googleCourse) {
        Course course = new Course();
        course.setId(googleCourse.getId());
        course.setName(googleCourse.getName());
        return course;
    }

    public Course fromMoodle(MoodleCourse moodleCourse) {
        Course course = new Course();
        course.setId(String.valueOf(moodleCourse.getId()));
        course.setName(moodleCourse.getFullname());
        return course;
    }

    public CourseList fromGoogle(GoogleCourseList googleList) {
        CourseList courseList = new CourseList();
        courseList.setCourses(googleList.getCourses().stream()
                .map(this::fromGoogle)
                .collect(Collectors.toList()));
        return courseList;
    }

    public CourseList fromMoodle(MoodleCourseList moodleList) {
        CourseList courseList = new CourseList();
        courseList.setCourses(moodleList.getCourses().stream()
                .map(this::fromMoodle)
                .collect(Collectors.toList()));
        return courseList;
    }
}
