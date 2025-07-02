package com.careconnect.dto.v2;

import lombok.Builder;

import java.time.Instant;
import java.util.List;

/** Signed export link */
@Builder
public record ExportLinkDTO(
    String url,          // presigned URL (valid 1h)
    Instant expiresAt
) {}