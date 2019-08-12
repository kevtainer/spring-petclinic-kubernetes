package org.springframework.samples.petclinic.notifications.model;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class PetDetails {
    private int id;

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getBirthDate() {
        return birthDate;
    }

    public PetType getType() {
        return type;
    }

    private String name;

    private String birthDate;

    private PetType type;

    private final List<VisitDetails> visits = new ArrayList<>();

}
