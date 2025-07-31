package com.careconnect.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class UserFileDTO {
    private Long id;
    private String s3FullKey;
    private String filename;
    private String originalFilename;
    private String contentType;
    private Long fileSize;
    private String fileUrl;
    private Long ownerId;
    private String ownerType;
    private String fileCategory;
    private Long patientId;
    private String storageType;
    private String description;
    private LocalDateTime uploadedAt;
    private LocalDateTime updatedAt;
}
