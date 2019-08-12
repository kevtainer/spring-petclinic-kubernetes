package org.springframework.samples.petclinic.notifications.model;
import lombok.Data;

@Data
public class VisitDetails {
    private int id;

    private int petId;

    private String date;

    public int getId() {
        return id;
    }

    public int getPetId() {
        return petId;
    }

    public String getDate() {
        return date;
    }

    public String getDescription() {
        return description;
    }

    private String description;
}
