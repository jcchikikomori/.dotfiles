---
name: android-kotlin
description: Android development with Kotlin, Jetpack Compose, MVVM, Hilt, and OWASP mobile security principles.
---

# Android Kotlin Skill

## Language & Style

- Write idiomatic Kotlin: data classes, sealed classes, extension functions, `object` declarations.
- Follow Kotlin Coding Conventions and Android Kotlin Style Guide.
- Prefer `val` over `var`; avoid mutable state unless necessary.
- Use `when` expressions over chains of `if-else` — always include an `else` branch.
- Use Kotlin Coroutines + Flow for async work.
- Follow existing code style in the project — consistency over strict adherence to new standards.
- Apply KISS & DRY, but prioritize consistency with existing code.

## Architecture (MVVM)

- Follow **MVVM** as the standard architecture.
- Use Android Architecture Components: `ViewModel`, `StateFlow`, `Room`, `WorkManager`.
- Separate concerns: `data/`, `domain/`, `presentation/` layers.
- Use **Hilt** for dependency injection.
- Expose UI state as a single `UiState` sealed class from `ViewModel`.
- Keep ViewModels thin on Android-specific logic; delegate business logic to domain/use-case layer.

## Jetpack Compose

- Prefer **Jetpack Compose** for all new UI.
- Keep composables small and focused; extract reusable composables.
- Use State Hoisting — hoist state to the nearest common ancestor.
- Use `remember` / `rememberSaveable` correctly; avoid unnecessary recompositions.
- Prefer `LazyColumn` / `LazyRow` for lists.
- Use `NavHost` (Compose Navigation) for routing.

## Coroutines & Flow

- Launch coroutines from `ViewModel` using `viewModelScope`; `lifecycleScope` in Activities/Fragments.
- Use `StateFlow` for UI state; `SharedFlow` for one-time events.
- Handle errors with `try/catch` or the `catch` operator — never ignore exceptions silently.
- Use `Dispatchers.IO` for I/O; `Dispatchers.Default` for CPU-heavy work.

## Data & Networking

- Use **Room** for local persistence with `@Entity`, `@Dao`, `@Database`.
- Use **Retrofit** + **OkHttp** for network calls.
- Use **Kotlin Serialization** for JSON (preferred in new code).
- Repository pattern: abstract data sources behind a repository interface.
- Avoid **N+1 patterns** — batch data fetches where possible.

## Security (OWASP Mobile Top 10)

- Do not hardcode secrets or API keys in source — use `local.properties` + BuildConfig or sealed storage.
- Enable `android:usesCleartextTraffic="false"` — HTTPS only.
- Use `EncryptedSharedPreferences` for sensitive local data.
- Validate all input; sanitize data passed to WebViews.
- Use certificate pinning for high-security network communication.
- Least privilege: request only necessary Android permissions.
- Strip sensitive data from logs; never log tokens or PII.

## Testing

- Unit test `ViewModel` and domain logic with JUnit 5 + Mockk.
- Use `Turbine` for testing Flows.
- UI test with Compose UI Testing (`composeTestRule`).
- Use Hilt test extensions for DI in tests.
- Expectations compare to **literal values**, not method calls.
- Target **≥95% coverage** on business logic and ViewModels.
- Build must be green before merging.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.

## Build & Tooling

- Keep `minSdk` / `targetSdk` / `compileSdk` up to date.
- Use **Version Catalogs** (`libs.versions.toml`) for dependency management.
- Enable R8/ProGuard for release builds.
- Run `./gradlew lint` and detekt for static analysis.
- Audit dependencies for vulnerabilities.
