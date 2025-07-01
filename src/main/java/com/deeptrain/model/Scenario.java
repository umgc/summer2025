package com.deeptrain.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "scenarios")
@Data
public class Scenario {

    @Id
    private String id;
    private String domain;
    private String contentJson;
}
