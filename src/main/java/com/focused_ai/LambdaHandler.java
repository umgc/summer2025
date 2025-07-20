package com.focused_ai;

import com.amazonaws.serverless.proxy.spring.SpringBootLambdaContainerHandler;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class LambdaHandler implements RequestStreamHandler {

    private static SpringBootLambdaContainerHandler<AwsProxyRequest, AwsProxyResponse> handler;

    static {
        try {
            System.out.println("=== INITIALIZING LAMBDA HANDLER ===");
            handler = SpringBootLambdaContainerHandler.getAwsProxyHandler(FocusEdAIApplication.class);
            System.out.println("=== LAMBDA HANDLER INITIALIZED SUCCESSFULLY ===");
        } catch (Exception e) {
            System.err.println("=== LAMBDA HANDLER INITIALIZATION FAILED ===");
            e.printStackTrace();
            throw new RuntimeException("Could not initialize Spring Boot application", e);
        }
    }

    @Override
    public void handleRequest(InputStream inputStream, OutputStream outputStream, Context context) throws IOException {
        System.out.println("=== LAMBDA HANDLER RECEIVED REQUEST ===");
        handler.proxyStream(inputStream, outputStream, context);
        System.out.println("=== LAMBDA HANDLER COMPLETED REQUEST ===");
    }
}