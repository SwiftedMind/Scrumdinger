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
import IdentifiedCollections
import Models

/// A provider that handles the recording of transcripts.
final class AudioRecorderProvider: ObservableObject {

    /// The dependencies of this provider.
    struct Dependencies {
        /// Resets the recorder.
        public var reset: () -> Void

        /// Requests to start a transcription.
        public var startTranscription: () async throws -> Void

        /// Finishes a transcription and returns the final result.
        public var finishTranscription: () -> String
    }

    /// The dependencies of this provider.
    private let dependencies: Dependencies

    /// A flag indicating is the audio recorder is recording.
    @MainActor @Published var isTranscribing: Bool = false

    /// A provider that handles the recording of transcripts.
    @MainActor init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    /// Resets the recorder.
    @MainActor public func reset() {
        dependencies.reset()
    }

    /// Requests to start a transcription.
    @MainActor public func startTranscription() async throws {
        try await dependencies.startTranscription()
        isTranscribing = true
    }

    /// Finishes a transcription and returns the final result.
    @MainActor public func finishTranscription() -> String {
        isTranscribing = false
        return dependencies.finishTranscription()
    }
}
