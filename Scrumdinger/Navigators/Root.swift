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

struct Root: Navigator {

    // The store that loads and stores all scrums of the user.
    @StateObject private var scrumStore: ScrumStore = .init(service: .live)

    // The navigation path.
    @State private var path: [Path] = []

    // Handle the creation of a scrum via a sheet presentation.
    @Queryable<DailyScrum, DailyScrum?> private var scrumCreation

    // Handle the edit of a scrum via a sheet presentation.
    @Queryable<DailyScrum, DailyScrum?> private var editScrum

    // Handle the confirmation of a meeting end via a confirmation dialog.
    @Queryable<Void, MeetingEndAction> private var meetingEndConfirmation

    // Target State setter for `ScrumList`.
    // Used to apply a state when a deep link is being handled.
    @TargetStateSetter<ScrumList.All.TargetState> private var scrumListTargetState

    // Target State setter for `ScrumDetail`.
    // Used to apply a state when a deep link is being handled.
    @TargetStateSetter<ScrumDetail.Managed.TargetState> private var scrumDetailTargetState

    var entryView: some View {
        NavigationStack(path: $path) {
            ScrumList.All(
                interface: .consume(handleScrumListInterface),
                scrumCreation: scrumCreation
            )
            .targetStateSetter(scrumListTargetState) // Send target states to the scrum list
            .navigationDestination(for: Path.self) { path in
                destination(for: path)
            }
        }
        .queryableSheet(controlledBy: scrumCreation) { draft, query in
            EditScrum(interface: .consume { handleScrumCreationInterface($0, query: query) }, scrum: draft)
                .transition(.scale.combined(with: .opacity))
        }
        .queryableSheet(controlledBy: editScrum) { draft, query in
            EditScrum(interface: .consume { handleScrumCreationInterface($0, query: query) }, scrum: draft, isNew: false)
        }
        .queryableConfirmationDialog(controlledBy: meetingEndConfirmation, title: "") { query in
            Button(Strings.cancel.text, role: .cancel) { query.answer(with: .cancel) }
            Button(Strings.Meeting.discard.text, role: .destructive) { query.answer(with: .discard) }
            Button(Strings.Meeting.save.text) { query.answer(with: .save) }
        } message: {
            Text(Strings.Meeting.endDialogMessage.text)
        }
        .environmentObject(scrumStore)
    }

    // Holds all the navigation destinations for any given `Path`
    @ViewBuilder @MainActor
    private func destination(for path: Path) -> some View {
        switch path {
        case .scrumDetail(let scrum):
            ScrumDetail.Managed(
                interface: .consume { handleScrumDetailInterface($0, for: scrum) },
                scrum: scrum,
                editScrum: editScrum
            )
            .targetStateSetter(scrumDetailTargetState)
        case .meeting(for: let scrum):
            Meeting.Managed(
                interface: .consume { handleMeetingInterface($0, for: scrum)},
                scrum: scrum,
                meetingEndConfirmation: meetingEndConfirmation
            )
        case .history(let history):
            HistoryDetail(
                interface: .consume { handleHistoryDetailInterface($0, for: history)},
                history: history
            )
        }
    }


    // MARK: - Interface Handler

    // Handles the interface from `ScrumList`
    @MainActor
    private func handleScrumListInterface(_ action: ScrumList.Action) {
        switch action {
        case .scrumTapped(let scrum):
            path.append(.scrumDetail(scrum))
        }
    }

    // Handles the interface from `ScrumDetail`
    @MainActor
    private func handleScrumDetailInterface(_ action: ScrumDetail.Action, for scrum: DailyScrum) {
        switch action {
        case .startMeetingButtonTapped:
            path.append(.meeting(for: scrum))
        case .historyTapped(let history):
            path.append(.history(history))
        }
    }

    // Handles the interface from the speech recording data provider `Meeting_SpeechRecording`
    @MainActor
    private func handleMeetingInterface(_ action: ManagedMeetingAction, for scrum: DailyScrum) {
        switch action {
        case .didCompleteMeeting:
            path.removeLast()
        }
    }

    // Handles the interface from `HistoryDetail`
    @MainActor
    private func handleHistoryDetailInterface(_ action: HistoryDetail.Action, for history: History) {
        switch action {
        case .noAction:
            break
        }
    }

    // Handles the interface from `EditScrum`
    @MainActor
    private func handleScrumCreationInterface(_ action: EditScrum.Action, query: QueryResolver<DailyScrum?>) {
        switch action {
        case .canceled:
            query.answer(with: nil)
        case .scrumSubmitted(let scrum):
            query.answer(with: scrum)
        }
    }

    // MARK: - State Configurations

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            break
        case .showScrum(let scrum):
            path = [.scrumDetail(scrum)]
        case .showScrumById(let id):
            if let scrum = scrumStore.scrums[id: id] {
                path = [.scrumDetail(scrum)]
            }
        case .startMeeting(for: let scrum):
            path = [.scrumDetail(scrum), .meeting(for: scrum)]
        case .startMeetingForScrumWithId(let id):
            if let scrum = scrumStore.scrums[id: id] {
                path = [.scrumDetail(scrum), .meeting(for: scrum)]
            }
        case .createScrum(draft: let draft):
            scrumListTargetState.set(.createScrum(draft: draft))
        case .editScrumOnDetailPage(let scrum):
            path = [.scrumDetail(scrum)]
            scrumDetailTargetState.set(.editScrum)
        case .editRandomScrumOnDetailPage:
            if let scrum = scrumStore.scrums.randomElement() {
                path = [.scrumDetail(scrum)]
                scrumDetailTargetState.set(.editScrum)
            }
        }
    }

    func urlOpenHandler(_ url: URL) -> TargetState? {
        if let targetState = DeepLinkHandler.targetState(for: url) {
            return targetState
        }
        return nil
    }
}

extension Root {

    enum MeetingEndAction: Hashable {
        case cancel
        case discard
        case save
    }

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

    enum Path: Hashable {
        case scrumDetail(DailyScrum)
        case meeting(for: DailyScrum)
        case history(History)
    }
}

