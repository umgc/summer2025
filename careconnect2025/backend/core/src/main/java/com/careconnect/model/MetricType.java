package com.careconnect.model;

public enum MetricType {
    HEART_RATE,          // bpm
    SPO2,                // %
    BLOOD_PRESSURE_SYS,  // mmHg
    BLOOD_PRESSURE_DIA,  // mmHg
    WEIGHT               // kg (or lb if you store units separately)
}