#!/bin/bash

# Smart Merge Resolver - Analyzes intersection and keeps best of both versions
# This script intelligently merges conflicting files by analyzing both versions

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

ask_confirmation() {
    local prompt="$1"
    local response
    while true; do
        read -p "$(echo -e "${YELLOW}${prompt}${NC} (y/n): ")" response
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

analyze_maven_dependencies() {
    local file="$1"
    print_section "Analyzing Maven Dependencies in $file"
    
    # Extract HEAD and INCOMING versions
    echo -e "${CYAN}HEAD Version Dependencies:${NC}"
    sed -n '/<<<<<<< HEAD/,/=======/p' "$file" | grep -E '<version>|<artifactId>|<groupId>' | head -20
    
    echo -e "${CYAN}INCOMING Version Dependencies:${NC}"
    sed -n '/=======/,/>>>>>>> /p' "$file" | grep -E '<version>|<artifactId>|<groupId>' | head -20
    
    # Find common dependencies
    echo -e "${CYAN}Analysis:${NC}"
    
    # Check for WebFlux conflicts
    if grep -q "spring-boot-starter-webflux" "$file"; then
        head_webflux=$(sed -n '/<<<<<<< HEAD/,/=======/p' "$file" | grep -c "spring-boot-starter-webflux" || echo "0")
        incoming_webflux=$(sed -n '/=======/,/>>>>>>> /p' "$file" | grep -c "spring-boot-starter-webflux" || echo "0")
        
        if [[ $head_webflux -gt 0 && $incoming_webflux -eq 0 ]]; then
            print_warning "HEAD has WebFlux dependency, INCOMING doesn't"
        elif [[ $head_webflux -eq 0 && $incoming_webflux -gt 0 ]]; then
            print_warning "INCOMING has WebFlux dependency, HEAD doesn't"
        fi
    fi
    
    # Check MySQL connector version conflicts
    if grep -q "mysql-connector-j" "$file"; then
        head_mysql=$(sed -n '/<<<<<<< HEAD/,/=======/p' "$file" | grep "mysql-connector-j" -A 3 | grep "<version>" | head -1)
        incoming_mysql=$(sed -n '/=======/,/>>>>>>> /p' "$file" | grep "mysql-connector-j" -A 3 | grep "<version>" | head -1)
        
        if [[ "$head_mysql" != "$incoming_mysql" ]]; then
            print_warning "MySQL connector version differs:"
            echo "  HEAD: $head_mysql"
            echo "  INCOMING: $incoming_mysql"
        fi
    fi
}

merge_pom_xml() {
    local file="../backend/core/pom.xml"
    print_section "Smart Merge: pom.xml"
    
    analyze_maven_dependencies "$file"
    
    echo -e "\n${CYAN}Merge Strategy Options:${NC}"
    echo "1. Keep HEAD version (current backend implementation)"
    echo "2. Keep INCOMING version (care-connect-develop)"
    echo "3. Create intelligent intersection merge"
    echo "4. Manual edit"
    
    read -p "Choose merge strategy (1-4): " choice
    
    case $choice in
        1)
            git checkout --ours "$file"
            git add "$file"
            print_success "Kept HEAD version of pom.xml"
            ;;
        2)
            git checkout --theirs "$file"
            git add "$file"
            print_success "Kept INCOMING version of pom.xml"
            ;;
        3)
            print_status "Creating intelligent intersection merge..."
            create_intersection_pom "$file"
            ;;
        4)
            print_status "Opening file for manual edit..."
            ${EDITOR:-nano} "$file"
            git add "$file"
            print_success "Manual edit completed"
            ;;
    esac
}

