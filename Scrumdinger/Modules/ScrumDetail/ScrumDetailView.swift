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
import Models

struct ScrumDetailView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var interface: Interface<Action>
    var state: ViewState

    var body: some View {
        List {
            meetingInfoSection
            attendeesSection
            historySection
            footerSection
        }
    }

    @ViewBuilder @MainActor
    private var footerSection: some View {
        Section {
            Text(state.scrum.id.uuidString)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        } header: {
            VStack(alignment: .leading) {
                Text(Strings.ScrumDetail.FooterSection.Title._1.text)
                Text(Strings.ScrumDetail.FooterSection.Title._2.text).font(.caption2)
            }
        }
    }

    @ViewBuilder @MainActor
    private var meetingInfoSection: some View {
        Section {
            DisclosureButton {
                interface.fire(.startMeetingButtonTapped)
            } content: {
                if dynamicTypeSize.isAccessibilitySize {
                    Text(Strings.ScrumDetail.InfoSection.startButton.text)
                        .font(.headline)
                        .foregroundColor(.accentColor)
                } else {
                    Label(Strings.ScrumDetail.InfoSection.startButton.text, systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }
            LabeledContent {
                Text(Strings.ScrumDetail.InfoSection.Length.value(state.scrum.lengthInMinutes))
            } label: {
                if dynamicTypeSize.isAccessibilitySize {
                    Text(Strings.ScrumDetail.InfoSection.Length.title.text)
                } else {
                    Label(Strings.ScrumDetail.InfoSection.Length.title.text, systemImage: "clock")
                }
            }
            .accessibilityElement(children: .combine)
            LabeledContent {
                Text(state.scrum.theme.name)
                    .padding(4)
                    .foregroundColor(state.scrum.theme.accentColor)
                    .background(state.scrum.theme.mainColor)
                    .cornerRadius(4)
            } label: {
                if dynamicTypeSize.isAccessibilitySize {
                    Text(Strings.ScrumDetail.InfoSection.theme.text)
                } else {
                    Label(Strings.ScrumDetail.InfoSection.theme.text, systemImage: "paintpalette")
                }
            }
            .accessibilityElement(children: .combine)
        } header: {
            Text(Strings.ScrumDetail.InfoSection.title.text)
        }
    }

    @ViewBuilder @MainActor
    private var attendeesSection: some View {
        Section {
            ForEach(state.scrum.attendees) { attendee in
                if dynamicTypeSize.isAccessibilitySize {
                    Text(attendee.name)
                } else {
                    Label(attendee.name, systemImage: "person")
                }
            }
        } header: {
            Text(Strings.ScrumDetail.AttendeesSection.title.text)
        }
    }

    @ViewBuilder @MainActor
    private var historySection: some View {
        Section {
            if state.scrum.history.isEmpty {
                if dynamicTypeSize.isAccessibilitySize {
                    Text("No meetings yet")
                } else {
                    Label("No meetings yet", systemImage: "calendar.badge.exclamationmark")
                }
            }
            ForEach(state.scrum.history) { history in
                DisclosureButton {
                    interface.fire(.historyTapped(history))
                } content: {
                    HStack {
                        if !dynamicTypeSize.isAccessibilitySize {
                            Image(systemName: "calendar")
                        }
                        Text(history.date, style: .date)
                    }
                }
            }
        } header: {
            Text(Strings.ScrumDetail.HistorySection.title.text)
        }
    }
}

extension ScrumDetailView {
    struct ViewState {

        var scrum: DailyScrum

        static var mock: Self {
            .init(scrum: .mock)
        }
    }

    enum Action {
        case historyTapped(History)
        case startMeetingButtonTapped
    }
}

struct ScrumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Preview(ScrumDetailView.init, state: .mock) { action, $state in

            }
            .navigationTitle(DailyScrum.mock.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Strings.edit.text) {}
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

