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

struct ScrumDetail: Provider {
    // TODO: is this modular and flexible? to have this environmentobject be everywhwere`
    @EnvironmentObject private var scrumStore: ScrumStore

    var interface: Interface<Action>
    var scrum: DailyScrum
    var scrumEdit: QueryableItem<DailyScrum, DailyScrum?>.Trigger

    var entryView: some View {
        ScrumDetailView(
            interface: .consume(handleViewInterface),
            state: .init(scrum: scrum)
        )
        .navigationTitle(scrum.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
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

    func applyStateConfiguration(_ configuration: StateConfiguration) {
        switch configuration {
        case .reset:
            break
        }
    }

    // MARK: - Utility

    @ToolbarContentBuilder @MainActor
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(Strings.edit.text) {
                editScrum()
            }
        }
    }

    // MARK: - Queries

    // Present the Edit Scrum sheet to modify an existing scrum.
    @MainActor
    private func editScrum() {
        Task {
            do {
                if let newScrum = try await scrumEdit.query(with: scrum) {
                    scrumStore.saveScrum(newScrum)
                }
            } catch {
                print(error)
            }
        }
    }
}

extension ScrumDetail {

    enum StateConfiguration {
        case reset
    }

    enum Action: Hashable {
        case startMeetingButtonTapped
        case historyTapped(History)
    }
}

