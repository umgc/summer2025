package com.careconnect.service;

import com.careconnect.model.Template;
import com.careconnect.repository.TemplateRepository;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.careconnect.dto.TemplateDto;
import com.careconnect.exception.AppException;

@Service
@Transactional
public class TemplateService {

    @Autowired
    private TemplateRepository templateRepository;

    public Template getTemplateById(Long templateId) {
        return templateRepository.findById(templateId)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "Template not found"));
    }

    // public List<Template> getTemplatesByPatientId(Long patientId) {
    //     Optional<List<Template>> templatesOpt = templateRepository.findByPatientId(patientId);
    //     if (templatesOpt.isPresent()) {
    //         return templatesOpt.get();
    //     } else {
    //         throw new AppException(HttpStatus.NOT_FOUND, "Templates not found for patient");
    //     }
    // }

    public List<Template> getAllTemplates() {
        List<Template> templatesOpt = templateRepository.findAll();
        if (!templatesOpt.isEmpty()) {
            return templatesOpt;
        } else {
            throw new AppException(HttpStatus.NOT_FOUND, "No templates found");
        }
    }

    public Template updateTemplate(Long templateId, TemplateDto templateDto) {
        Template templateOpt = templateRepository.findById(templateId)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "Template not found"));
        // Update template fields with values from templateDto
        templateOpt.setName(templateDto.getName());
        templateOpt.setDescription(templateDto.getDescription());
        templateOpt.setFrequency(templateDto.getFrequency());
        templateOpt.setTaskInterval(templateDto.getInterval());
        templateOpt.setDoCount(templateDto.getCount());
        templateOpt.setDaysOfWeek(templateDto.getDaysOfWeek());
        templateOpt.setTimeOfDay(templateDto.getTimeOfDay());
        templateOpt.setIcon(templateDto.getIcon());
        templateOpt.setNotifications(templateDto.getNotifications());
        return templateRepository.save(templateOpt);
    }

    public boolean deleteTemplate(Long templateId) {
        Optional<Template> templateOpt = templateRepository.findById(templateId);
        if (templateOpt.isPresent()) {
            templateRepository.delete(templateOpt.get());
            return true;
        } else {
            throw new AppException(HttpStatus.NOT_FOUND, "Template not found");
        }
    }
}
