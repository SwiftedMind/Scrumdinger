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

@propertyWrapper
public struct MyWrapper {

    private var trigger: Int
    public var wrappedValue: Int {
        trigger
    }

    public init(wrappedValue trigger: Int = 0) {
        self.trigger = trigger
    }

    /// A type that is capable of triggering and cancelling a query.
    public struct Trigger {
    }
}

extension Meeting {
    struct Managed: Provider {
        @EnvironmentObject private var scrumStore: ScrumStore
        @StateObject private var speechRecognizer = SpeechRecognizer()

        var interface: Interface<ManagedMeetingAction>

        /// The managed scrum. Its identifier will be used to always display the up-to-date version of this scrum from the `ScrumStore`.
        var scrum: DailyScrum
        var meetingEndConfirmation: Queryable<Void, Root.MeetingEndAction>.Trigger

        private var managedScrum: DailyScrum {
            scrumStore.scrums[id: scrum.id] ?? scrum
        }

        @State private var isRecording: Bool = false

        var entryView: some View {
            Meeting(
                interface: .consume(handleMeetingInterface),
                scrum: managedScrum,
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

        func applyTargetState(_ state: TargetState) {
            switch state {
            case .reset:
                break
            }
        }

        // MARK: - Utility

        @MainActor
        private func finishMeeting(save: Bool) {
            speechRecognizer.stopTranscribing()
            var updatedScrum = managedScrum
            if save {
                let history = History(
                    attendees: updatedScrum.attendees,
                    lengthInMinutes: updatedScrum.lengthInMinutes,
                    transcript: speechRecognizer.transcript
                )
                updatedScrum.history.insert(history, at: 0)
                print("Saving: Previous: \(managedScrum.history.count), new \(updatedScrum.history.count)")
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
}

extension Meeting.Managed {
    enum TargetState {
        case reset
    }
}

enum ManagedMeetingAction: Hashable {
    case didCompleteMeeting
}
