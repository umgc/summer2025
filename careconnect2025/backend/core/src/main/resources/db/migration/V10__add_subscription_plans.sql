-- Insert subscription plans for the application
-- This migration adds two default plans: Standard Plan and Premium Plan

-- Check if the plan table exists, and create it if it doesn't
CREATE TABLE IF NOT EXISTS `plan` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `price_cents` int NOT NULL,
  `billing_period` varchar(20) DEFAULT 'MONTH',
  `is_active` bit(1) DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  CONSTRAINT `plan_chk_1` CHECK ((`price_cents` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Delete any existing plans with the same codes to avoid conflicts
DELETE FROM `plan` WHERE `code` IN ('plan_SbkhH3AATKabKy', 'plan_SbkhIoC5wy5iwB');

-- Insert Standard Plan
INSERT INTO `plan` (`code`, `name`, `price_cents`, `billing_period`, `is_active`) 
VALUES ('plan_SbkhH3AATKabKy', 'Standard Plan', 2000, 'MONTH', b'1');

-- Insert Premium Plan
INSERT INTO `plan` (`code`, `name`, `price_cents`, `billing_period`, `is_active`) 
VALUES ('plan_SbkhIoC5wy5iwB', 'Premium Plan', 3000, 'MONTH', b'1');

-- Insert a mapping for the existing subscription (if price_1RmqWxELoozGI1YxQql5rsvN exists in any subscription)
-- This ensures existing subscriptions with this price ID are linked to the Premium Plan
INSERT IGNORE INTO `plan` (`code`, `name`, `price_cents`, `billing_period`, `is_active`) 
VALUES ('price_1RmqWxELoozGI1YxQql5rsvN', 'Premium Plan', 3000, 'MONTH', b'1');
