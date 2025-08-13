-- Remove Spring Session tables as we've migrated to JWT-only authentication
-- This migration safely removes session-based authentication tables

-- First, disable foreign key checks to avoid dependency issues
SET FOREIGN_KEY_CHECKS = 0;

-- Drop Spring Session tables if they exist
DROP TABLE IF EXISTS SPRING_SESSION_ATTRIBUTES;
DROP TABLE IF EXISTS SPRING_SESSION;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
