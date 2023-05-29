//
//  Copyright © 2023 Dennis Müller and all collaborators
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

/// The global providers provider, holding all providers that need providing, duh.
///
/// These providers contain all the external dependencies of the app so that the views just have to consume them
/// (for the most part).
/// It's a compromise between handling *all* data in external objects (less convenient, more testable)
/// and handling *no* data in external objects (more convenient, less testable).
///
/// This setup makes it easy to override any provider with a mock variant, simply by overriding its object in the environment.
/// For example:
///
/// ```
/// MyView()
///   .environmentObject(ScrumProvider.mock()) // Override scrum provider with a mock
///   .withProviders(.live()) // Inject live providers
/// ```
@MainActor final class Providers: ObservableObject {

    let scrumProvider: ScrumProvider
    let audioRecorderProvider: AudioRecorderProvider
    let deepLinkResolver: DeepLinkResolver

    init(
        scrumProvider: ScrumProvider,
        audioRecorderProvider: AudioRecorderProvider,
        deepLinkResolver: DeepLinkResolver
    ) {
        self.scrumProvider = scrumProvider
        self.audioRecorderProvider = audioRecorderProvider
        self.deepLinkResolver = deepLinkResolver
    }

    /// Initializes a `Providers` instance using live dependencies.
    /// - Returns: The `Providers` instance.
    static func live() -> Providers {
        .init(
            scrumProvider: .live(),
            audioRecorderProvider: .live(),
            deepLinkResolver: .live()
        )
    }

    /// Initializes a `Providers` instance using mock dependencies.
    /// - Returns: The `Providers` instance.
    static func mock() -> Providers {
        .init(
            scrumProvider: .mock(),
            audioRecorderProvider: .mock(),
            deepLinkResolver: .mock()
        )
    }
}

extension View {
    /// Injects all providers inside of `Providers` into the SwiftUI environment,
    /// so that any module can access it.
    ///
    /// - Note: Even though any SwiftUI view could technically access these providers, only module views should ever do so.
    /// Component views should be as modular, independent and replaceable as possible.
    /// - Parameter providers: The providers object to use to inject into the environment.
    /// - Returns: A view whose environment is modified to include all the providers inside `Providers`.
    @MainActor func withProviders(_ providers: Providers) -> some View {
        self
            .environmentObject(providers.scrumProvider)
            .environmentObject(providers.audioRecorderProvider)
            .environmentObject(providers.deepLinkResolver)
    }
}
