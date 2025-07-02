// src/main/java/com/careconnectpt/careconnect2025/service/ChatBotService.java
package com.careconnect.service.v2;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;
import java.util.UUID;
import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.chat.ChatCompletionRequest;
import com.theokanning.openai.completion.chat.ChatCompletionResult;
import com.theokanning.openai.completion.chat.ChatMessage;
import com.theokanning.openai.moderation.ModerationRequest;
import com.theokanning.openai.moderation.ModerationResult;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@Service
public class ChatBotService {

    private final OpenAiService ai;
    private final Map<String, List<ChatMessage>> histories = new ConcurrentHashMap<>();

    public ChatBotService(OpenAiService ai) {
        this.ai = ai;
    }

    public String ask(String sessionId, String userInput) {

        /* 0) Moderate incoming message */
//        if (!passesModeration(userInput)) {
//            return "I’m sorry, I can’t help with that.";
//        }

        /* 1) Ensure history exists with the system prompt */
        histories.computeIfAbsent(sessionId, id -> {
            List<ChatMessage> init = new ArrayList<>();
            init.add(new ChatMessage(
                    "system",
                    "You are a compassionate healthcare assistant. "
                  + "Only discuss topics related to patient care: physical health, "
                  + "psychological support, social well-being, spiritual guidance. "
                  + "If asked outside this domain, reply: “I’m sorry, I can’t help with that.”"));
            return init;
        });

        /* 2) Add user message */
        histories.get(sessionId).add(new ChatMessage("user", userInput));

        /* 3) Call ChatCompletion */
        ChatCompletionRequest request = ChatCompletionRequest.builder()
                .model("gpt-4o")                       // or any other model
                .messages(histories.get(sessionId))
                .temperature(0.7)
                .maxTokens(512)
                .build();

        ChatCompletionResult result = ai.createChatCompletion(request);
        String reply = result.getChoices().get(0).getMessage().getContent();

        /* 4) Moderate the assistant reply */
//        if (!passesModeration(reply)) {
//            reply = "I’m sorry, I can’t help with that.";
//        }

        /* 5) Store reply and return it */
        histories.get(sessionId).add(new ChatMessage("assistant", reply));
        return reply;
    }

    /* moderation helper */
//    private boolean passesModeration(String text) {
//
//        // ---------- 1) Fallback for null / blank -----------------
//        if (text == null || text.isBlank()) {
//            text = UUID.randomUUID().toString();   // harmless placeholder
//        }
//
//        // ---------- 2) Build and send the moderation request -----
//        ModerationRequest modReq = ModerationRequest.builder()
//                .input(text)                       // now guaranteed non-null
//                .model("text-moderation-latest")
//                .build();
//
//        ModerationResult res = ai.createModeration(modReq);
//
//        // ---------- 3) Return “not flagged” ----------------------
//        return !res.getResults().getFirst().isFlagged();
//    }
}
