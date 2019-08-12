package org.springframework.samples.petclinic.notifications.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

import static java.util.stream.Collectors.toList;

@Data
public class OwnerDetails {

    private int id;

    private String firstName;

    private String lastName;

    private String address;

    private String city;

    private String telephone;

    private String email;

    private final List<PetDetails> pets = new ArrayList<>();

    public int getId() {
        return id;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public String getAddress() {
        return address;
    }

    public String getCity() {
        return city;
    }

    public String getTelephone() {
        return telephone;
    }

    public String getEmail() {
        return email;
    }

    @JsonIgnore
    public List<Integer> getPetIds() {
        return pets.stream()
            .map(PetDetails::getId)
            .collect(toList());
    }
}
