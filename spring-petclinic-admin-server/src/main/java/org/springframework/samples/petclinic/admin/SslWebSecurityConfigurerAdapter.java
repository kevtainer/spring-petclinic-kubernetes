//package org.springframework.samples.petclinic.admin;
//
//import org.springframework.context.annotation.Configuration;
//import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//
//@Configuration()
//public class SslWebSecurityConfigurerAdapter extends WebSecurityConfigurerAdapter {
//
//    @Override
//    protected void configure(HttpSecurity http) throws Exception {
//        // Customize the application security
//        http.requiresChannel().anyRequest().requiresSecure();
//    }
//
//}