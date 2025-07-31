package com.careconnect.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UploadedFileDTO {
    private String filename;
    private String content; // Base64 or plain text, depending on frontend
    private String contentType;
}