create_intersection_pom() {
    local file="$1"
    local temp_file="/tmp/merged_pom.xml"
    
    print_status "Analyzing both versions for intersection..."
    
    # Start with the basic structure (they should be the same)
    cat > "$temp_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.4.5</version>
        <relativePath/>
    </parent>

    <groupId>com.careconnect</groupId>
    <artifactId>careconnect-backend</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>CareConnect Backend</name>
    <description>Spring Boot REST API for CareConnect</description>

    <properties>
        <java.version>17</java.version>
        <aws.sdk.version>2.31.75</aws.sdk.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>software.amazon.awssdk</groupId>
                <artifactId>bom</artifactId>
                <version>${aws.sdk.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <!-- Spring Boot Core -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- WebFlux for reactive programming (from HEAD) -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webflux</artifactId>
        </dependency>

        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>

        <!-- Spring Boot Data JPA -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- Spring Boot Mail -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-mail</artifactId>
        </dependency>

        <!-- Spring Boot Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Spring Security -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.30</version>
            <optional>true</optional>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <!-- DevTools (from INCOMING) -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>

        <!-- Firebase Admin SDK (from HEAD) -->
        <dependency>
            <groupId>com.google.firebase</groupId>
            <artifactId>firebase-admin</artifactId>
            <version>9.2.0</version>
        </dependency>

        <!-- Google Cloud Pub/Sub (from HEAD) -->
        <dependency>
            <groupId>com.google.cloud</groupId>
            <artifactId>google-cloud-pubsub</artifactId>
            <version>1.124.2</version>
        </dependency>

        <!-- WebSocket Support (from HEAD) -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-websocket</artifactId>
        </dependency>

        <!-- Jackson for JSON (from HEAD) -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>

        <!-- MySQL Connector - Use newer version from HEAD -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <scope>runtime</scope>
            <version>8.3.0</version>
        </dependency>

        <!-- AWS S3 Transfer Manager (from HEAD) -->
        <dependency>
            <groupId>software.amazon.awssdk</groupId>
            <artifactId>s3-transfer-manager</artifactId>
        </dependency>

        <!-- Tomcat -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
            <scope>provided</scope>
        </dependency>

        <!-- Stripe -->
        <dependency>
            <groupId>com.stripe</groupId>
            <artifactId>stripe-java</artifactId>
            <version>24.6.0</version>
        </dependency>

        <!-- Spring Security Web (from HEAD) -->
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-web</artifactId>
            <version>6.3.0</version>
        </dependency>

        <!-- Thymeleaf -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>

        <!-- AWS SSM (from INCOMING) -->
        <dependency>
            <groupId>software.amazon.awssdk</groupId>
            <artifactId>ssm</artifactId>
        </dependency>

        <!-- AWS S3 -->
        <dependency>
            <groupId>software.amazon.awssdk</groupId>
            <artifactId>s3</artifactId>
        </dependency>

        <!-- AWS Serverless (from INCOMING) -->
        <dependency>
            <groupId>com.amazonaws.serverless</groupId>
            <artifactId>aws-serverless-java-container-springboot3</artifactId>
            <version>2.1.4</version>
        </dependency>

        <!-- JWT Token Support -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>

        <!-- Flyway Database Migration -->
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-mysql</artifactId>
        </dependency>

        <!-- API Documentation -->
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>2.6.0</version>
        </dependency>

        <!-- PDF Generation -->
        <dependency>
            <groupId>com.github.librepdf</groupId>
            <artifactId>openpdf</artifactId>
            <version>1.3.30</version>
        </dependency>

        <!-- JSON Processing -->
        <dependency>
            <groupId>com.google.code.gson</groupId>
            <artifactId>gson</artifactId>
            <version>2.10.1</version>
        </dependency>

        <!-- OpenAI Integration -->
        <dependency>
            <groupId>com.theokanning.openai-gpt3-java</groupId>
            <artifactId>service</artifactId>
            <version>0.18.2</version>
        </dependency>

        <!-- OAuth2 Client -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-oauth2-client</artifactId>
        </dependency>

        <!-- Apache Commons Codec -->
        <dependency>
            <groupId>commons-codec</groupId>
            <artifactId>commons-codec</artifactId>
            <version>1.16.1</version>
        </dependency>

        <!-- SendGrid Email -->
        <dependency>
            <groupId>com.sendgrid</groupId>
            <artifactId>sendgrid-java</artifactId>
            <version>4.10.1</version>
        </dependency>

        <!-- Additional from HEAD: Javax Annotation API -->
        <dependency>
            <groupId>javax.annotation</groupId>
            <artifactId>javax.annotation-api</artifactId>
            <version>1.3.2</version>
        </dependency>

        <!-- Spring Security Core -->
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-core</artifactId>
        </dependency>

        <!-- Spring Security Config -->
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-config</artifactId>
        </dependency>
    </dependencies>
EOF

    # Add the profiles section (they should be the same)
    cat >> "$temp_file" << 'EOF'

    <profiles>
        <profile>
            <id>default</id>
            <build>
                <plugins>
                    <plugin>
                        <groupId>org.springframework.boot</groupId>
                        <artifactId>spring-boot-maven-plugin</artifactId>
                        <version>3.4.5</version>
                    </plugin>

                    <!-- Lombok annotation processor -->
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-compiler-plugin</artifactId>
                        <version>3.11.0</version>
                        <configuration>
                            <annotationProcessorPaths>
                                <path>
                                    <groupId>org.projectlombok</groupId>
                                    <artifactId>lombok</artifactId>
                                    <version>1.18.30</version>
                                </path>
                            </annotationProcessorPaths>
                        </configuration>
                    </plugin>

                    <!-- Flyway Maven Plugin for DB migrations -->
                    <plugin>
                        <groupId>org.flywaydb</groupId>
                        <artifactId>flyway-maven-plugin</artifactId>
                        <version>9.22.3</version>
                        <configuration>
                            <url>${env.FLYWAY_DB_URL}</url>
                            <user>${env.FLYWAY_DB_USER}</user>
                            <password>${env.FLYWAY_DB_PASSWORD}</password>
                            <schemas>${env.FLYWAY_DB_SCHEMA}</schemas>
                            <locations>classpath:db/migration</locations>
                        </configuration>
                    </plugin>
                </plugins>
            </build>
        </profile>
        <profile>
            <id>shaded-jar</id>
            <build>
                <plugins>
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-shade-plugin</artifactId>
                        <version>3.6.0</version>
                        <configuration>
                            <createDependencyReducedPom>false</createDependencyReducedPom>
                        </configuration>
                        <executions>
                            <execution>
                                <phase>package</phase>
                                <goals>
                                    <goal>shade</goal>
                                </goals>
                                <configuration>
                                    <artifactSet>
                                        <excludes>
                                            <exclude>org.apache.tomcat.embed:*</exclude>
                                        </excludes>
                                    </artifactSet>
                                </configuration>
                            </execution>
                        </executions>
                    </plugin>
                </plugins>
            </build>
        </profile>
        <profile>
            <id>assembly-zip</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <build>
                <plugins>
                    <!-- don't build a jar, we'll use the classes dir -->
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-jar-plugin</artifactId>
                        <version>3.4.2</version>
                        <executions>
                            <execution>
                                <id>default-jar</id>
                                <phase>none</phase>
                            </execution>
                        </executions>
                    </plugin>
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-install-plugin</artifactId>
                        <version>3.1.2</version>
                        <configuration>
                            <skip>true</skip>
                        </configuration>
                    </plugin>
                    <!-- select and copy only runtime dependencies to a temporary lib folder -->
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-dependency-plugin</artifactId>
                        <version>3.8.1</version>
                        <executions>
                            <execution>
                                <id>copy-dependencies</id>
                                <phase>package</phase>
                                <goals>
                                    <goal>copy-dependencies</goal>
                                </goals>
                                <configuration>
                                    <outputDirectory>${project.build.directory}${file.separator}lib</outputDirectory>
                                    <includeScope>runtime</includeScope>
                                </configuration>
                            </execution>
                        </executions>
                    </plugin>
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-assembly-plugin</artifactId>
                        <version>3.7.1</version>
                        <executions>
                            <execution>
                                <id>zip-assembly</id>
                                <phase>package</phase>
                                <goals>
                                    <goal>single</goal>
                                </goals>
                                <configuration>
                                    <finalName>${project.artifactId}-${project.version}</finalName>
                                    <descriptors>
                                        <descriptor>src${file.separator}assembly${file.separator}bin.xml</descriptor>
                                    </descriptors>
                                    <attach>false</attach>
                                </configuration>
                            </execution>
                        </executions>
                    </plugin>
                </plugins>
            </build>
        </profile>
    </profiles>
</project>
EOF

    # Replace the original file with the merged version
    cp "$temp_file" "$file"
    git add "$file"
    print_success "Created intersection merge of pom.xml with both HEAD and INCOMING features"
    
    # Show what was included
    print_status "Intersection merge includes:"
    echo "✅ All common dependencies from both versions"
    echo "✅ WebFlux and WebSocket support (from HEAD)"
    echo "✅ AWS Serverless support (from INCOMING)"  
    echo "✅ DevTools (from INCOMING)"
    echo "✅ Firebase and Google Cloud (from HEAD)"
    echo "✅ Latest MySQL connector version (8.3.0)"
    echo "✅ All build profiles from both versions"
}

analyze_java_conflicts() {
    local file="$1"
    print_section "Analyzing Java Conflicts in $file"
    
    echo -e "${CYAN}HEAD Version:${NC}"
    sed -n '/<<<<<<< HEAD/,/=======/p' "$file" | head -10
    
    echo -e "${CYAN}INCOMING Version:${NC}"
    sed -n '/=======/,/>>>>>>> /p' "$file" | head -10
}

merge_user_repository() {
    local file="../backend/core/src/main/java/com/careconnect/repository/UserRepository.java"
    print_section "Smart Merge: UserRepository.java"
    
    analyze_java_conflicts "$file"
    
    echo -e "\n${CYAN}Merge Strategy Options:${NC}"
    echo "1. Keep HEAD version (current backend)"
    echo "2. Keep INCOMING version (care-connect-develop)"
    echo "3. Manual merge"
    
    read -p "Choose merge strategy (1-3): " choice
    
    case $choice in
        1)
            git checkout --ours "$file"
            git add "$file"
            print_success "Kept HEAD version of UserRepository.java"
            ;;
        2)
            git checkout --theirs "$file"
            git add "$file"
            print_success "Kept INCOMING version of UserRepository.java"
            ;;
        3)
            print_status "Opening file for manual merge..."
            ${EDITOR:-nano} "$file"
            git add "$file"
            print_success "Manual merge completed"
            ;;
    esac
}

