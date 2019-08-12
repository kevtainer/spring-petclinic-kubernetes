package org.springframework.samples.petclinic;

public  class  VisitRecord {
    public Integer  petId;
    public Integer ownerId;
    public Integer visitId;

    public VisitRecord() {}

    public VisitRecord(Integer petId, Integer ownerId, Integer visitId) {
        this.petId = petId;
        this.ownerId = ownerId;
        this.visitId = visitId;
    }

    public Integer getPetId() {
        return this.petId;
    }

    public Integer getOwnerId() {
        return this.ownerId;
    }

    public Integer getVisitId() { return this.visitId; }

    public void setPetId(Integer petId) {
        this.petId = petId;
    }

    /**
     * @param ownerId the ownerId to set
     */
    public void setOwnerId(Integer ownerId) {
        this.ownerId = ownerId;
    }

    @Override
    public String toString() {
        return "VisitCreation{" +
            "petId='"+ petId + '\'' +
            ", ownerId='"+ ownerId + '\'' +
            ", visitId='"+ visitId + '\'' +
            '}';
    }
}

