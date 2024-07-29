package example.dto;


import com.fasterxml.jackson.annotation.JsonProperty;

public class PatientDto {
    private Long id;
    private String name;
    private String dateOfBirth;
    @JsonProperty("zipcode")
    private String zipcode;
    private String gender;
    private String disease;

    public PatientDto() {}

    public PatientDto(Long anonymizedId, String name, String dateOfBirth, String zipCode, String gender, String disease) {
        this.id = anonymizedId;
        this.name = name;
        this.dateOfBirth = dateOfBirth;
        this.zipcode = zipCode;
        this.gender = gender;
        this.disease = disease;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(String dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getZipCode() {
        return zipcode;
    }

    public void setZipCode(String zipCode) {
        this.zipcode = zipCode;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getDisease() {
        return disease;
    }

    public void setDisease(String disease) {
        this.disease = disease;
    }
}