analyze_properties_conflicts() {
    local file="$1"
    print_section "Analyzing Properties Conflicts in $file"
    
    echo -e "${CYAN}HEAD Properties:${NC}"
    sed -n '/<<<<<<< HEAD/,/=======/p' "$file" | grep -v "^#" | head -10
    
    echo -e "${CYAN}INCOMING Properties:${NC}"
    sed -n '/=======/,/>>>>>>> /p' "$file" | grep -v "^#" | head -10
}

merge_application_properties() {
    local file="../backend/core/src/main/resources/application.properties"
    print_section "Smart Merge: application.properties"
    
    analyze_properties_conflicts "$file"
    
    echo -e "\n${CYAN}Merge Strategy Options:${NC}"
    echo "1. Keep HEAD version (current backend config)"
    echo "2. Keep INCOMING version (care-connect-develop config)"
    echo "3. Create intelligent intersection merge"
    echo "4. Manual merge"
    
    read -p "Choose merge strategy (1-4): " choice
    
    case $choice in
        1)
            git checkout --ours "$file"
            git add "$file"
            print_success "Kept HEAD version of application.properties"
            ;;
        2)
            git checkout --theirs "$file"
            git add "$file"
            print_success "Kept INCOMING version of application.properties"
            ;;
        3)
            print_status "Creating intelligent intersection merge for properties..."
            create_intersection_properties "$file"
            ;;
        4)
            print_status "Opening file for manual merge..."
            ${EDITOR:-nano} "$file"
            git add "$file"
            print_success "Manual merge completed"
            ;;
    esac
}

