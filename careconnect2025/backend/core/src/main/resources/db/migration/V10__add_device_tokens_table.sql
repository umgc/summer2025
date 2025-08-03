-- V14: Add device tokens table for Firebase FCM
CREATE TABLE device_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    fcm_token VARCHAR(500) NOT NULL,
    device_type ENUM('ANDROID', 'IOS', 'WEB') NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL,
    last_used_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_fcm_token (fcm_token),
    INDEX idx_device_id (device_id),
    UNIQUE KEY uk_user_device (user_id, device_id)
);
