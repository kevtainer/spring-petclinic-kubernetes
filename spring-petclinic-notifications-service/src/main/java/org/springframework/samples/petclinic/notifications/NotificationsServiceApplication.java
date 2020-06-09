package org.springframework.samples.petclinic.notifications;

import io.jaegertracing.Configuration;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
public class NotificationsServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(NotificationsServiceApplication.class, args);
    }

    @Bean
    @LoadBalanced
    RestTemplate loadBalancedRestTemplate() {
        return new RestTemplate();
    }

	@Bean
    @Profile("jaegertracing")
    public io.opentracing.Tracer getTracer() {
        return Configuration.fromEnv().getTracer();
    }
}
