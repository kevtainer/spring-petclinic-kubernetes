package org.springframework.samples.petclinic.notifications.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.ArrayList;
import java.util.List;

@RestController
public class SmsResource {

    private final List<SseEmitter> emitters = new ArrayList<>();

    @GetMapping("/sms-messages")
    public SseEmitter sms() {
        SseEmitter emitter = new SseEmitter( 1 * 60 * 1000L );
        emitters.add(emitter);

        emitter.onCompletion(() -> emitters.remove(emitter));

        emitter.onTimeout(() -> emitters.remove(emitter));

        return emitter;
    }

    public List<SseEmitter> getEmitters() {
        return emitters;
    }

    public SseEmitter getLatestEmitter() {
        return (emitters.isEmpty()) ? null : emitters.get(emitters.size()-1);
    }
}
