/*
 * Copyright 2002-2017 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.owners.client;

import lombok.RequiredArgsConstructor;
import org.springframework.cloud.netflix.ribbon.RibbonClient;
import org.springframework.samples.petclinic.owners.model.OwnerDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
@RequiredArgsConstructor
@RibbonClient(name = "customers-service")
public class CustomersServiceClient {

    private final RestTemplate loadBalancedRestTemplate;

    public OwnerDetails getOwner(final int ownerId) {
        return loadBalancedRestTemplate.getForObject("http://customers-service:8080/owners/{ownerId}", OwnerDetails.class, ownerId);
    }
}
