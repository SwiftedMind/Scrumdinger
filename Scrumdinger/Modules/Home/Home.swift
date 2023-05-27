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
import Queryable
import Models

struct Home: Provider {
    @EnvironmentObject private var scrumProvider: ScrumProvider
    @StateObject private var router = HomeRouter()

    @Signal<AllScrums.SignalValue> private var scrumListSignal
    @Signal<ScrumDetail.SignalValue> private var scrumDetailSignal

    var entryView: some View {
        NavigationStack(path: $router.path) {
            AllScrums()
                .sendSignals(scrumListSignal)
                .navigationDestination(for: HomeRouter.Destination.self) { destination in
                    view(for: destination)
                }
        }
        .sheet(item: $router.scrumEdit) { draft in
            ScrumEdit(scrum: draft)
        }
        .sheet(item: $router.scrumAdd) { draft in
            ScrumAdd(draft: draft)
        }
        .environmentObject(router)
        .resolveSignals(ofType: SignalValue.self, action: resolveSignal)
    }

    // Holds all the navigation destinations for any given `Path`
    @ViewBuilder @MainActor
    private func view(for destination: HomeRouter.Destination) -> some View {
        switch destination {
        case .scrumDetail(let scrum):
            ScrumDetail(scrumId: scrum.id)
                .sendSignals(scrumDetailSignal, id: scrum.id)
        case .meeting(for: let scrum):
            MeetingDetail(scrum: scrum)
        case .history(let history):
            HistoryDetail(history: history)
        }
    }

    // MARK: - State Configurations

    func resolveSignal(_ value: SignalValue) {
        switch value {
        case .reset:
            break
        case .showScrum(let scrum):
            router.setPath([.scrumDetail(scrum)])
        case .showScrumById(let id):
            if let scrum = scrumProvider.scrums[id: id] {
                router.setPath([.scrumDetail(scrum)])
            }
        case .startMeeting(for: let scrum):
            router.setPath([.scrumDetail(scrum), .meeting(for: scrum)])
        case .startMeetingForScrumWithId(let id):
            if let scrum = scrumProvider.scrums[id: id] {
                router.setPath([.scrumDetail(scrum), .meeting(for: scrum)])
            }
        case .createScrum(draft: let draft):
            scrumListSignal.send(.createScrum(draft: draft))
        case .editScrumOnDetailPage(let scrum):
            router.setPath([.scrumDetail(scrum)])
            scrumDetailSignal.send(.edit)
        case .editRandomScrumOnDetailPage:
            if let scrum = scrumProvider.scrums.randomElement() {
                router.setPath([.scrumDetail(scrum)])
                scrumDetailSignal.send(.edit, id: scrum.id)
            }
        }
    }
}

extension Home {
    enum SignalValue {
        case reset
        case showScrum(DailyScrum)
        case showScrumById(UUID)
        case createScrum(draft: DailyScrum = .draft)
        case editScrumOnDetailPage(DailyScrum)
        case editRandomScrumOnDetailPage
        case startMeeting(for: DailyScrum)
        case startMeetingForScrumWithId(UUID)
    }
}

struct HomeHome_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .withProviders(.mock())
    }
}
