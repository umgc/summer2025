package com.careconnect.model;

import java.time.LocalDateTime;
import java.util.List;

import io.micrometer.common.lang.Nullable;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "tasks")
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id")
    private Patient patient;
    
    private String name;
    @Nullable
    private String description;
    
    private String date;
    @Nullable
    private String timeOfDay;
    
    private boolean isCompleted;

    private String taskType;
    
    // FrequencyTask fields
    @Nullable
    private String frequency; // e.g. "daily", "weekly", etc.
    @Nullable
    private int taskInterval; // Interval for the frequency, e.g. every 2 days
    @Nullable
    private int doCount; // Number of occurrences

    // DayOfWeekTask fields
    @Nullable
    private String daysOfWeek; // 7 long list for each day of the week
}