package com.deeptrain.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.Data;

@Entity
@Data
public class PageRoute {
    @Id
    private String path;

    private String component;
    private String initialDomain;

    // Lombok @Data generates getters/setters
}
