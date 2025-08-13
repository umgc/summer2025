package com.careconnect.controller;

import com.careconnect.model.Message;
import com.careconnect.model.User;
import com.careconnect.dto.InboxMessageDto;
import com.careconnect.repository.MessageRepository;
import com.careconnect.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/v1/api/messages")
public class MessageController {

    @Autowired
    private MessageRepository messageRepo;

    @Autowired
    private UserRepository userRepo;

    // ✅ Send a new message
    @PostMapping("/send")
    public ResponseEntity<Message> sendMessage(@RequestBody Message message) {
        message.setTimestamp(LocalDateTime.now());
        message.setRead(false);
        Message saved = messageRepo.save(message);
        return ResponseEntity.ok(saved);
    }

    // ✅ Fetch full conversation between two users
    @GetMapping("/conversation")
    public ResponseEntity<List<Message>> getConversation(
            @RequestParam Long user1,
            @RequestParam Long user2
    ) {
        List<Message> conversation = messageRepo.findConversation(user1, user2);
        return ResponseEntity.ok(conversation);
    }

    // ✅ Inbox view: list all recent conversations with peer info
    @GetMapping("/inbox/{userId}")
    public ResponseEntity<List<InboxMessageDto>> getInbox(@PathVariable Long userId) {
        List<Message> messages = messageRepo.findAllUserMessages(userId);
        Map<Long, InboxMessageDto> map = new LinkedHashMap<>(); // keep order

        for (Message m : messages) {
            Long peerId = m.getSenderId().equals(userId) ? m.getReceiverId() : m.getSenderId();
            if (map.containsKey(peerId)) continue; // already got latest from this peer

            Optional<User> peer = userRepo.findById(peerId);
            if (peer.isPresent()) {
                User u = peer.get();
                InboxMessageDto dto = new InboxMessageDto(
                        m.getId(),
                        peerId,
                        u.getName(),
                        u.getEmail(),
                        m.getContent(),
                        m.getTimestamp()
                );
                map.put(peerId, dto);
            }
        }

        return ResponseEntity.ok(new ArrayList<>(map.values()));
    }
}