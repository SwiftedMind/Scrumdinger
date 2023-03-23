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

// TODO: If we push a .mock detail, you can start and end a meeting, but that will never appear in the detail screen, since it is not managed
// Is that fine or does it need a solution?

@MainActor
final class ScrumStore: ObservableObject {

    private var service: ScrumService

    // The collection representing all the user's scrums
    @Published private(set) var scrums: IdentifiedArrayOf<DailyScrum> = []
    private var restorationTask: Task<Void, Never>?
    private var storeTask: Task<Void, Never>?

    init(service: ScrumService) {
        self.service = service
        restoreScrums()
    }

    /// Updates a scrum.
    /// - Parameter scrum: The scrum to update
    func saveScrum(_ scrum: DailyScrum) {
        scrums[id: scrum.id] = scrum
        storeScrums()
    }

    // MARK: - Utility

    private func restoreScrums() {
        restorationTask?.cancel()
        restorationTask = Task {
            do {
                scrums = try await service.scrums()
            } catch {
                scrums = []
                print(error)
            }
        }
    }

    private func storeScrums() {
        storeTask?.cancel()
        storeTask = Task {
            do {
                try await service.saveScrums(scrums)
            } catch {
                print(error)
            }
        }
    }
}
