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

/// A provider that loads, manages and stores daily scrums.
final class ScrumProvider: ObservableObject {

    /// The dependencies of this provider.
    struct Dependencies {
        /// Retrieves a list of daily scrums.
        public var load: () async throws -> IdentifiedArrayOf<DailyScrum>

        /// Stores a list of daily scrums.
        public var save: (_ scrums: IdentifiedArrayOf<DailyScrum>) async throws -> Void
    }

    /// The dependencies of this provider.
    private let dependencies: Dependencies

    /// The task that handles daily scrum restoration.
    private var restorationTask: Task<Void, Never>?

    /// The task that handles storing the daily scrums.
    private var storeTask: Task<Void, Never>?

    /// A cached and managed list of daily scrums, loaded from the dependencies.
    @MainActor @Published private(set) var scrums: IdentifiedArrayOf<DailyScrum> = []

    /// A provider that loads, manages and stores daily scrums.
    @MainActor init(dependencies: Dependencies) {
        self.dependencies = dependencies
        restoreScrums()
    }

    /// Updates a scrum.
    /// - Parameter scrum: The scrum to update
    @MainActor func save(_ scrum: DailyScrum) {
        scrums[id: scrum.id] = scrum
        storeScrums()
    }

    /// Removes scrums at the given offsets.
    /// - Parameter offsets: The offsets.
    @MainActor func remove(atOffsets offsets: IndexSet) {
        scrums.remove(atOffsets: offsets)
        storeScrums()
    }

    // MARK: - Utility

    /// Restores the daily scrums.
    @MainActor private func restoreScrums() {
        restorationTask?.cancel()
        restorationTask = Task {
            do {
                scrums = try await dependencies.load()
            } catch {
                scrums = []
                print(error)
            }
        }
    }

    /// Stores the daily scrums.
    @MainActor private func storeScrums() {
        storeTask?.cancel()
        storeTask = Task {
            do {
                try await dependencies.save(scrums)
            } catch {
                print(error)
            }
        }
    }
}
