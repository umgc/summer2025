package com.careconnect.dto;

import java.util.List;

import io.micrometer.common.lang.Nullable;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskDto {
    @NotNull(message = "Task name is required")
    private String name;
    @Nullable
    private String description;
    @NotNull(message = "Date is required")
    private String date;
    @Nullable
    private String timeOfDay; // Assuming timeOfDay is a string representation
    @NotNull(message = "Completion state is required")
    private boolean isCompleted;
    @Nullable
    private String frequency;
    @Nullable
    private int interval;
    @Nullable
    private int count;
    @Nullable
    private String daysOfWeek;
    private String taskType;
}
