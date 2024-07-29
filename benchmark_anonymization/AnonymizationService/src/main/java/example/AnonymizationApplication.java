package example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = {"example.config", "example.service", "example.controller", "example.repository"})
@EnableFeignClients
public class AnonymizationApplication {
    public static void main(String[] args) {
        SpringApplication.run(AnonymizationApplication.class, args);
    }
}
