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
import Models

struct ScrumListView: View {
    var interface: Interface<Action>
    var scrums: IdentifiedArrayOf<DailyScrum>

    var body: some View {
        List {
            ForEach(scrums) { scrum in
                Button {
                    interface.send(.scrumTapped(scrum))
                } label: {
                    CardView(scrum: scrum)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowBackground(scrum.theme.mainColor)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button(Strings.ScrumList.Item.LeadingAction.title.text) {
                        UIPasteboard.general.string = scrum.id.uuidString
                    }
                }
            }
            .onDelete { interface.send(.scrumsDeleted(atOffsets: $0)) }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: scrums)
    }
}

extension ScrumListView {
    enum Action: Hashable {
        case scrumTapped(DailyScrum)
        case scrumsDeleted(atOffsets: IndexSet)
    }
}

// MARK: - Preview

private struct PreviewState {
    var scrums: IdentifiedArrayOf<DailyScrum> = Mock.DailyScrum.all
}

struct ScrumListView_Previews: PreviewProvider {
    static var previews: some View {
        StateHosting(PreviewState()) { $state in
            ScrumListView(interface: .consume({ action in
                switch action {
                case .scrumTapped(let scrum):
                    print("Scrum tapped: »\(scrum.id)«")
                case .scrumsDeleted(atOffsets: let offsets):
                    state.scrums.remove(atOffsets: offsets)
                }
            }), scrums: state.scrums)
            .overlay(alignment: .bottom) {
                HStack {
                    Button("Clear List") {
                        state.scrums.removeAll()
                    }
                    .disabled(state.scrums.isEmpty)
                    Button("Fill List") {
                        state.scrums = Mock.DailyScrum.all
                    }
                    .disabled(!state.scrums.isEmpty)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
