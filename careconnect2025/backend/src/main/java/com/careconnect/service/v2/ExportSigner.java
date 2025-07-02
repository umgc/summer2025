package com.careconnect.service.v2;

import java.time.Duration;
import java.time.Instant;

import org.springframework.stereotype.Service;

import com.careconnect.dto.v2.ExportLinkDTO;

import lombok.RequiredArgsConstructor;

import org.springframework.context.annotation.Profile;

@Profile("v2")
@Service
@RequiredArgsConstructor
public class ExportSigner {

    private static final Duration TTL = Duration.ofHours(1);

    public ExportLinkDTO sign(String relativePath) {
        String url = "https://files.careconnect.ai" + relativePath + "?sig=mock123"; // TODO real signer
        return ExportLinkDTO.builder()
                .url(url)
                .expiresAt(Instant.now().plus(TTL))
                .build();
    }
}