package com.careconnect.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {
    @SuppressWarnings("SpringJavaInjectionPointsAutowiringInspection")
    @Autowired
    private JavaMailSender mailSender;

    public void sendVerificationEmail(String recipientEmail, String verificationLink) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setTo(recipientEmail);
            helper.setSubject("CareConnect Email Verification");
            helper.setText(
                    "<p>Hello,</p>"
                            + "<p>Thank you for registering with CareConnect.</p>"
                            + "<p>Please click the link below to verify your email address:</p>"
                            + "<p><a href=\"" + verificationLink + "\">VERIFY NOW</a></p>"
                            + "<p>If you did not create an account, you can safely ignore this email.</p>",
                    true
            );

            mailSender.send(message);
            System.out.println("✅ Verification email sent to " + recipientEmail);
        } catch (MessagingException e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to send verification email", e);
        }
    }
}
