package com.careconnect.controller;
import com.careconnect.model.Template;
import com.careconnect.dto.TemplateDto;
import com.careconnect.service.TemplateService;

import jakarta.servlet.http.HttpServletRequest;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;


@RestController
@RequestMapping("/v1/api/templates")
public class TemplateController {
    @Autowired
    private TemplateService templateService;

    @GetMapping("{templateId}")
    public ResponseEntity<Template> getTemplateById(
            @PathVariable Long templateId,
            HttpServletRequest request) {

        Template template = templateService.getTemplateById(templateId);
        if (template != null) {
            return ResponseEntity.ok(template);
        }
        return ResponseEntity.notFound().build();
    }

    // @GetMapping("/patient/{patientId}")
    // public ResponseEntity<List<Template>> getTemplatesByPatientId(
    //         @PathVariable Long patientId,
    //         HttpServletRequest request) {

    //     List<Template> templates = templateService.getTemplatesByPatientId(patientId);
    //     if (templates != null && !templates.isEmpty()) {
    //         return ResponseEntity.ok(templates);
    //     }
    //     return ResponseEntity.notFound().build();
    // }

    @GetMapping("all")
    public ResponseEntity<List<Template>> getAllTemplates(HttpServletRequest request) {

        List<Template> templates = templateService.getAllTemplates();
        if (templates != null && !templates.isEmpty()) {
            return ResponseEntity.ok(templates);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{templateId}")
    public ResponseEntity<Template> updateTemplate(
            @PathVariable Long templateId,
            @RequestBody TemplateDto template,
            HttpServletRequest request) {
        Template updatedTemplate = templateService.updateTemplate(templateId, template);
        if (updatedTemplate != null) {
            return ResponseEntity.ok(updatedTemplate);
        }
        return ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{templateId}")
    public ResponseEntity<Void> deleteTemplate(
            @PathVariable Long templateId,
            HttpServletRequest request) {
        boolean deleted = templateService.deleteTemplate(templateId);
        if (deleted) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}