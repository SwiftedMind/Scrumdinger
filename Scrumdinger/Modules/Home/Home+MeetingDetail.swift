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

extension Home {
    struct MeetingDetail: Provider {
        @EnvironmentObject private var router: HomeRouter
        @EnvironmentObject private var scrumProvider: ScrumProvider
        @EnvironmentObject private var audioRecorderProvider: AudioRecorderProvider

        /// The managed scrum. Its identifier will be used to always display the up-to-date version of this scrum from the `ScrumStore`.
        var scrum: DailyScrum

        @Queryable<Void, MeetingEndAction> private var meetingEndConfirmation

        private var managedScrum: DailyScrum {
            scrumProvider.scrums[id: scrum.id] ?? scrum
        }

        @State private var isRecording: Bool = false

        var entryView: some View {
            MeetingDetailView(
                interface: .consume(handleMeetingInterface),
                scrum: managedScrum,
                isRecording: audioRecorderProvider.isTranscribing
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
            .task { await tryStartingTranscription() }
        }

        @MainActor
        func tryStartingTranscription() async {
            do {
                try await audioRecorderProvider.startTranscription()
            } catch {
                print("Error »\(error.localizedDescription)«")
            }
        }

        // MARK: - Interface Handler

        @MainActor
        private func handleMeetingInterface(_ action: MeetingDetailView.Action) {
            switch action {
            case .allSpeakersCompleted:
                finishMeeting(save: true)
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
            let transcript = audioRecorderProvider.finishTranscription()
            var updatedScrum = managedScrum
            if save {
                let history = History(
                    attendees: updatedScrum.attendees,
                    lengthInMinutes: updatedScrum.lengthInMinutes,
                    transcript: transcript
                )
                updatedScrum.history.insert(history, at: 0)
                scrumProvider.save(updatedScrum)
            }

            router.pop()
        }
    }
}

extension Home.MeetingDetail {

    enum MeetingEndAction: Hashable {
        case cancel
        case discard
        case save
    }

    enum TargetState {
        case reset
    }
}

struct Home_MeetingDetail_Previews: PreviewProvider {
    static var previews: some View {
        Home.MeetingDetail(scrum: .mock)
            .environmentObject(HomeRouter())
            .withProviders(.mock())
    }
}
