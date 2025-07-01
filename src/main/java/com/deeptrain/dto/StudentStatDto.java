package com.deeptrain.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class StudentStatDto {
    private String title;
    private String value;
    private String change;
    private String icon;
}
