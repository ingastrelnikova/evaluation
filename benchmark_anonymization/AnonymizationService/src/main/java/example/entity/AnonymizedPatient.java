package example.entity;

import javax.persistence.*;

@Entity
@Table(name = "anonymized_patients")
public class AnonymizedPatient {

    @Id
    private Long anonymizedId;
    private String anonymizedName;
    private String anonymizedDateOfBirth;
    private String zipCode;
    private String gender;
    private String disease;

    public void setAnonymizedId(Long anonymizedId) {
        this.anonymizedId = anonymizedId;
    }
    public void setAnonymizedName(String anonymizedName) {
        this.anonymizedName = anonymizedName;
    }
    public void setAnonymizedDateOfBirth(String anonymizedDateOfBirth) {
        this.anonymizedDateOfBirth = anonymizedDateOfBirth;
    }
    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }
    public void setGender(String gender) {
        this.gender = gender;
    }
    public void setDisease(String disease) {
        this.disease = disease;
    }
}
