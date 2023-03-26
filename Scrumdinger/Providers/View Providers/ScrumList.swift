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

struct ScrumList: Provider {
    @EnvironmentObject private var scrumStore: ScrumStore

    var interface: Interface<Action>
    var dataInterface: Interface<DataAction>
    var scrums: IdentifiedArrayOf<DailyScrum>

    var entryView: some View {
        ScrumListView(
            interface: .consume(handleViewInterface),
            state: .init(scrums: scrums)
        )
        .navigationTitle(Strings.ScrumList.title.text)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dataInterface.fire(.addScrumButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    // MARK: - Interface Handler

    @MainActor
    private func handleViewInterface(_ action: ScrumListView.Action) {
        switch action {
        case .scrumTapped(let dailyScrum):
            interface.fire(.scrumTapped(dailyScrum))
        case .scrumsDeleted(atOffsets: let offsets):
            dataInterface.fire(.scrumsDeleted(atOffsets: offsets))
        }
    }

    // MARK: - State Configurations

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            break
        }
    }
}

extension ScrumList {

    enum TargetState {
        case reset
    }

    enum DataAction: Hashable {
        case addScrumButtonTapped
        case scrumsDeleted(atOffsets: IndexSet)
    }

    enum Action: Hashable {
        case scrumTapped(DailyScrum)
    }
}

