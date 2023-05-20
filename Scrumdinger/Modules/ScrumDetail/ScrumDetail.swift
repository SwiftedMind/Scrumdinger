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

struct ScrumDetail: Provider {
    var interface: Interface<Action>
    var dataInterface: Interface<DataAction>
    var scrum: DailyScrum

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

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            break
        }
    }

    // MARK: - Utility

    @ToolbarContentBuilder @MainActor
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(Strings.edit.text) {
                dataInterface.fire(.editButtonTapped)
            }
        }
    }
}

extension ScrumDetail {

    enum TargetState {
        case reset
    }

    enum DataAction: Hashable {
        case editButtonTapped
    }

    enum Action: Hashable {
        case startMeetingButtonTapped
        case historyTapped(History)
    }
}

