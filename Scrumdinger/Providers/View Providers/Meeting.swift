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

//@MainActor
//final class Timer: ObservableObject {
//
//    var scrum: DailyScrum?
//    var interface: Interface<Meeting.Action>?
//
//    @Published var speakers: IdentifiedArrayOf<MeetingView.Speaker> = []
//    @Published var secondsElapsed: Int = 0
//    @Published var secondsRemaining: Int = 0
//    @Published var isRecording: Bool = false
//    @Published var meetingTask: Task<Void, Never>?
//    @Published var currentSpeakerIndex: Int = 0
//
//    private var secondsPerSpeaker: Int {
//        guard let scrum else { return 0 }
//        return (scrum.lengthInMinutes * 60) / speakers.count
//    }
//
//    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
//
//    func reset(with scrum: DailyScrum) {
//        meetingTask?.cancel()
//        secondsElapsed = 0
//        currentSpeakerIndex = 0
//        secondsRemaining = scrum.lengthInMinutes * 60
//        speakers = scrum.attendees.speakers
//        startMeetingProgressUpdates()
//    }
//
//    func startMeetingProgressUpdates() {
//        guard let scrum else { return }
//        meetingTask?.cancel()
//        meetingTask = Task {
//            do {
//                var startDate = Date()
//                while !Task.isCancelled {
//                    try await Task.sleep(for: .seconds(1))
//                    guard currentSpeakerIndex < speakers.count else { break }
//
//                    let secondsForCurrentSpeaker = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
//
//                    secondsElapsed = currentSpeakerIndex * secondsPerSpeaker + secondsForCurrentSpeaker
//                    secondsRemaining = max(0, scrum.lengthInMinutes * 60 - secondsElapsed)
//
//                    guard secondsForCurrentSpeaker <= secondsPerSpeaker else {
//                        nextSpeaker()
//                        startDate = Date()
//                        continue
//                    }
//                }
//            } catch {}
//        }
//    }
//
//    func nextSpeaker() {
//        guard let scrum else { return }
//        player.seek(to: .zero)
//        player.play()
//        speakers[currentSpeakerIndex].isCompleted = true
//
//        currentSpeakerIndex += 1
//
//        // Cancel if all speakers have spoken
//        guard currentSpeakerIndex < speakers.count else {
//            interface?.fire(.allSpeakersCompleted)
//            meetingTask?.cancel()
//            return
//        }
//
//        secondsElapsed = currentSpeakerIndex * secondsPerSpeaker
//        secondsRemaining = scrum.lengthInMinutes * 60 - secondsElapsed
//    }
//
//    func skipSpeaker() {
//        meetingTask?.cancel()
//        nextSpeaker()
//        startMeetingProgressUpdates()
//    }
//}

struct Meeting: Provider {

    var interface: Interface<Action>
    var scrum: DailyScrum
    var isRecording: Bool

    @State private var speakers: IdentifiedArrayOf<MeetingView.Speaker> = []
    @State private var secondsElapsed: Int = 0
    @State private var secondsRemaining: Int = 0

    @State private var meetingTask: Task<Void, Never>?
    @State private var currentSpeakerIndex: Int = 0

    @State private var meeting: History = History(attendees: [])

    private var secondsPerSpeaker: Int {
        (scrum.lengthInMinutes * 60) / speakers.count
    }

    private var player: AVPlayer { AVPlayer.sharedDingPlayer }

    var entryView: some View {
        MeetingView(
            interface: .consume(handleViewInterface),
            state: .init(
                theme: scrum.theme,
                speakers: speakers,
                secondsElapsed: secondsElapsed,
                secondsRemaining: secondsRemaining,
                isRecording: isRecording
            )
        )
        .toolbar { toolbarContent }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: scrum, perform: reset)
    }

    func start() async {
        reset(with: scrum)
        startMeetingProgressUpdates()
    }

    func stop() {
        meetingTask?.cancel()
    }

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            reset(with: scrum)
        }
    }

    // MARK: - Interface Handler

    @MainActor
    private func handleViewInterface(_ action: MeetingView.Action) {
        switch action {
        case .speakerSkipped:
            skipSpeaker()
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
            interface.fire(.allSpeakersCompleted)
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

    // MARK: - Utility

    @ToolbarContentBuilder @MainActor
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(Strings.end.text) {
                interface.fire(.endButtonTapped)
            }
        }
    }
}

extension Meeting {

    enum TargetState {
        case reset
    }

    enum Action: Hashable {
        case allSpeakersCompleted
        case endButtonTapped
    }
}

