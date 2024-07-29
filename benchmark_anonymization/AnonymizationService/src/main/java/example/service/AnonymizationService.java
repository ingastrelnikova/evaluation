import example.dto.PatientDto;
import example.dto.AnonymizedPatientDto;
import example.entity.AnonymizedPatient;
import example.repository.AnonymizedPatientRepository;
import org.deidentifier.arx.*;
import org.deidentifier.arx.aggregates.HierarchyBuilderRedactionBased;
import org.deidentifier.arx.criteria.KAnonymity;
import org.deidentifier.arx.Data.DefaultData;
import org.deidentifier.arx.aggregates.HierarchyBuilderDate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

@Service
public class AnonymizationService {

    @Autowired
    private AnonymizedPatientRepository anonymizedPatientRepository;

    private static final String LOG_CSV_PATH = "anonymization_log.csv";

    @Transactional
    public void deletePatientsByIds(List<Long> patientIds) {
        patientIds.forEach(id -> {
            Optional<AnonymizedPatient> patient = anonymizedPatientRepository.findById(id);
            if (patient.isPresent()) {
                anonymizedPatientRepository.delete(patient.get());
            }
        });
    }

    public List<AnonymizedPatientDto> anonymizePatients(List<PatientDto> patients) {
        return anonymizePatients(patients, 4);
    }

