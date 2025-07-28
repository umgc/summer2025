package com.careconnect.dto;

import java.util.List;

import io.micrometer.common.lang.Nullable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TemplateDto {
    private String name;
    @Nullable
    private String description;
    @Nullable
    private String frequency;
    @Nullable
    private int interval;
    @Nullable
    private int count;
    @Nullable
    private List<Boolean> daysOfWeek;
    @Nullable
    private String timeOfDay;
    private int icon;
    @Nullable
    private List<String> notifications;
}
