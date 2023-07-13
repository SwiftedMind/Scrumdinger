

<p align="center">
  <img width="200" height="200" src="https://github.com/SwiftedMind/Scrumdinger/assets/7083109/b4e0b71d-f0f8-4fdd-9883-21611fcbc481">
</p>

# Scrumdinger Re-Implementation
This project is a re-implementation of Apple's [Scrumdinger](https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger) tutorial app in the [Puddles architecture](https://github.com/SwiftedMind/Puddles) that I'm working on. It is my attempt at creating a modular and scalable app structure using as many native SwiftUI mechanisms as possible.

The idea of using this example app to test out different ideas and architectures comes from [Point-Free](https://www.pointfree.co/). They built a version of the app based on their [Modern SwiftUI](https://www.pointfree.co/collections/swiftui/modern-swiftui) series. You can find the project here: [Standups](https://github.com/pointfreeco/standups).

## Project Structure
![A diagram of the project structure that is explained in full below the image](https://github.com/SwiftedMind/Puddles/assets/7083109/8169d9f0-c8ed-469c-b191-2894f890d9b3)


### Core (Local Swift Package)
The Core layer is a local Swift package. Here, you can define all the logic that is independent of your app or UI, like network adapters, file stores, app models or controllers. Importantly, all this business logic should be as opaque to the app as possible. For example, an API connector should not leak its DTO models but instead internally translate them into app models.

While not technically independent of the app, this Core package makes building independent business logic much more convenient and you lose very little in the majority of cases, I would argue.

The Scrumdinger re-implementation has 5 targets inside the Services package:
- **AudioRecording** - Contains the `SpeechRecognizer` class that handles the transcription of meetings.
- **Extensions** - Contains a few helpful extensions that are commonly used in the app.
- **MockData** - Contains some general mock data. In this case, there is only a simple `MockError`.
- **Models** - Contains the app's models, like `DailyScrum` or `Theme`.
- **ScrumStore** - Contains the logic to read from and write to the file system, where the daily scrums are stored.

### Providers
A Provider acts as the interface between the Core packages and the actual app. It is responsible for preparing and caching data using one or more dependencies and communicating updates to the views (via `@Published` properties, for example). 

Providers are distributed through the native SwiftUI environment, as environment objects, which means they are accessible from anywhere in the view hierarchy as well as easily overridable.

#### Dependency Injection

An important aspect of a Provider is that it doesn't directly access or manipulate data. Rather, it does so through a `Dependencies` API, which can be injected at initialization.

In Scrumdinger, this is done with a `Dependencies` object that contains property closures for each functionality that it needs. For example, the `ScrumProvider` needs to load and save daily scrums, so the dependencies might look like this:

```swift
final class ScrumProvider: ObservableObject {
  struct Dependencies {
    public var load: () async  throws -> IdentifiedArrayOf<DailyScrum>
    public var save: (_ scrums: IdentifiedArrayOf<DailyScrum>) async throws -> Void
  }
  // ...
}
```

This means, we can easily provide different instances of `Dependencies` to the provider to change its data access. Without ever changing the provider, we can swap out a file-system based storage with a backend storage, or use an in-memory store for use in previews. For example, the Scrumdinger re-implementation uses these two implementations of  `ScrumProvider`:

```swift
extension ScrumProvider {
  @MainActor static func live() -> ScrumProvider {
    let store = ScrumStore()
    return .init(
      dependencies: .init(
        load: {
          try await store.load()
        }, save: { scrums in
          try await store.save(scrums)
        }
      )
    )
  }
}

// MARK: - Mock
extension ScrumProvider {
  @MainActor static func mock() -> ScrumProvider {
    let store = InMemoryStore(scrums: .mockList)
    return .init(
      dependencies: .init(
        load: {
          try await store.load()
        }, save: { scrums in
          try await store.save(scrums)
        }
      )
    )
  }
}

@MainActor private final class InMemoryStore { /* ... */ }
```

To use the provider, you can inject it into the environment, using either the live or the mock implementation:
```swift
RootView()
  .environmentObject(ScrumProvider.live())
  // ...
```
Since this is using the SwiftUI environment, you can easily override the provider to use a mock in any part of your view hierarchy.

### Components

The Components layer is comprised of generic SwiftUI views that do not know anything about their placement in the app or the origin of their data. All they do is specify what they need and then display it and report back any user interaction that might trigger a side effect, like a navigation or a backend fetch.

View components should be trivial to reuse anywhere in the app, since they have no context about anything whatsoever.

### Modules

Modules form the structure of the app. They define the concrete screens, the navigation between them as well as what data is shown on each screen. Essentially, they act as the glue that connects the generic providers with the generic view components to create the actual UX of the app. As such, _they cannot be generic themselves, by definition_. They implement the app's concrete _user stories_, using the generic tools mentioned above. 

Modules know about their specific place and context in the app. In them, you can and should hardcode navigation, toolbars or anything, that's fine since both the accessed providers as well as the contained view components are already generic and the modules only add context and connection logic, not meaningful new functionality. Ideally, no two modules should be the same, even if their underlying view components or providers are. There's always a semantic difference, like a changed title, toolbar or navigation destination. 

To do all the things described above, modules are also plain SwiftUI views, giving them access to the environment as well as the ability to be placed in any SwiftUI view hierarchy without additional setup or data injections. For example, this is what the `AllScrums` module looks like:

```swift
// AllScrums module, which is part of the main "Home" module
struct AllScrums: View {
  @EnvironmentObject private var router: HomeRouter // Access to the Home module's navigation
  @EnvironmentObject private var scrumProvider: ScrumProvider // Access the scrums via a provider

  var body: some View {
    ScrumListView( // Generic UI component taking data and reporting user interactions
      interface: .consume(handleInterface), // Handle user interactions
      scrums: scrumProvider.scrums // Provide concrete data to the UI
    )
    .navigationTitle(Strings.ScrumList.title.text) // Set the view's context (this module is part of a navigation stack, so it needs a title)
    .toolbar { toolbarContent } // Set the toolbar
    .resolveSignals(ofType: SignalValue.self, action: resolveSignal) // Resolve signals from parent
  }
  
  // ...
}
```

## Tools Used
- [Puddles](https://github.com/SwiftedMind/Puddles/tree/develop), which is an app architecture that I'm working on. The idea behind it is to use as many native SwiftUI mechanisms as possible with as little abstraction as possible. There are, naturally, a lot of trade-offs and disadvantages with this approach, but it also makes it easy to adopt, adjust, maintain and remove.
- [Queryable](https://github.com/SwiftedMind/Queryable), a Swift package I built that lets you present views (like a sheet or an overlay) asynchronously, using Swift Concurrency.
- [Identified Collections](https://github.com/pointfreeco/swift-identified-collections) by Point-Free, which is an _incredibly_ useful wrapper around [OrderedDictionary](https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md). It's the first thing I add to any new project I start.
