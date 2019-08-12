package org.springframework.samples.petclinic.notifications.model;

import lombok.Data;

@Data
public class PetType {
    public String getName() {
        return name;
    }

    private String name;
}
