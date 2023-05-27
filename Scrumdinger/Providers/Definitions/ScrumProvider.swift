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

final class ScrumProvider: ObservableObject {

    struct Dependencies {
        public var load: () async throws -> IdentifiedArrayOf<DailyScrum>
        public var save: (_ scrums: IdentifiedArrayOf<DailyScrum>) async throws -> Void
    }

    private let dependencies: Dependencies
    private var restorationTask: Task<Void, Never>?
    private var storeTask: Task<Void, Never>?

    // The collection representing all the user's scrums
    @MainActor @Published private(set) var scrums: IdentifiedArrayOf<DailyScrum> = []

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

    @MainActor func remove(atOffsets offsets: IndexSet) {
        scrums.remove(atOffsets: offsets)
        storeScrums()
    }

    // MARK: - Utility

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
