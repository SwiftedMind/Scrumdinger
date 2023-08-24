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
    /// The submodule inside Home that is displaying meeting detail screen.
    struct MeetingDetail: View {
        @EnvironmentObject private var scrumProvider: ScrumProvider
        @EnvironmentObject private var audioRecorderProvider: AudioRecorderProvider

        /// The id of the daily scrum for this meeting.
        var scrumId: DailyScrum.ID

        /// The daily scrum from the scrum provider.
        private var managedScrum: DailyScrum? {
            scrumProvider.scrums[id: scrumId]
        }

        /// A flag to indicate if the audio recorder is recording.
        @State private var isRecording: Bool = false

        var body: some View {
            NavigationStack {
                if let managedScrum {
                    MeetingDetailView(
                        interface: .consume(handleMeetingInterface),
                        scrum: managedScrum,
                        isRecording: audioRecorderProvider.isTranscribing
                    )
                    .toolbar { toolbarContent }
                    .navigationBarBackButtonHidden()
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .queryableConfirmationDialog(
                controlledBy: Router.shared.home.meetingEndConfirmation,
                title: ""
            ) { query in
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
                    queryMeetingEnd()
                }
            }
        }

        @MainActor
        private func queryMeetingEnd() {
            Task {
                do {
                    switch try await Router.shared.home.queryMeetingEndConfirmation() {
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
            guard let managedScrum else { return }
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

            Router.shared.dismissMeetingDetail()
        }
    }
}

struct Home_MeetingDetail_Previews: PreviewProvider {
    static var previews: some View {
        Home.MeetingDetail(scrumId: ScrumProvider.mock.scrums.first?.id ?? Mock.DailyScrum.example.id)
            .withMockProviders()
    }
}
