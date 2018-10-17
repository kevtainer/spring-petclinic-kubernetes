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
package org.springframework.samples.petclinic.visits.web;

import io.micrometer.core.instrument.MeterRegistry;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.samples.petclinic.VisitRecord;
import org.springframework.samples.petclinic.visits.model.Visit;
import org.springframework.samples.petclinic.visits.model.VisitRepository;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;
import java.util.Optional;

@RestController
@Slf4j
public class VisitResource {
    private final VisitRepository visitRepository;
    private final MeterRegistry registry;

    public VisitResource(VisitRepository visitRepository, MeterRegistry registry) {
        this.visitRepository = visitRepository;
        this.registry = registry;
    }

    @Autowired
    private KafkaTemplate<String, VisitRecord> kafkaTemplate;

    @PostMapping("owners/{ownerId}/pets/{petId}/visits")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void create(
        @Valid @RequestBody Visit visit,
        @PathVariable("petId") int petId,
        @PathVariable("ownerId") int ownerId) {

        visit.setPetId(petId);
        log.info("Saving visit {}", visit);

        Visit savedVisit = visitRepository.save(visit);
        registry.counter("create.visit").increment();

        VisitRecord visitRecord = new VisitRecord(petId, ownerId, savedVisit.getId());
        kafkaTemplate.send("create-visit-record", visitRecord);
    }

    @GetMapping("owners/*/pets/*/visits/{visitId}")
    public Optional<Visit> visit(@PathVariable("visitId") int visitId) {
        return visitRepository.findById(visitId);
    }

    @GetMapping("owners/*/pets/{petId}/visits")
    public List<Visit> visits(@PathVariable("petId") int petId) {
        return visitRepository.findByPetId(petId);
    }
}
