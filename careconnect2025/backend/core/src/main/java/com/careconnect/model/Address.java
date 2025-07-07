package com.careconnect.model;

import jakarta.persistence.Embeddable;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Embeddable
public class Address {
    private String line1;
    private String line2;
    private String city;
    private String state;
    private String zip;
}