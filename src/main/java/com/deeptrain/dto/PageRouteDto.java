package com.deeptrain.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PageRouteDto {
    private String path;
    private String component;
    private String initialDomain; // for ScenarioBuilder only, if needed
}
