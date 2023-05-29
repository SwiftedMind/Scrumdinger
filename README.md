
<p align="center">
  <img width="200" height="200" src="https://github.com/SwiftedMind/Scrumdinger/assets/7083109/d38ec00b-3d03-4506-a4b8-95eb1157529c">
</p>

# Scrumdinger Re-Implementation
This project is a re-implementation of Apple's [Scrumdinger](https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger) tutorial app in the [Puddles architecture](https://github.com/SwiftedMind/Puddles) that I'm working on. It is my attempt at creating a modular and scalable app structure using as many native SwiftUI mechanisms as possible.

The idea of using this example app to test out different ideas and architectures comes from [Point-Free](https://www.pointfree.co/). They built a version of the app based on their [Modern SwiftUI](https://www.pointfree.co/collections/swiftui/modern-swiftui) series. You can find the project here: [Standups](https://github.com/pointfreeco/standups).

## Project Structure
![A diagram of the project structure that is explained in full below the image](https://github.com/SwiftedMind/Scrumdinger/assets/7083109/4524b6ff-5dc6-4534-8433-d0ea413fe437)


### Services (Local Swift Package)
The services are part of a local "Services" package. Here, you can define all the logic that is independent of your app or UI, like network adapters, file stores or controllers. I also like to put the models in there. While not technically independent of the app, it makes building services much more convenient and you lose very little in the majority of cases, I would argue.

The Scrumdinger re-implementation has 5 targets inside the Services package:
- **AudioRecording** - Contains the `SpeechRecognizer` class that handles the transcription of meetings.
- **Extensions** - Contains a few helpful extensions that are commonly used in the app.
- **MockData** - Contains some general mock data. In this case, there is only a simple `MockError`.
- **Models** - Contains the app's models, like `DailyScrum` or `Theme`.
- **ScrumStore** - Contains the logic to read from and write to the file system, where the daily scrums are stored.

This approach encapsulates all non-UI related logic into isolated targets that can be imported as needed, keeping the namespaces clear while hiding implementation details like DTO models or internal helpers from the app.

### Providers
A Provider acts as the interface between the services packages and the actual app. It is responsible for preparing and caching data using one or more services and communicate updates to the views (via `@Published` properties, for example). 

Providers are distributed through the native SwiftUI environment, as environment objects, which means they are accessible from anywhere in the view hierarchy as well as easily overridable. However, they are only accessed from within module views (see below).

#### Dependencies

An important aspect of a Provider is that it doesn't directly access instances of a service. Rather, it defines a `Dependencies` object that contains closures for each functionality that it needs. For example, the `ScrumProvider` needs to load and save daily scrums, so the dependencies might look like this:

```swift
final class ScrumProvider: ObservableObject {
  struct Dependencies {
    public var load: () async  throws -> IdentifiedArrayOf<DailyScrum>
    public var save: (_ scrums: IdentifiedArrayOf<DailyScrum>) async throws -> Void
  }
  // ...
}
```

This means, we can easily provide different instances of `Dependencies` to the provider to provide specific external behaviors. Without ever changing the provider, we can swap out a file-system based storage with a backend storage, or use an in-memory store for use in previews. For example, the Scrumdinger re-implementation uses these two implementations of  `ScrumProvider`:

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

### Modules
### Components


## Tools Used
- [Puddles](https://github.com/SwiftedMind/Puddles/tree/develop), which is an app architecture that I'm working on. The idea behind it is to use as many native SwiftUI mechanisms as possible with as little abstraction as possible. There are, naturally, a lot of trade-offs and disadvantages with this approach, but it also makes it easy to adopt, adjust, maintain and remove.
- [Queryable](https://github.com/SwiftedMind/Queryable), a Swift package I built that lets you present views (like a sheet or an overlay) asynchronously, using Swift Concurrency.
- [Identified Collections](https://github.com/pointfreeco/swift-identified-collections) by Point-Free, which is an _incredibly_ useful wrapper around [OrderedDictionary](https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md). It's the first thing I add to any new project I start.
