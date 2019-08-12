package org.springframework.samples.petclinic.notifications.client;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.netflix.ribbon.RibbonClient;
import org.springframework.samples.petclinic.notifications.model.OwnerDetails;
import org.springframework.samples.petclinic.notifications.model.PetDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
@RequiredArgsConstructor
@RibbonClient(name = "customers-service")
public class CustomersServiceClient {
    @Value("${customers-service.url}")
    private String customersServiceUrl;

    private final RestTemplate loadBalancedRestTemplate;

    public OwnerDetails getOwner(final int ownerId) {
        return loadBalancedRestTemplate.getForObject(customersServiceUrl + "/owners/{ownerId}", OwnerDetails.class, ownerId);
    }

    public PetDetails getPet(final int ownerId, final int petId) {
        return loadBalancedRestTemplate.getForObject(customersServiceUrl + "/owners/{ownerId}/pets/{petId}", PetDetails.class, ownerId, petId);
    }
}
