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
    var scrums: IdentifiedArrayOf<DailyScrum>
    var scrumCreation: QueryableItem<DailyScrum, DailyScrum?>.Trigger

    var entryView: some View {
        ScrumListView(
            interface: .consume(handleViewInterface),
            state: .init(scrums: scrums)
        )
        .navigationTitle(Strings.ScrumList.title.text)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    queryScrumCreation()
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
        }
    }

    // MARK: - State Configurations

    func applyStateConfiguration(_ configuration: StateConfiguration) {
        switch configuration {
        case .reset:
            break
        }
    }

    // MARK: - Queries

    // Present the Edit Scrum sheet to create a new scrum.
    @MainActor
    private func queryScrumCreation() {
        Task {
            do {
                if let scrum = try await scrumCreation.query(with: .draft) {
                    scrumStore.saveScrum(scrum)
                }
            } catch {
                print(error)
            }
        }
    }
}

extension ScrumList {

    enum StateConfiguration {
        case reset
    }

    enum Action: Hashable {
        case scrumTapped(DailyScrum)
    }
}

