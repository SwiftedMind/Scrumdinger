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

extension Home {
    struct AllScrums: Provider {
        @EnvironmentObject private var router: HomeRouter
        @EnvironmentObject private var scrumProvider: ScrumProvider

        var entryView: some View {
            ScrumListView(
                interface: .consume(handleInterface),
                scrums: scrumProvider.scrums
            )
            .navigationTitle(Strings.ScrumList.title.text)
            .toolbar { toolbarContent }
            .resolveSignals(ofType: SignalValue.self, action: resolveSignal)
        }

        // MARK: - Interface Handlers

        @MainActor
        private func handleInterface(_ action: ScrumListView.Action) {
            switch action {
            case .scrumTapped(let scrum):
                router.push(.scrumDetail(scrum))
            case .addScrumButtonTapped:
                queryScrumCreation(draft: .draft)
            case .scrumsDeleted(let offsets):
                scrumProvider.remove(atOffsets: offsets)
            }
        }

        @MainActor
        func resolveSignal(_ value: SignalValue) {
            switch value {
            case .reset:
                break
            case .createScrum(let draft):
                queryScrumCreation(draft: draft)
            }
        }

        // MARK: - Utility

        @ToolbarContentBuilder @MainActor
        private var toolbarContent: some ToolbarContent {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    queryScrumCreation(draft: .draft)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }

        // Present the Edit Scrum sheet to create a new scrum.
        @MainActor
        private func queryScrumCreation(draft: DailyScrum) {
            Task {
                do {
                    try router.queryAddScrum(withDraft: draft)
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension Home.AllScrums {
    enum SignalValue {
        case reset
        case createScrum(draft: DailyScrum)
    }
}

struct Home_AllScrums_Previews: PreviewProvider {
    static var previews: some View {
        Home.AllScrums()
            .environmentObject(HomeRouter())
            .withProviders(.mock())
    }
}
