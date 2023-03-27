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

import Puddles
import SwiftUI
import IdentifiedCollections

extension ScrumList {
    struct All: Provider {
        @EnvironmentObject private var scrumStore: ScrumStore

        var interface: Interface<ScrumList.Action>
        var scrumCreation: Queryable<DailyScrum, DailyScrum?>.Trigger

        var entryView: some View {
            ScrumList(
                interface: .forward(to: interface),
                dataInterface: .consume(handleDataInterface),
                scrums: scrumStore.scrums
            )
        }

        // MARK: - Interface Handlers

        @MainActor
        private func handleDataInterface(_ action: ScrumList.DataAction) {
            switch action {
            case .addScrumButtonTapped:
                queryScrumCreation(draft: .draft)
            case .scrumsDeleted(atOffsets: let offsets):
                scrumStore.removeScrums(atOffsets: offsets)
            }
        }

        // MARK: - State Configurations

        func applyTargetState(_ state: TargetState) {
            switch state {
            case .createScrum(draft: let draft):
                scrumCreation.cancel()
                queryScrumCreation(draft: draft ?? .draft)
            }
        }

        // MARK: - Queries

        // Present the Edit Scrum sheet to create a new scrum.
        @MainActor
        private func queryScrumCreation(draft: DailyScrum) {
            Task {
                do {
                    // Triggers presentation of a sheet with a form to create an item and a save button.
                    // When the save button has been pressed, the sheet is dismissed and
                    // this function resumes with the created item
                    if let scrum = try await scrumCreation.query(with: draft) {
                        scrumStore.saveScrum(scrum)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension ScrumList.All {

    enum TargetState {
        case createScrum(draft: DailyScrum? = .draft)
    }

    enum Action: Hashable {
        case noAction
    }
}
