package com.careconnect.model.v2;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;

/** Mapped superclass for audit fields */
@MappedSuperclass @Getter @Setter
public abstract class Auditable {

    @CreationTimestamp    // insert-time
    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @UpdateTimestamp      // last modified
    @Column(name = "updated_at")
    private Instant updatedAt;
}