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

import SwiftUI
import Puddles
import PreviewDebugTools
import IdentifiedCollections

struct MeetingView: View {

    var interface: Interface<Action>
    var state: ViewState

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(state.theme.mainColor)
            VStack {
                MeetingHeaderView(
                    secondsElapsed: state.secondsElapsed,
                    secondsRemaining: state.secondsRemaining,
                    theme: state.theme
                )
                MeetingTimerView(
                    speakers: state.speakers,
                    isRecording: state.isRecording,
                    theme: state.theme
                )
                MeetingFooterView(speakers: state.speakers) {
                    interface.fire(.speakerSkipped)
                }
            }
        }
        .padding()
        .foregroundColor(state.theme.accentColor)
    }
}

extension MeetingView {

    struct Speaker: Identifiable {
        let id = UUID()
        let name: String
        var isCompleted: Bool = false

        static var mock: Self {
            .init(name: "James", isCompleted: false)
        }

        static var mockList: IdentifiedArrayOf<MeetingView.Speaker> {
            [.init(name: "Kim"), .init(name: "James"), .init(name: "Naomi"), .init(name: "Camina"), .init(name: "Bill")]
        }
    }

    struct ViewState {
        var theme: Theme
        var speakers: IdentifiedArrayOf<MeetingView.Speaker>
        var secondsElapsed: Int
        var secondsRemaining: Int
        var isRecording: Bool

        static var mock: Self {
            .init(
                theme: .bubblegum,
                speakers: MeetingView.Speaker.mockList,
                secondsElapsed: 0,
                secondsRemaining: 30,
                isRecording: true
            )
        }
    }

    enum Action {
        case speakerSkipped
    }
}

struct MeetingView_Previews: PreviewProvider {
    private static var task: Task<Void, Never>?
    static var previews: some View {
        NavigationStack {
            Preview(MeetingView.init, state: .mock) { action, $state in

            }
            .overlay { $state in
                HStack {
                    DebugButton("Start Meeting") {
                        task?.cancel()
                        task = Task {
                            var index = 0
                            while true {
                                do {
                                    try await Task.sleep(for: .seconds(1))
                                    state.secondsElapsed += 1
                                    state.secondsRemaining -= 1

                                    if state.secondsElapsed.isMultiple(of: 5), index < state.speakers.count {
                                        state.speakers[index].isCompleted = true
                                        index += 1
                                    }
                                } catch {
                                    break
                                }
                            }
                        }
                    }
                    DebugButton("Stop Meeting") {
                        task?.cancel()
                    }
                    DebugButton("Reset") {
                        task?.cancel()
                        state = .mock
                    }
                }
                .dynamicTypeSize(...(.accessibility1))
            }
        }
        .preferredColorScheme(.dark)
    }
}