    public List<AnonymizedPatientDto> anonymizePatients(List<PatientDto> patients, int k) {
        int recordCount = patients.size();
        DefaultData data = createDataFromPatients(patients);
        ARXAnonymizer anonymizer = new ARXAnonymizer();
        ARXConfiguration config = ARXConfiguration.create();
        config.addPrivacyModel(new KAnonymity(k));
        config.setSuppressionLimit(0d);

        long startAnonymizationTime = System.currentTimeMillis();

        try {
            ARXResult result = anonymizer.anonymize(data, config);
            DataHandle handle = result.getOutput(false);

            long endAnonymizationTime = System.currentTimeMillis();
            long anonymizationLatency = endAnonymizationTime - startAnonymizationTime;

            if (handle == null) {
                logLatency(anonymizationLatency, recordCount, "anonymization");
                return new ArrayList<>();
            }

            List<AnonymizedPatientDto> anonymizedPatients = createAnonymizedPatientsList(handle);

            long startSavingTime = System.currentTimeMillis();

            saveAnonymizedPatients(anonymizedPatients);

            long endSavingTime = System.currentTimeMillis();
            long savingLatency = endSavingTime - startSavingTime;

            logLatency(anonymizationLatency, recordCount, "anonymization");
            logLatency(savingLatency, recordCount, "saving");

            return anonymizedPatients;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private DefaultData createDataFromPatients(List<PatientDto> patients) {
        DefaultData data = Data.create();
        data.add("id", "name", "dateOfBirth", "gender", "zipcode", "disease");

        patients.forEach(patient -> {
            data.add(patient.getId().toString(), patient.getName(), patient.getDateOfBirth(), patient.getGender(),
                    patient.getZipCode(), patient.getDisease());
        });

        data.getDefinition().setAttributeType("id", AttributeType.INSENSITIVE_ATTRIBUTE);
        data.getDefinition().setAttributeType("name", AttributeType.IDENTIFYING_ATTRIBUTE);
        data.getDefinition().setAttributeType("disease", AttributeType.INSENSITIVE_ATTRIBUTE);
        data.getDefinition().setAttributeType("gender", AttributeType.INSENSITIVE_ATTRIBUTE);

        HierarchyBuilderDate dateHierarchy = getDateOfBirthHierarchy();
        if (dateHierarchy != null) {
            data.getDefinition().setAttributeType("dateOfBirth", dateHierarchy);
        } else {
            data.getDefinition().setAttributeType("dateOfBirth", AttributeType.QUASI_IDENTIFYING_ATTRIBUTE);
        }

        HierarchyBuilderRedactionBased<String> zipCodeHierarchy = getZipCodeHierarchy();
        data.getDefinition().setAttributeType("zipcode", zipCodeHierarchy);

        return data;
    }

    private HierarchyBuilderDate getDateOfBirthHierarchy() {
        try {
            String stringDateFormat = "yyyy-MM-dd";
            DataType<Date> dateType = DataType.createDate(stringDateFormat);

            HierarchyBuilderDate builder = HierarchyBuilderDate.create(dateType);
            builder.setGranularities(new HierarchyBuilderDate.Granularity[]{
                    HierarchyBuilderDate.Granularity.DAY_MONTH_YEAR,
                    HierarchyBuilderDate.Granularity.MONTH_YEAR,
                    HierarchyBuilderDate.Granularity.QUARTER_YEAR,
                    HierarchyBuilderDate.Granularity.YEAR,
                    HierarchyBuilderDate.Granularity.DECADE,
                    HierarchyBuilderDate.Granularity.CENTURY,
                    HierarchyBuilderDate.Granularity.MILLENNIUM
            });
            return builder;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private HierarchyBuilderRedactionBased<String> getZipCodeHierarchy() {
        return HierarchyBuilderRedactionBased.create(
                HierarchyBuilderRedactionBased.Order.RIGHT_TO_LEFT,
                HierarchyBuilderRedactionBased.Order.RIGHT_TO_LEFT,
                ' ',
                '*');
    }

    private List<AnonymizedPatientDto> createAnonymizedPatientsList(DataHandle handle) {
        List<AnonymizedPatientDto> result = new ArrayList<>();
        for (int i = 0; i < handle.getNumRows(); i++) {
            result.add(new AnonymizedPatientDto(
                    Long.parseLong(handle.getValue(i, 0)),
                    handle.getValue(i, 1),
                    handle.getValue(i, 2),
                    handle.getValue(i, 4),
                    handle.getValue(i, 3),
                    handle.getValue(i, 5)
            ));
        }
        return result;
    }

    @Transactional
    public void saveAnonymizedPatients(List<AnonymizedPatientDto> anonymizedPatientDtos) {
        List<AnonymizedPatient> anonymizedPatients = new ArrayList<>();
        for (AnonymizedPatientDto dto : anonymizedPatientDtos) {
            AnonymizedPatient anonymizedPatient = new AnonymizedPatient();
            anonymizedPatient.setAnonymizedId(dto.getAnonymizedId());
            anonymizedPatient.setAnonymizedName(dto.getAnonymizedName());
            anonymizedPatient.setAnonymizedDateOfBirth(dto.getAnonymizedDateOfBirth());
            anonymizedPatient.setZipCode(dto.getZipCode());
            anonymizedPatient.setGender(dto.getGender());
            anonymizedPatient.setDisease(dto.getDisease());

            // check patient with id and update if there
            Optional<AnonymizedPatient> existingPatient = anonymizedPatientRepository.findById(dto.getAnonymizedId());
            if (existingPatient.isPresent()) {
                AnonymizedPatient existing = existingPatient.get();
                existing.setAnonymizedName(dto.getAnonymizedName());
                existing.setAnonymizedDateOfBirth(dto.getAnonymizedDateOfBirth());
                existing.setZipCode(dto.getZipCode());
                existing.setGender(dto.getGender());
                existing.setDisease(dto.getDisease());
                anonymizedPatients.add(existing);
            } else {
                anonymizedPatients.add(anonymizedPatient);
            }
        }
        anonymizedPatientRepository.saveAll(anonymizedPatients);
    }

    private void logLatency(long latency, int recordCount, String operation) {
        try (FileWriter writer = new FileWriter(LOG_CSV_PATH, true)) {
            writer.append(String.join(",", Arrays.asList(
                    Long.toString(System.currentTimeMillis()),
                    operation,
                    Long.toString(latency),
                    Integer.toString(recordCount)
            )));
            writer.append("\n");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
