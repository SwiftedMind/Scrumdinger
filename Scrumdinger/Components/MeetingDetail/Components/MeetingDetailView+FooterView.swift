/*
See LICENSE folder for this sample’s licensing information.
*/

import SwiftUI
import IdentifiedCollections

extension MeetingDetailView {
    struct FooterView: View {
        let speakers: IdentifiedArrayOf<MeetingDetailView.Speaker>
        var skipAction: ()->Void

        private var speakerNumber: Int? {
            guard let index = speakers.firstIndex(where: { !$0.isCompleted }) else { return nil}
            return index + 1
        }
        private var isLastSpeaker: Bool {
            return speakers.dropLast().allSatisfy { $0.isCompleted }
        }
        private var speakerText: String {
            guard let speakerNumber = speakerNumber else { return "No more speakers" }
            return "Speaker \(speakerNumber) of \(speakers.count)"
        }

        var body: some View {
            VStack {
                HStack {
                    if isLastSpeaker {
                        Text("Last Speaker")
                    } else {
                        Text(speakerText)
                        Spacer()
                        Button(action: skipAction) {
                            Image(systemName: "forward.fill")
                        }
                        .accessibilityLabel("Next speaker")
                    }
                }
            }
            .padding([.bottom, .horizontal])
        }
    }
}

struct MeetingDetailView_FooterView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingDetailView.FooterView(speakers: .init(uniqueElements: MeetingDetailView.Speaker.mockList), skipAction: {})
    }
}
