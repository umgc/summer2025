-- V10__add_tasks_and_templates.sql
-- Add tasks and templates functionality for patients

CREATE TABLE tasks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    patient_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    date TIMESTAMP NOT NULL,
    time_of_day TIME NOT NULL,
    isCompleted BOOLEAN NOT NULL DEFAULT FALSE,
    task_type ENUM('TASK', 'FREQUENCY', 'DAYOFWEEK') NOT NULL,
    frequency TEXT,
    task_interval INT,
    do_count INT,
    days_of_week JSON NOT NULL,
    status ENUM('PENDING', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE templates (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    frequency TEXT,
    task_interval INT,
    do_count INT,
    days_of_week JSON,
    time_of_day TIME,
    icon VARCHAR(255) NOT NULL,
    notifications JSON,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);