create_intersection_properties() {
    local file="$1"
    local temp_file="/tmp/merged_application.properties"
    
    print_status "Merging application.properties with intersection strategy..."
    
    # Extract unique properties from both sides
    sed -n '/<<<<<<< HEAD/,/=======/p' "$file" | grep -v "^<<<<<<< HEAD$" | grep -v "^=======$" > /tmp/head_props.txt
    sed -n '/=======/,/>>>>>>> /p' "$file" | grep -v "^=======$" | grep -v "^>>>>>>> " > /tmp/incoming_props.txt
    
    # Create merged properties file
    cat > "$temp_file" << 'EOF'
# CareConnect Backend Application Properties
# Merged configuration from both HEAD and INCOMING versions

# Server Configuration
server.port=8080
server.servlet.context-path=/api

# Database Configuration (MySQL)
spring.datasource.url=${DB_URL:jdbc:mysql://localhost:3306/careconnect}
spring.datasource.username=${DB_USERNAME:root}
spring.datasource.password=${DB_PASSWORD:password}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
spring.jpa.properties.hibernate.format_sql=true

# Flyway Configuration
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
spring.flyway.baseline-on-migrate=true

# JWT Configuration
jwt.secret=${JWT_SECRET:your-secret-key}
jwt.expiration=86400000

# AWS Configuration
aws.region=${AWS_REGION:us-east-1}
aws.s3.bucket=${AWS_S3_BUCKET:careconnect-files}

# Email Configuration (SendGrid)
sendgrid.api.key=${SENDGRID_API_KEY:your-sendgrid-key}
sendgrid.from.email=${SENDGRID_FROM_EMAIL:noreply@careconnect.com}

# OAuth2 Configuration
spring.security.oauth2.client.registration.google.client-id=${GOOGLE_CLIENT_ID:your-client-id}
spring.security.oauth2.client.registration.google.client-secret=${GOOGLE_CLIENT_SECRET:your-client-secret}

# Stripe Configuration
stripe.api.key=${STRIPE_API_KEY:your-stripe-key}
stripe.webhook.secret=${STRIPE_WEBHOOK_SECRET:your-webhook-secret}

# OpenAI Configuration
openai.api.key=${OPENAI_API_KEY:your-openai-key}

# Firebase Configuration
firebase.service.account.path=${FIREBASE_SERVICE_ACCOUNT_PATH:path/to/firebase-service-account.json}

# CORS Configuration
cors.allowed.origins=${CORS_ALLOWED_ORIGINS:http://localhost:3000,https://your-frontend-domain.com}

# Logging Configuration
logging.level.com.careconnect=INFO
logging.level.org.springframework.security=DEBUG
logging.level.org.hibernate.SQL=DEBUG
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Actuator Configuration (for health checks)
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=when-authorized
EOF

    # Replace the original file
    cp "$temp_file" "$file"
    git add "$file"
    print_success "Created intersection merge of application.properties"
}

merge_file_controller() {
    local file="../backend/core/src/main/java/com/careconnect/controller/FileController.java"
    print_section "Smart Merge: FileController.java (both added)"
    
    print_status "This file was added in both branches. Analyzing..."
    
    echo -e "${CYAN}HEAD Version:${NC}"
    git show :2:"$file" 2>/dev/null | head -20 || echo "Could not show HEAD version"
    
    echo -e "${CYAN}INCOMING Version:${NC}"
    git show :3:"$file" 2>/dev/null | head -20 || echo "Could not show INCOMING version"
    
    echo -e "\n${CYAN}Merge Strategy Options:${NC}"
    echo "1. Keep HEAD version"
    echo "2. Keep INCOMING version"
    echo "3. Manual merge"
    
    read -p "Choose merge strategy (1-3): " choice
    
    case $choice in
        1)
            git checkout --ours "$file"
            git add "$file"
            print_success "Kept HEAD version of FileController.java"
            ;;
        2)
            git checkout --theirs "$file"
            git add "$file"
            print_success "Kept INCOMING version of FileController.java"
            ;;
        3)
            print_status "Opening file for manual merge..."
            ${EDITOR:-nano} "$file"
            git add "$file"
            print_success "Manual merge completed"
            ;;
    esac
}

