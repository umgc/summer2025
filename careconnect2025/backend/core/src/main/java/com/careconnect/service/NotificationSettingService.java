package com.careconnect.service;

import com.careconnect.dto.NotificationSettingDTO;
import com.careconnect.model.NotificationSetting;
import com.careconnect.repository.NotificationSettingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class NotificationSettingService {
    private final NotificationSettingRepository notificationSettingRepository;

    public NotificationSettingDTO getByUserId(Long userId) {
        NotificationSetting setting = notificationSettingRepository.findByUserId(userId)
                .orElseGet(() -> notificationSettingRepository.save(
                        NotificationSetting.builder()
                                .userId(userId)
                                .build()
                ));
        return toDTO(setting);
    }

    @Transactional
    public NotificationSettingDTO createOrUpdate(NotificationSettingDTO dto) {
        NotificationSetting setting = notificationSettingRepository.findByUserId(dto.userId())
                .orElse(NotificationSetting.builder().userId(dto.userId()).build());
        setting.setGamification(dto.gamification());
        setting.setEmergency(dto.emergency());
        setting.setVideoCall(dto.videoCall());
        setting.setAudioCall(dto.audioCall());
        setting.setSms(dto.sms());
        setting.setSignificantVitals(dto.significantVitals());
        NotificationSetting saved = notificationSettingRepository.save(setting);
        return toDTO(saved);
    }

    private NotificationSettingDTO toDTO(NotificationSetting setting) {
        return NotificationSettingDTO.builder()
                .id(setting.getId())
                .userId(setting.getUserId())
                .gamification(setting.isGamification())
                .emergency(setting.isEmergency())
                .videoCall(setting.isVideoCall())
                .audioCall(setting.isAudioCall())
                .sms(setting.isSms())
                .significantVitals(setting.isSignificantVitals())
                .createdAt(setting.getCreatedAt())
                .updatedAt(setting.getUpdatedAt())
                .build();
    }
}
