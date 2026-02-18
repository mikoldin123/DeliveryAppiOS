# Delivery Tracking App (iOS)

A testable iOS application built with SwiftUI and MVVM to track delivery orders.

  
## Architecture

**MVVM (Model-View-ViewModel)** combined with a **Repository Pattern**.
- **View (SwiftUI):** Strictly declarative. It observes the ViewModel and renders the UI based on explicit state enums.
- **ViewModel:** Handles presentation logic, state management, and calls the Repository. It transforms raw data into a specific ViewState (loading, loaded, error, empty).
- **Repository:** Abstracts the data source. This allows the app to switch between a MockOrderRepository (used here) and a real API implementation without changing a single line of ViewModel code.
- **Model:** Pure data structures (struct and enum).

Why this approach?
1. **Separation of Concerns:** The View doesn't know about networking. The ViewModel doesn't know about UI components.
2. **Testability:** By injecting the `OrderRepositoryProtocol` into the ViewModel, we can easily inject mock data during Unit Tests.
3. **Scalability:** If we need to add a local database (CoreData/Realm) later, we only update the Repository layer.

## Data Flow
1. `View` requests action (e.g., `loadOrders()`).
2. `ViewModel` sets state to `.loading`.
3.  `Repository` fetches data asynchronously (simulating network delay).
4. `ViewModel` processes data and updates state to `.loaded([Order])`.
5.  `View` automatically updates via `@Published` properties.

## Demonstrations/ Questions
### 1. Domain vs UI Models
In this specific implementation, I used the `Order` struct for both domain and UI to adhere to the timebox. However, the - = **ViewState** enum acts as the decoupling layer.

-   **Current state:** The UI consumes `Order` directly.
-   **Future scaling:** If the backend API changes (e.g., nesting status inside a `meta` object), I would introduce a `OrderDTO` (Data Transfer Object) for decoding, and map it to a `OrderUIModel` in the Repository or ViewModel. This ensures the View never breaks due to backend JSON structure changes.

### 2. Testability by Design
-   **Dependency Injection:** The ViewModels accept a protocol (`OrderRepositoryProtocol`) in their `init`. This is the single most important design choice for testing.
-   **Explicit State:** Testing "Loading" vs "Success" is trivial because `ViewState` is an enum. We don't have to check `if isLoading == true && data.count == 0`.
-   **Trade-off:** Writing protocols and mocks takes slightly more initial setup time than calling a singleton API directly, but it pays off immediately when writing tests.

### 3. Safe Evolution (Scenario: Adding `CANCELLED` status)
If a new status `CANCELLED` is introduced:

1.  **Changes Required:** Changes has to be made on the `OrderStatus` enum, currently unsupported status is marked by default as `.unknown`  and filtered out so app does not break. Other required changes would be on the icons and status labels for the `OrderRowView` also changes to the update `advanceStatus` needs to be added to add logic that `.delivered` status cannot be cancelled or any other new logic. 
2. **Test Protection:** If you accidentally allow an order to move from `DELIVERED` to `CANCELLED`  or any unsupported status, your existing unit tests for the "Delivered" state will fail immediately. 

### 4. Trade-offs
#### What I simplified due to time

-   **Mocking Strategy:** I hardcoded the mock data directly into the `MockOrderRepository`. In a production-level assessment with more time, I would have loaded these from a **local JSON file** to test the decoding logic specifically.
    
-   **Simple Navigation:** I used the standard `NavigationLink(destination:)` initializer. While easy to implement, it couples the `OrderListView` directly to the `OrderDetailView`.
    
-   **Minimal Styling:** I prioritized functional layout primitives (VStack, List, Spacer) over custom design systems. I relied on SwiftUI’s default system materials to ensure the app looks native and respects Dark Mode out of the box.
    
-   **Dependency Injection:** I used manual constructor injection. For a larger app, I would implement a **Dependency Container** or a library like `Factory` to manage the lifecycle of services more cleanly.
    
#### What I would refactor next

-   **Programmatic Navigation:** As mentioned in future improvements, I would migrate to `NavigationPath`. This would allow me to move navigation logic out of the View and into a Coordinator or Router, making the Views truly independent.
    
-   **Domain Model Separation:** I would create a strict boundary between `OrderDTO` (the raw data from the API) and `Order` (the domain model used by the UI). This prevents a backend field name change from breaking the entire UI layer.
    
-   **Combine Integration:** I would replace the `Timer` in the `OrderDetailViewModel` with **AsyncStream** or a Combine-based tracking service. This would allow for better cancellation handling and cleaner "live" data streams.
    
-   **Snapshot Testing:** I would add `SnapshotTesting` (using the Point-Free library) to ensure that the UI remains consistent across different device sizes (iPhone SE vs. Pro Max) without manually checking every simulator.

### 5. Future Improvements

#### 1. Programmatic Navigation (`NavigationPath`)

-   **Decoupling:** Currently, the app uses standard `NavigationLink`. I would refactor this to use a `NavigationStack` managed by a `NavigationPath`.
    
-   **Flow Control:** This allows the navigation state to be moved into a `Router` or a `Coordinator` object.
    
-   **Deep Linking:** With a `NavigationPath`, we can easily reconstruct a user's navigation stack from a push notification or a Universal Link (e.g., taking the user directly to a specific Order Detail screen).
    
#### 2. Offline Support & Caching

-   **Persistence:** Implement **SwiftData** to cache `Order` objects. The Repository would fetch from local storage first (for an instant UI load) and sync with the API in the background.
    
-   **Optimistic UI:** Update the status in the UI immediately and revert only if the network call fails, ensuring the app feels "snappy."
    
#### 3. Advanced Error Handling

-   **Granular Errors:** Replace generic errors with a typed `AppError` enum (e.g., `.networkUnreachable`, `.serverError(500)`).
    
-   **Global Toasts:** Use a ViewModifier to show non-intrusive alerts for background update failures rather than blocking the whole screen.
    
#### 4. CI/CD & Quality

-   **GitHub Actions:** Automate `xcodebuild test` on every PR.
    
-   **Linting:** Integrate **SwiftLint** to enforce a unified style guide.
    
#### 5. Performance

-   **Pagination:** Implement infinite scrolling in the list for high-volume customers.

## Thought Exercise: Real-Time Map Tracking
If I had more time to implement real-time driver tracking:
1.  **Isolation:** I would create a `MapServiceProtocol` that wraps the native `MapKit` or Google Maps SDK. The ViewModel would interact with this protocol, not the SDK directly.
2.  **Communication:** I would use a `WebSocket` connection managed by a `LocationRepository`.
3.  **State:** The ViewModel would subscribe to a `PassthroughSubject<CLLocationCoordinate2D, Never>` stream.
4.  **Testing:** By wrapping the Map SDK, I can unit test the ViewModel's reaction to coordinate updates (e.g., calculating ETA) without needing to instantiate a real MapView or simulate GPS signals in the test runner.