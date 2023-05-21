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

// TODO: Rename StateSetter and TargetStates. they sound bad

/*
 StateUpdate, StatePoint, StateCombination, StateSet, Control, StateControl,

 StatePublisher StateStream, StateSignal

 Shortcut, memory, Quick, Pointer, Deeplink, state application
 */

struct Home: Provider {
    @EnvironmentObject private var scrums: Feature.Scrums
    @EnvironmentObject private var router: Feature.HomeRouter

    // Target State setter for `ScrumListPage`.
    // Used to apply a state when a deep link is being handled.
    @TargetStateSetter<ScrumListPage.TargetState> private var scrumList

    // Target State setter for `ScrumDetailPage`.
    // Used to apply a state when a deep link is being handled.
    @TargetStateSetter<ScrumDetailPage.TargetState> private var scrumDetail

    var entryView: some View {
        NavigationStack(path: $router.path) {
            ScrumListPage()
                .applyTargetStates(with: scrumList)
                .navigationDestination(for: Feature.HomeRouter.Destination.self) { destination in
                    view(for: destination)
                }
        }
        .sheet(item: $router.scrumEdit) { draft in
            ScrumEditSheet(scrum: draft)
        }
        .sheet(item: $router.scrumAdd) { draft in
            ScrumAddSheet(draft: draft)
        }
        .environmentObject(router)
    }

    // Holds all the navigation destinations for any given `Path`
    @ViewBuilder @MainActor
    private func view(for destination: Feature.HomeRouter.Destination) -> some View {
        switch destination {
        case .scrumDetail(let scrum):
            ScrumDetailPage(scrumId: scrum.id)
                .applyTargetStates(with: scrumDetail, id: scrum.id)
        case .meeting(for: let scrum):
            MeetingPage(scrum: scrum)
        case .history(let history):
            HistoryDetail(
                interface: .consume { handleHistoryDetailInterface($0, for: history)},
                history: history
            )
        }
    }

    // MARK: - Interface Handler

    // Handles the interface from `HistoryDetail`
    @MainActor
    private func handleHistoryDetailInterface(_ action: HistoryDetail.Action, for history: History) {
        switch action {
        case .noAction:
            break
        }
    }

    // MARK: - State Configurations

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            break
        case .showScrum(let scrum):
            router.setPath([.scrumDetail(scrum)])
        case .showScrumById(let id):
            if let scrum = scrums.all[id: id] {
                router.setPath([.scrumDetail(scrum)])
            }
        case .startMeeting(for: let scrum):
            router.setPath([.scrumDetail(scrum), .meeting(for: scrum)])
        case .startMeetingForScrumWithId(let id):
            if let scrum = scrums.all[id: id] {
                router.setPath([.scrumDetail(scrum), .meeting(for: scrum)])
            }
        case .createScrum(draft: let draft):
            scrumList.apply(.createScrum(draft: draft))
        case .editScrumOnDetailPage(let scrum):
            router.setPath([.scrumDetail(scrum)])
            scrumDetail.apply(.edit)
        case .editRandomScrumOnDetailPage:
            if let scrum = scrums.all.randomElement() {
                router.setPath([.scrumDetail(scrum)])
                scrumDetail.apply(.edit, id: scrum.id)
            }
        }
    }
}

extension Home {
    enum TargetState {
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
            .withFeatures(.mock())
    }
}
