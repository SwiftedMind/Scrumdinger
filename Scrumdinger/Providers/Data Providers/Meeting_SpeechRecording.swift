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

private struct Meeting_SpeechRecording: Provider {
    @EnvironmentObject private var scrumStore: ScrumStore
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var interface: Interface<SpeechRecordingMeetingAction>
    var scrum: DailyScrum
    var meetingEndConfirmation: Queryable<Root.MeetingEndAction>.Trigger

    @State private var isRecording: Bool = false

    var entryView: some View {
        Meeting(
            interface: .consume(handleMeetingInterface),
            scrum: scrum,
            isRecording: speechRecognizer.canTranscribe
        )
    }

    func start() async {
        speechRecognizer.transcribe()
    }

    // MARK: - Interface Handler

    @MainActor
    private func handleMeetingInterface(_ action: Meeting.Action) {
        switch action {
        case .allSpeakersCompleted:
            finishMeeting(save: true)
        case .endButtonTapped:
            queryMeetingEnd(for: scrum)
        }
    }

    // MARK: - State Configurations

    func applyStateConfiguration(_ configuration: StateConfiguration) {
        switch configuration {
        case .reset:
            break
        }
    }

    // MARK: - Utility

    @MainActor
    private func finishMeeting(save: Bool) {
        speechRecognizer.stopTranscribing()
        var updatedScrum = scrum
        if save {
            let history = History(
                attendees: updatedScrum.attendees,
                lengthInMinutes: updatedScrum.lengthInMinutes,
                transcript: speechRecognizer.transcript
            )
            updatedScrum.history.insert(history, at: 0)
            scrumStore.saveScrum(updatedScrum)
        }
        interface.fire(.didCompleteMeeting)
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
}

extension Meeting_SpeechRecording {

    enum StateConfiguration {
        case reset
    }
}

enum SpeechRecordingMeetingAction: Hashable {
    case didCompleteMeeting
}

extension Meeting {

    static func speechRecording(
        interface: Interface<SpeechRecordingMeetingAction>,
        scrum: DailyScrum,
        meetingEndConfirmation: Queryable<Root.MeetingEndAction>.Trigger
    ) -> some View {
        Meeting_SpeechRecording(
            interface: interface,
            scrum: scrum,
            meetingEndConfirmation: meetingEndConfirmation
        )
    }
}
