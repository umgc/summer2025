package com.careconnect.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class FileUploadResponse {
    private Long fileId;
    private String filename;
    private String originalFilename;
    private String fileUrl;
    private String contentType;
    private Long fileSize;
    private String category;
    private LocalDateTime uploadedAt;
    private String message;
}
