---
name: grails
description: Web application development using the Grails framework (Groovy). Covers GORM, MVC conventions, Groovy syntax, and Grails-specific service layers.
---

# Grails Developer Skill

**Reference:** [Grails Framework Documentation](https://docs.grails.org/latest/) | [Groovy Language](https://groovy-lang.org/)

## Framework Overview
Grails is a high-productivity web framework for the JVM based on the Groovy language. It relies heavily on "Convention over Configuration," strongly resembling Ruby on Rails, but built on top of Spring Boot and Hibernate.

## Language & Style (Groovy)
- Use Groovy's dynamic typing, closures, and collection methods (`.collect()`, `.find()`, `.findAll()`).
- Leverage GStrings (`"Hello ${name}"`) instead of Java string concatenation.
- Respect Groovy truth (e.g., empty strings, null, and empty collections evaluate to `false`).

## Architecture (MVC + Services)
- **Domain Classes (`grails-app/domain`):** Define the data model. Grails automatically injects **GORM** (Grails Object Relational Mapping) methods into these classes.
- **Controllers (`grails-app/controllers`):** Handle web requests. Keep them thin. Map URLs, bind parameters, and delegate complex logic to services.
- **Services (`grails-app/services`):** This is where business logic lives. Services in Grails are transactional by default.
- **Views (`grails-app/views`):** Use GSP (Groovy Server Pages) for HTML rendering, or JSON views (JSON Views / Gson) for REST APIs.

## GORM (Grails Object Relational Mapping)
- Use dynamic finders: `User.findByEmail(email)`, `Book.findAllByAuthorAndTitle(...)`.
- Use `where` queries or Criteria criteria builder for complex queries instead of raw SQL/HQL.
- Manage constraints and validation directly inside the Domain class `constraints = { ... }` block.
- Be cautious of N+1 query problems; use `fetch: [association: "join"]` in queries when eager loading is necessary.

## Best Practices
- **Never put business logic in Controllers.** Controllers should only handle routing, parameter binding, and choosing the response format.
- Let GORM handle the heavy lifting of database migrations/schema updates via `database-migration` plugin (Liquibase).
- Use Grails CLI commands (`grails create-domain-class`, `grails create-controller`, `grails generate-all`) to bootstrap code and ensure it lands in the conventionally correct folders.