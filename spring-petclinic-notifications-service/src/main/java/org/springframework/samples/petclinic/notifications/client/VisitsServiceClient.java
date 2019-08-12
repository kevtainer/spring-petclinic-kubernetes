package org.springframework.samples.petclinic.notifications.client;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.netflix.ribbon.RibbonClient;
import org.springframework.samples.petclinic.notifications.model.VisitDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.io.OutputStream;

@Component
@RequiredArgsConstructor
@RibbonClient(name = "visits-service")
public class VisitsServiceClient {
    @Value("${visits-service.url}")
    private String visitsServiceUrl;

    private final RestTemplate loadBalancedRestTemplate;

    public VisitDetails getVisit(final int ownerId, final int petId, final int visitId) {
        return loadBalancedRestTemplate.getForObject(visitsServiceUrl + "/owners/{ownerId}/pets/{petId}/visits/{visitId}", VisitDetails.class, ownerId, petId, visitId);
    }
}
