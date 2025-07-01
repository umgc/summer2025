package com.deeptrain.dto;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.Data;

@Data
@Entity
public class PageRoute {
    @Id
    private String path;
    private String component;
    private String initialDomain;
}
