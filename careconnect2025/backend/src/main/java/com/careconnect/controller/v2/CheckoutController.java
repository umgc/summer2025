package com.careconnect.controller.v2;

import java.util.Map;
import com.careconnect.service.v2.StripeCheckoutService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Profile;


@Profile("v2")
@RestController
@RequestMapping("/v2/api/checkout")
public class CheckoutController {

    private final StripeCheckoutService checkoutService;

    public CheckoutController(StripeCheckoutService checkoutService) {
        this.checkoutService = checkoutService;
    }

@PostMapping("/create")
public ResponseEntity<?> createCheckoutSession(
        HttpServletRequest request,
        @RequestParam String plan,
        @RequestParam Long userId) {
    try {
        String domain = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort();
        long amount = switch (plan.toLowerCase()) {
            case "premium" -> 3000L;
            case "standard" -> 2000L;
            default -> throw new IllegalArgumentException("Invalid plan");
        };

        Session session = checkoutService.createCheckoutSession(plan, amount,
            domain + "/payment-success.html",
            domain + "/payment-cancel.html");

        checkoutService.saveCheckoutSession(userId, plan, amount, session);

        return ResponseEntity.ok(Map.of("checkoutUrl", session.getUrl()));
    } catch (Exception e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
    }
}
}
