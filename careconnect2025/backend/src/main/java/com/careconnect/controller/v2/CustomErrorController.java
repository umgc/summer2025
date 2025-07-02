package com.careconnect.controller.v2;

import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@Controller
public class CustomErrorController implements ErrorController {
    @RequestMapping("/error")
    public String handleError() {
        return "errorPage"; 
    }

    public String getErrorPath() {
        return "/error";
    }
}
