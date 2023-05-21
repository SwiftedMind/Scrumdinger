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

struct MeetingPage: Provider {
    @EnvironmentObject private var router: Feature.HomeRouter
    @EnvironmentObject private var scrums: Feature.Scrums
    @EnvironmentObject private var audioRecorder: Feature.AudioRecorder

    /// The managed scrum. Its identifier will be used to always display the up-to-date version of this scrum from the `ScrumStore`.
    var scrum: DailyScrum

    @Queryable<Void, MeetingEndAction> private var meetingEndConfirmation

    private var managedScrum: DailyScrum {
        scrums.all[id: scrum.id] ?? scrum
    }

    @State private var isRecording: Bool = false

    var entryView: some View {
        Meeting(
            interface: .consume(handleMeetingInterface),
            scrum: managedScrum,
            isRecording: audioRecorder.isTranscribing
        )
        .toolbar { toolbarContent }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .queryableConfirmationDialog(controlledBy: meetingEndConfirmation, title: "") { query in
            Button(Strings.cancel.text, role: .cancel) { query.answer(with: .cancel) }
            Button(Strings.Meeting.discard.text, role: .destructive) { query.answer(with: .discard) }
            Button(Strings.Meeting.save.text) { query.answer(with: .save) }
        } message: {
            Text(Strings.Meeting.endDialogMessage.text)
        }
    }

    func start() async {
        do {
            try await audioRecorder.startTranscription()
        } catch {
            print("Error »\(error.localizedDescription)«")
        }
    }

    // MARK: - Interface Handler

    @MainActor
    private func handleMeetingInterface(_ action: Meeting.Action) {
        switch action {
        case .allSpeakersCompleted:
            finishMeeting(save: true)
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
            Button(Strings.end.text) {
                queryMeetingEnd(for: scrum)
            }
        }
    }

    @MainActor
    private func queryMeetingEnd(for scrum: DailyScrum) {
        Task {
            do {
                switch try await meetingEndConfirmation.query() {
                case .cancel:
                    break // Do nothing
                case .discard:
                    finishMeeting(save: false)
                case .save:
                    finishMeeting(save: true)
                }
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    private func finishMeeting(save: Bool) {
        let transcript = audioRecorder.finishTranscription()
        var updatedScrum = managedScrum
        if save {
            let history = History(
                attendees: updatedScrum.attendees,
                lengthInMinutes: updatedScrum.lengthInMinutes,
                transcript: transcript
            )
            updatedScrum.history.insert(history, at: 0)
            scrums.save(updatedScrum)
        }

        router.pop()
    }
}

extension MeetingPage {

    enum MeetingEndAction: Hashable {
        case cancel
        case discard
        case save
    }

    enum TargetState {
        case reset
    }
}

struct MeetingPage_Previews: PreviewProvider {
    static var previews: some View {
        MeetingPage(scrum: .mock)
            .withFeatures(.mock())
    }
}
