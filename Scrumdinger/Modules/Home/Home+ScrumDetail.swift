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
    /// The submodule inside Home that is displaying the detail view of a daily scrum.
    struct ScrumDetail: View {
        @EnvironmentObject private var router: HomeRouter
        @EnvironmentObject private var scrumProvider: ScrumProvider

        /// The id of the daily scrum for this meeting.
        var scrumId: DailyScrum.ID

        /// The daily scrum from the scrum provider.
        private var managedScrum: DailyScrum? {
            scrumProvider.scrums[id: scrumId]
        }

        var body: some View {
            if let managedScrum {
                ScrumDetailView(
                    interface: .consume(handleInterface),
                    scrum: managedScrum
                )
                .navigationTitle(managedScrum.title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
                .resolveSignals(ofType: SignalValue.self, action: resolveSignal)
            }
        }

        // MARK: - Interface Handlers

        @MainActor
        private func handleInterface(_ action: ScrumDetailView.Action) {
            switch action {
            case .startMeetingButtonTapped:
                guard let managedScrum else { return }
                router.meetingDetail = managedScrum
                router.setPath([.scrumDetail(managedScrum)])
            case .historyTapped(let history):
                router.push(.history(history))
            }
        }

        // MARK: - State Configurations

        @MainActor
        func resolveSignal(_ value: SignalValue) {
            switch value {
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
            guard let managedScrum else { return }
            Task {
                do {
                    try router.queryEditScrum(managedScrum)
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension Home.ScrumDetail {
    enum SignalValue {
        case edit
    }
}

struct Home_ScrumDetailPage_Previews: PreviewProvider {
    static let providers = Providers.mock()
    static var previews: some View {
        Home.ScrumDetail(scrumId: providers.scrumProvider.scrums.first?.id ?? DailyScrum.mock.id)
            .environmentObject(HomeRouter())
            .withProviders(providers)
    }
}
