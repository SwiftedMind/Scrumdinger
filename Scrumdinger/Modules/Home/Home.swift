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

// The main (and only) module of this example app.
struct Home: View {
    @EnvironmentObject private var scrumProvider: ScrumProvider

    /// The router that's handling all kinds of navigation. It is passed down the view hierarchy as environment object
    /// so that all submodules can access it.
    @StateObject private var router = HomeRouter()

    /// The signal handler sending signals to the scrum list screen.
    @Signal<AllScrums.SignalValue>(debugIdentifier: "Home.ScrumList") private var scrumListSignal

    /// The signal handler sending signals to the scrum detail screen.
    @Signal<ScrumDetail.SignalValue>(debugIdentifier: "Home.ScrumDetail") private var scrumDetailSignal

    /// The contents of the Home module.
    var body: some View {
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
        .fullScreenCover(item: $router.meetingDetail) { dailyScrum in
            MeetingDetail(scrumId: dailyScrum.id)
        }
        .environmentObject(router)
        .resolveSignals(ofType: SignalValue.self, action: resolveSignal) // Resolve signals coming from Root().
    }

    /// Holds all the navigation destination for any given `HomeRouter.Destination`.
    @ViewBuilder @MainActor
    private func view(for destination: HomeRouter.Destination) -> some View {
        switch destination {
        case .scrumDetail(let scrum):
            ScrumDetail(scrumId: scrum.id)
                .sendSignals(scrumDetailSignal, id: scrum.id)
        case .history(let history):
            HistoryDetail(history: history)
        }
    }

    /// Resolves the signals by adjusting the view's state.
    /// - Parameter value: The value of the signal that needs resolving.
    func resolveSignal(_ value: SignalValue) {
        switch value {
        case .showScrum(let scrum):
            router.setPath([.scrumDetail(scrum)])
        case .showScrumById(let id):
            if let scrum = scrumProvider.scrums[id: id] {
                router.setPath([.scrumDetail(scrum)])
            }
        case .startMeeting(for: let scrum):
            router.setPath([.scrumDetail(scrum)])
            router.meetingDetail = scrum
        case .startMeetingForScrumWithId(let id):
            if let scrum = scrumProvider.scrums[id: id] {
                router.setPath([.scrumDetail(scrum)])
                router.meetingDetail = scrum
            }
        case .createScrum(draft: let draft):
            router.popToRoot()
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
    /// The signals the Home module is capable of resolving.
    /// Here, these are used as deep linking targets.
    enum SignalValue {
        case showScrum(DailyScrum)
        case showScrumById(UUID)
        case createScrum(draft: DailyScrum = .draft)
        case editScrumOnDetailPage(DailyScrum)
        case editRandomScrumOnDetailPage
        case startMeeting(for: DailyScrum)
        case startMeetingForScrumWithId(UUID)
    }
}

// Again, anywhere in the app, we can set up a preview using mock (or even live) providers
// to have a fully functional preview canvas.
struct HomeHome_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .withProviders(.mock())
    }
}
