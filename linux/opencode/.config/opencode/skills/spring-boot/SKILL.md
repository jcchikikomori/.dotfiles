---
name: spring-boot
description: Java/Kotlin backend development using the Spring Boot framework. Covers Controller-Service-Repository patterns, Spring Data JPA, Spring Security, and dependency injection.
---

# Spring Boot Developer Skill

**Roadmap Alignment:** [roadmap.sh/spring-boot](https://roadmap.sh/spring-boot)
**Language Reference:** [Spring Boot Reference Guide](https://docs.spring.io/spring-boot/reference/)

## Architecture & Design Patterns
- **Layered Architecture:** Strictly enforce the **Controller -> Service -> Repository** pattern.
  - **Controllers (`@RestController`)**: Handle HTTP requests, validation, and serialization. Should contain NO business logic.
  - **Services (`@Service`)**: Contain core business logic and transaction management.
  - **Repositories (`@Repository`)**: Handle database access (usually extending `JpaRepository` or `CrudRepository`).
- **Dependency Injection:** Use **Constructor Injection** (via `Lombok` `@RequiredArgsConstructor` or explicitly writing the constructor). NEVER use field injection (`@Autowired` on variables) as it makes unit testing difficult and hides dependencies.

## Data & Persistence
- **Spring Data JPA / Hibernate:** 
  - Use Entities (`@Entity`) with proper relationship annotations (`@OneToMany`, `@ManyToOne`).
  - Avoid N+1 query problems by using `@EntityGraph` or custom JPQL `JOIN FETCH` queries.
  - Keep transaction boundaries at the Service layer using `@Transactional`.
- **Data Transfer Objects (DTOs):** Never expose Entities directly via REST controllers. Map Entities to DTOs using libraries like MapStruct or manual mappers.

## Security
- **Spring Security:** 
  - Use `SecurityFilterChain` beans for configuring HTTP security (avoid deprecated `WebSecurityConfigurerAdapter`).
  - Secure endpoints using `@PreAuthorize` method-level security.
  - Use standard stateless authentication (JWT) for APIs.

## Exception Handling
- Use `@RestControllerAdvice` and `@ExceptionHandler` to globally handle exceptions and return standardized, RFC 7807 (Problem Details) compliant JSON error responses.

## Configuration & Testing
- Use `application.yml` or `application.properties` for configurations.
- Use `@ConfigurationProperties` for type-safe configuration binding instead of `@Value`.
- Test controllers using `@WebMvcTest`. Test data layers with `@DataJpaTest`. Write integration tests with `@SpringBootTest` and Testcontainers.