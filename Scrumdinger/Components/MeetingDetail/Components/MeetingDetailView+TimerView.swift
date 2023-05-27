/*
See LICENSE folder for this sample’s licensing information.
*/

import SwiftUI
import IdentifiedCollections
import Models

extension MeetingDetailView {
    struct TimerView: View {
        let speakers: IdentifiedArrayOf<MeetingDetailView.Speaker>
        let isRecording: Bool
        let theme: Theme

        private var currentSpeaker: String {
            speakers.first(where: { !$0.isCompleted })?.name ?? "Someone"
        }

        var body: some View {
            Circle()
                .strokeBorder(lineWidth: 24)
                .overlay {
                    VStack {
                        Text(currentSpeaker)
                            .font(.title)
                        Text("is speaking")
                        Image(systemName: isRecording ? "mic" : "mic.slash")
                            .font(.title)
                            .padding(.top)
                            .accessibilityLabel(isRecording ? "with transcription" : "without transcription")
                    }
                    .dynamicTypeSize(...(.accessibility1))
                    .accessibilityElement(children: .combine)
                    .foregroundStyle(theme.accentColor)
                }
                .overlay  {
                    ForEach(speakers) { speaker in
                        if speaker.isCompleted, let index = speakers.firstIndex(where: { $0.id == speaker.id }) {
                            SpeakerArc(speakerIndex: index, totalSpeakers: speakers.count)
                                .rotation(Angle(degrees: -90))
                                .stroke(theme.mainColor, lineWidth: 12)
                        }
                    }
                }
                .padding(.horizontal)
        }
    }
}

struct MeetingDetailView_TimerView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingDetailView.TimerView(speakers: MeetingDetailView.Speaker.mockList, isRecording: true, theme: .yellow)
    }
}
