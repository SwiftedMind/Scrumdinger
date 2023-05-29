
<p align="center">
  <img width="200" height="200" src="https://github.com/SwiftedMind/Scrumdinger/assets/7083109/8868bbf6-b8c6-4bc6-b637-adad36678a2b">
</p>

# Scrumdinger Re-Implementation
This project is a re-implementation of Apple's [Scrumdinger](https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger) tutorial app in the [Puddles architecture](https://github.com/SwiftedMind/Puddles) that I'm working on. It is my attempt at creating a modular and scalable app structure.

The idea of using this example app to test out different ideas and architectures is an idea by [Point-Free](https://www.pointfree.co/). They built a version of the app based on their [Modern SwiftUI](https://www.pointfree.co/collections/swiftui/modern-swiftui) series. You can find it here: [Standups](https://github.com/pointfreeco/standups).

## Architecture


## Tools Used
- [Puddles](https://github.com/SwiftedMind/Puddles/tree/develop), which is an app architecture that I' working on. The idea behind it is to use as many native SwiftUI mechanisms as possible with as little abstraction as possible. There are, naturally, a lot of trade-offs and disadvantages with this approach, but it also makes it easy to adopt, adjust, maintain and remove.
- [Queryable](https://github.com/SwiftedMind/Queryable), a Swift package I built that lets you present views (like a sheet or an overlay) asynchronously, using Swift Concurrency.
- [Identified Collections](https://github.com/pointfreeco/swift-identified-collections) by Point-Free, which is an _incredibly_ useful wrapper around [OrderedDictionary](https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md). It's the first thing I add to any new project I start.
