
package com.careconnect.service;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PatientContextRetrievalService {
    private final List<String> contextSegments = new ArrayList<>();

    public PatientContextRetrievalService() {
        // No embedding model needed for generic interface
    }

    public void indexPatientContext(Long patientId, String context) {
        // Split context into segments and store
        contextSegments.clear();
        for (String segment : context.split("\n")) {
            if (!segment.trim().isEmpty()) {
                contextSegments.add(segment.trim());
            }
        }
    }
    public List<String> retrieveRelevantContext(String query, int topK) {
        // Simple keyword-based retrieval for demonstration
        return contextSegments.stream()
                .filter(segment -> segment.toLowerCase().contains(query.toLowerCase()))
                .limit(topK)
                .collect(Collectors.toList());
    }
}
