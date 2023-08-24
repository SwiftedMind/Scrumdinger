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
    /// The submodule inside Home that is displaying a list of all scrums.
    struct AllScrums: View {
        @EnvironmentObject private var scrumProvider: ScrumProvider

        var body: some View {
            ScrumListView(
                interface: .consume(handleInterface),
                scrums: scrumProvider.scrums
            )
            .navigationTitle(Strings.ScrumList.title.text)
            .toolbar { toolbarContent }
        }

        // MARK: - Interface Handlers

        @MainActor
        private func handleInterface(_ action: ScrumListView.Action) {
            switch action {
            case .scrumTapped(let scrum):
                Router.shared.navigate(to: .scrumDetail(scrum))
            case .scrumsDeleted(let offsets):
                scrumProvider.remove(atOffsets: offsets)
            }
        }

        // MARK: - Utility

        @ToolbarContentBuilder @MainActor
        private var toolbarContent: some ToolbarContent {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    queryScrumCreation(draft: Mock.DailyScrum.draft)
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
                    try Router.shared.queryAddScrum(withDraft: draft)
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct Home_AllScrums_Previews: PreviewProvider {
    static var previews: some View {
        Home.AllScrums()
            .withMockProviders()
    }
}
