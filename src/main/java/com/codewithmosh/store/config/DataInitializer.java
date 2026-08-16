package com.codewithmosh.store.config;

import com.codewithmosh.store.entities.Role;
import com.codewithmosh.store.entities.User;
import com.codewithmosh.store.repositories.RoleRepository;
import com.codewithmosh.store.repositories.UserRepository;
import io.jsonwebtoken.security.Password;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Set;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {
    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception{
        initRoles();
        initAdminUser();
    }

    private void initRoles(){
        if(roleRepository.count() == 0){
            roleRepository.save(Role.builder().name("ADMIN").build());
            roleRepository.save(Role.builder().name("USER").build());
            System.out.println(">>> Created default roles: ADMIN, USER");
        }
    }

    private void initAdminUser(){
        if(!userRepository.existsByEmail("admin@store.com")){
            Role adminRole = roleRepository.findByName("ADMIN")
                    .orElseThrow(() -> new RuntimeException("ADMIN role not found"));

        User admin = User.builder()
                .username("admin")
                .email("admin@store.com")
                .passwordHash(passwordEncoder.encode("admin123"))
                .firstName("Admin")
                .lastName("System")
                .status("ACTIVE")
                .roles(Set.of(adminRole))
                .build();

        userRepository.save(admin);
        System.out.println(">>> Created default admin: admin@store.com / admin123");
        }
    }
}
