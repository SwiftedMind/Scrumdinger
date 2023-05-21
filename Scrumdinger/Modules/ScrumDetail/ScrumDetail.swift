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
import Models
import Queryable

struct ScrumDetail: Provider {
    @EnvironmentObject private var scrums: Feature.Scrums

    /// The scrum detail interface.
    var interface: Interface<Action>

    // TODO: This feels strange.
    /// The managed scrum. Its identifier will be used to always display the up-to-date version of this scrum from the `Scrums` feature.
    var scrumId: DailyScrum.ID

    /// The queryable that provides us with the means to edit a scrum.
    var onEdit: (DailyScrum) async throws -> DailyScrum?

    private var managedScrum: DailyScrum? {
        scrums.all[id: scrumId]
    }

    var entryView: some View {
        if let managedScrum {
            ScrumDetailView(
                interface: .consume(handleViewInterface),
                state: .init(scrum: managedScrum)
            )
            // TODO: Should this be here? too much context?
            .navigationTitle(managedScrum.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
        }
    }

    // MARK: - Interface Handler

    @MainActor
    private func handleViewInterface(_ action: ScrumDetailView.Action) {
        switch action {
        case .historyTapped(let history):
            interface.fire(.historyTapped(history))
        case .startMeetingButtonTapped:
            interface.fire(.startMeetingButtonTapped)
        }
    }

    // MARK: - State Configurations

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            break
        case .edit:
            queryEditScrum()
        }
    }

    // MARK: - Utility

    @ToolbarContentBuilder @MainActor
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(Strings.edit.text) {
                queryEditScrum()
            }
        }
    }

    @MainActor
    private func queryEditScrum() {
        Task {
            do {
                if let newScrum = try await onEdit(scrum) {
                    scrums.save(newScrum)
                }
            } catch {
                print(error)
            }
        }
    }
}

extension ScrumDetail {
    enum TargetState {
        case reset
        case edit
    }

    enum Action: Hashable {
        case startMeetingButtonTapped
        case historyTapped(History)
    }
}

