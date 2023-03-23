/*
 See LICENSE folder for this sample’s licensing information.
 */


import SwiftUI
import Puddles
import PreviewDebugTools

struct HistoryDetailView: View {

    var interface: Interface<Action>
    var state: ViewState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Divider()
                    .padding(.bottom)
                Text("Attendees")
                    .font(.headline)
                Text(state.history.attendeeString)
                if let transcript = state.history.transcript {
                    Text("Transcript")
                        .font(.headline)
                        .padding(.top)
                    Text(transcript)
                }
            }
        }
        .navigationTitle(Text(state.history.date, style: .date))
        .padding()
    }
}

extension HistoryDetailView {
    struct ViewState {

        var history: History

        static var mock: Self {
            .init(history: .mock)
        }
    }

    enum Action {
        case noAction
    }
}

struct HistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Preview(HistoryDetailView.init, state: .mock) { action, $state in

            }
        }
        .preferredColorScheme(.dark)
    }
}

private extension History {
    var attendeeString: String {
        ListFormatter.localizedString(byJoining: attendees.map { $0.name })
    }
}