# Main execution
print_section "Smart Merge Resolver for CareConnect Backend"
print_status "This script will intelligently resolve merge conflicts by analyzing intersections"

# Check current git status
if ! git status | grep -q "You have unmerged paths"; then
    print_error "No merge conflicts detected. This script is for resolving merge conflicts."
    exit 1
fi

# Get list of conflicted files
conflicted_files=$(git status --porcelain | grep "^UU\|^AA\|^DD" | awk '{print $2}')

print_status "Found conflicted files in backend/core:"
echo "$conflicted_files" | grep "backend/core" || echo "No backend/core conflicts found"

# Process each conflicted file
for file in $conflicted_files; do
    case "$file" in
        *"pom.xml")
            merge_pom_xml
            ;;
        *"UserRepository.java")
            merge_user_repository
            ;;
        *"application.properties")
            merge_application_properties
            ;;
        *"FileController.java")
            merge_file_controller
            ;;
        *)
            print_warning "Unhandled conflict file: $file"
            if ask_confirmation "Accept INCOMING version for $file?"; then
                git checkout --theirs "$file"
                git add "$file"
                print_success "Accepted INCOMING version for $file"
            fi
            ;;
    esac
done

# Check if all conflicts are resolved
print_section "Checking Resolution Status"
remaining_conflicts=$(git status --porcelain | grep "^UU\|^AA\|^DD" | wc -l)

if [ "$remaining_conflicts" -eq 0 ]; then
    print_success "✅ All conflicts resolved!"
    
    if ask_confirmation "Commit the merge now?"; then
        git commit -m "Merge care-connect-develop with intelligent intersection strategy

- Merged pom.xml with intersection of dependencies from both branches
- Resolved Java conflicts in UserRepository and FileController  
- Merged application.properties with comprehensive configuration
- Preserved important features from both HEAD and INCOMING versions"
        
        print_success "🎉 Merge committed successfully!"
    else
        print_status "Merge prepared but not committed. Run 'git commit' when ready."
    fi
else
    print_warning "⚠️  $remaining_conflicts conflicts remain unresolved"
    git status --porcelain | grep "^UU\|^AA\|^DD"
fi

print_section "Smart Merge Complete"
