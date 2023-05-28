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
import AVFoundation
import Models

struct MeetingDetailView: View {

    var interface: Interface<Action>
    var scrum: DailyScrum
    var isRecording: Bool

    @State private var speakers: IdentifiedArrayOf<Speaker> = []
    @State private var secondsElapsed: Int = 0
    @State private var secondsRemaining: Int = 0
    @State private var meetingTask: Task<Void, Never>?
    @State private var currentSpeakerIndex: Int = 0
    @State private var meeting: History = History(attendees: [])

    private var secondsPerSpeaker: Int {
        (scrum.lengthInMinutes * 60) / speakers.count
    }

    private var player: AVPlayer { AVPlayer.sharedDingPlayer }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(scrum.theme.mainColor)
            VStack {
                HeaderView(
                    secondsElapsed: secondsElapsed,
                    secondsRemaining: secondsRemaining,
                    theme: scrum.theme
                )
                TimerView(
                    speakers: speakers,
                    isRecording: isRecording,
                    theme: scrum.theme
                )
                FooterView(speakers: speakers) {
                    nextSpeaker()
                }
            }
        }
        .padding()
        .foregroundColor(scrum.theme.accentColor)
        .onChange(of: scrum, perform: reset)
        .onFirstAppear {
            reset(with: scrum)
            startMeetingProgressUpdates()
        }
        .onDisappear {
            meetingTask?.cancel()
        }
    }

    @MainActor
    private func reset(with scrum: DailyScrum) {
        meetingTask?.cancel()
        meeting = .init(attendees: scrum.attendees, lengthInMinutes: scrum.lengthInMinutes, transcript: nil)
        secondsElapsed = 0
        currentSpeakerIndex = 0
        secondsRemaining = scrum.lengthInMinutes * 60
        speakers = scrum.attendees.speakers
        startMeetingProgressUpdates()
    }

    // MARK: - Meeting Progress

    @MainActor
    private func startMeetingProgressUpdates() {
        meetingTask?.cancel()
        meetingTask = Task {
            do {
                var startDate = Date()
                while !Task.isCancelled {
                    try await Task.sleep(for: .seconds(1))
                    guard currentSpeakerIndex < speakers.count else { break }

                    let secondsForCurrentSpeaker = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)

                    secondsElapsed = currentSpeakerIndex * secondsPerSpeaker + secondsForCurrentSpeaker
                    secondsRemaining = max(0, scrum.lengthInMinutes * 60 - secondsElapsed)

                    guard secondsForCurrentSpeaker <= secondsPerSpeaker else {
                        nextSpeaker()
                        startDate = Date()
                        continue
                    }
                }
            } catch {}
        }
    }

    @MainActor
    private func nextSpeaker() {
        player.seek(to: .zero)
        player.play()
        speakers[currentSpeakerIndex].isCompleted = true

        currentSpeakerIndex += 1

        // Finish if all speakers have spoken
        guard currentSpeakerIndex < speakers.count else {
            interface.send(.allSpeakersCompleted)
            meetingTask?.cancel()
            return
        }

        secondsElapsed = currentSpeakerIndex * secondsPerSpeaker
        secondsRemaining = scrum.lengthInMinutes * 60 - secondsElapsed
    }

    @MainActor
    private func skipSpeaker() {
        meetingTask?.cancel()
        nextSpeaker()
        startMeetingProgressUpdates()
    }
}

extension MeetingDetailView {

    struct Speaker: Identifiable {
        let id = UUID()
        let name: String
        var isCompleted: Bool = false

        static var mock: Self {
            .init(name: "James", isCompleted: false)
        }

        static var mockList: IdentifiedArrayOf<Speaker> {
            [.init(name: "Kim"), .init(name: "James"), .init(name: "Naomi"), .init(name: "Camina"), .init(name: "Bill")]
        }
    }

    enum Action: Hashable {
        case allSpeakersCompleted
    }
}

// MARK: - Preview

private struct PreviewState {
    var scrum: DailyScrum = .mock
    var isRecording: Bool = true
}

struct MeetingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Preview(state: PreviewState(), interfaceAction: MeetingDetailView.Action.self) { interface, $state in
            MeetingDetailView(interface: interface, scrum: state.scrum, isRecording: state.isRecording)
        } actionHandler: { action, $state in
            switch action {
            case .allSpeakersCompleted:
                print("All Speakers have spoken")
            }
        }
    }
}
