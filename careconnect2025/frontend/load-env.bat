@echo off
REM ================================
REM CareConnect Backend Environment Loader (Windows)
REM ================================

echo Loading CareConnect environment variables...

REM Check if .env file exists
if not exist ".env" (
    echo Error: .env file not found in current directory
    echo Please create a .env file based on the provided template
    exit /b 1
)

REM Load environment variables from .env file
for /f "usebackq tokens=1* delims==" %%a in (".env") do (
    if not "%%a"=="" (
        if not "%%a"=="%%a:#=%" (
            REM Skip comment lines
        ) else (
            set "%%a=%%b"
        )
    )
)

echo Environment variables loaded successfully!

REM Verify critical variables are set
set "missing_vars="
if "%JDBC_URI%"=="" set "missing_vars=%missing_vars% JDBC_URI"
if "%DB_USER%"=="" set "missing_vars=%missing_vars% DB_USER"
if "%DB_PASSWORD%"=="" set "missing_vars=%missing_vars% DB_PASSWORD"
if "%SECURITY_JWT_SECRET%"=="" set "missing_vars=%missing_vars% SECURITY_JWT_SECRET"
if "%FIREBASE_PROJECT_ID%"=="" set "missing_vars=%missing_vars% FIREBASE_PROJECT_ID"
if "%FIREBASE_SENDER_ID%"=="" set "missing_vars=%missing_vars% FIREBASE_SENDER_ID"

if not "%missing_vars%"=="" (
    echo Warning: The following critical environment variables are not set:
    echo %missing_vars%
    echo Please update your .env file with the required values
    echo Please set the missing environment variables before starting the application
    exit /b 1
) else (
    echo Starting CareConnect Backend...
    REM Execute the passed command with loaded environment
    %*
)
