package org.springframework.samples.petclinic.notifications.listener.visit;


import lombok.RequiredArgsConstructor;
import org.apache.kafka.clients.producer.internals.Sender;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.samples.petclinic.VisitRecord;
import org.springframework.samples.petclinic.notifications.client.CustomersServiceClient;
import org.springframework.samples.petclinic.notifications.client.VisitsServiceClient;
import org.springframework.samples.petclinic.notifications.model.OwnerDetails;
import org.springframework.samples.petclinic.notifications.model.PetDetails;
import org.springframework.samples.petclinic.notifications.model.VisitDetails;
import org.springframework.samples.petclinic.notifications.web.SmsResource;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.*;

@Configuration
@EnableKafka
@RequiredArgsConstructor
public class VisitListener {

    private static final Logger LOGGER = LoggerFactory.getLogger(Sender.class);

    private final CustomersServiceClient customersServiceClient;
    private final VisitsServiceClient visitsServiceClient;
    private final SmsResource smsResource;

    @KafkaListener(topics = "create-visit-record", groupId = "group-id")
    public void listener(VisitRecord visit) {
        LOGGER.info("kafka message consumed visit='{}'", visit.toString());

        // fetch pet info
        PetDetails petDetails = customersServiceClient.getPet(visit.ownerId, visit.petId);

        // fetch owner info
        OwnerDetails ownerDetails = customersServiceClient.getOwner(visit.ownerId);

        // fetch visit info
        VisitDetails visitDetails = visitsServiceClient.getVisit(visit.ownerId, visit.petId, visit.visitId);

        SseEmitter latestEm = smsResource.getLatestEmitter();

        try {
            latestEm.send(String.format("Outgoing SMS: %s\n--> Hello %s %s, Thank you for bringing %s the %s to our office on %s." +
                " Our records indicate your visit was regarding: %s. Please contact our office for payment details.",
                ownerDetails.getTelephone(),
                ownerDetails.getFirstName(),
                ownerDetails.getLastName(),
                petDetails.getName(),
                petDetails.getType().getName(),
                visitDetails.getDate(),
                visitDetails.getDescription()));
        } catch (IOException e) {
            latestEm.completeWithError(e);
        }
    }
}
