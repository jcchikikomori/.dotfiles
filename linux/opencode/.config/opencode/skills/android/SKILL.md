---
name: android
description: Android development for both modern (Kotlin/Compose) and legacy (Java/XML) projects. Covers MVVM, MVP, MVC, Hilt/Dagger, and mobile security.
---

# Android Developer Skill

**Roadmap Alignment:** [roadmap.sh/android](https://roadmap.sh/android)
**Language Reference:** [Kotlin Documentation](https://kotlinlang.org/docs/home.html) | [Java Documentation](https://docs.oracle.com/en/java/)

## Project Era Detection
When working on an Android project, first identify the era and build system of the codebase:
- **Modern (Kotlin):** Uses Gradle/KTS, Jetpack Compose, Coroutines, Flow, Hilt, and MVVM.
- **Legacy (Java/Gradle):** Uses Java, Gradle, XML layouts, RxJava/AsyncTasks, Dagger 2, and MVC/MVP.
- **Deep Legacy (Eclipse/Ant):** Uses `AndroidManifest.xml` at the root, an `ant.properties` or `.project` file, no Gradle, and manual `libs/` folder management.

## Language & Style

### Kotlin (Modern)
- Write idiomatic Kotlin: data classes, sealed classes, extension functions, `object` declarations.
- Follow Kotlin Coding Conventions and Android Kotlin Style Guide.
- Prefer `val` over `var`; avoid mutable state unless necessary.
- Use Kotlin Coroutines + Flow for async work.

### Java (Legacy)
- Respect legacy Java conventions. Do not forcefully convert working Java files to Kotlin unless explicitly requested.
- Use explicit getters/setters or Lombok if present.
- Use RxJava 2/3 for async work in legacy codebases, or fall back to threads/handlers if RxJava isn't present.
- Handle nullability explicitly with `@Nullable` and `@NonNull` annotations.

## Architecture

- **Modern:** Follow **MVVM** using `ViewModel`, `StateFlow`, `Room`, and `Hilt`. Separate `data/`, `domain/`, `presentation/`.
- **Legacy:** Respect the existing architecture (MVC or MVP). If migrating, slowly introduce `ViewModel` and `LiveData` to bridge Java components to modern standards.

## UI Layer

- **Modern (Compose):** Prefer **Jetpack Compose** for all new UI. Use State Hoisting.
- **Legacy (XML):** Use `ConstraintLayout` for flat hierarchies. Use ViewBinding over `findViewById`. Respect existing `Activity`/`Fragment` lifecycles.

## Data & Networking

- Use **Room** (or legacy SQLiteOpenHelper if forced) for local persistence.
- Use **Retrofit** + **OkHttp** for network calls (Gson for Java, Kotlin Serialization/Moshi for Kotlin).
- Abstract data sources behind a repository interface to avoid N+1 fetches.

## Security (OWASP Mobile Top 10)

- Do not hardcode secrets or API keys in source — use `local.properties` + BuildConfig or sealed storage.
- Enable `android:usesCleartextTraffic="false"` — HTTPS only.
- Use `EncryptedSharedPreferences` (or Keystore for legacy) for sensitive local data.
- Validate all input; sanitize data passed to WebViews.
- Use certificate pinning for high-security network communication.
- Least privilege: request only necessary Android permissions.
- Strip sensitive data from logs; never log tokens or PII.

## Build Systems & Dependency Management

- **Gradle (Modern):** 
  - Use `build.gradle.kts` (Kotlin DSL) or `build.gradle` (Groovy). 
  - Use **Version Catalogs** (`libs.versions.toml`) for centralizing dependency versions.
  - Pull dependencies from `google()`, `mavenCentral()`, or custom Maven/JitPack repositories.
- **Maven:** 
  - If a strictly Maven-based project (`pom.xml`), define `<dependencies>` and use the Android Maven Plugin.
- **Eclipse/Ant (Deep Legacy):** 
  - Manage dependencies manually by placing `.jar` files in the `libs/` directory.
  - Ensure the `AndroidManifest.xml` and `res/` folders are located at the project root rather than `src/main/`.
  - Avoid suggesting Gradle commands (like `./gradlew`). Use `ant debug` or `ant release` if compilation is required.

## Testing & Tooling

- Test `ViewModel` logic with JUnit + Mockk (Kotlin) or Mockito (Java).
- Keep `minSdk` / `targetSdk` / `compileSdk` up to date.
- Enable R8/ProGuard for release builds.
