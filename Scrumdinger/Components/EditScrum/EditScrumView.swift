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

struct EditScrumView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var interface: Interface<Action>

    @Binding var draft: DailyScrum
    @State private var newAttendeeName: String = ""
    @FocusState private var focusedField: Field?


    private var layout: AnyLayout {
        dynamicTypeSize >= .accessibility2 ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())
    }

    var body: some View {
        List {
            infoSection
            attendeesSection
        }
        .animation(.default, value: draft.attendees)
        .onAppear { focusedField = .scrumName }
    }

    @ViewBuilder @MainActor
    private var infoSection: some View {
        Section {
            TextField(
                Strings.EditMeeting.InfoSection.NameField.placeholder.text,
                text: $draft.title
            )
            .focused($focusedField, equals: .scrumName)
            .onSubmit { focusedField = nil }
            .submitLabel(.next)
            layout {
                Slider(
                    value: $draft.lengthDouble,
                    in: 5...30
                )
                Text(Strings.EditMeeting.InfoSection.LengthSlider.value(Int(draft.lengthInMinutes)))
            }
            Picker(
                Strings.EditMeeting.InfoSection.ThemePicker.title.text,
                selection: $draft.theme
            ) {
                ForEach(Theme.allCases) { theme in
                    if dynamicTypeSize.isAccessibilitySize {
                        Text(theme.name)
                            .padding(4)
                            .tag(theme)
                    } else {
                        Label(theme.name, systemImage: "paintpalette")
                            .padding(4)
                            .tag(theme)
                    }
                }
            }
        } header: {
            Text(Strings.EditMeeting.InfoSection.title.text)
        }
    }

    @ViewBuilder @MainActor
    private var attendeesSection: some View {
        Section {
            ForEach(draft.attendees) { attendee in
                Text(attendee.name)
            }
            .onDelete(perform: { draft.attendees.remove(atOffsets: $0) })
            HStack {
                TextField(
                    Strings.EditMeeting.AttendeesSection.AttendeesField.placeholder.text,
                    text: $newAttendeeName
                )
                .focused($focusedField, equals: .attendeeName)
                .onSubmit {
                    submitAttendee()
                }
                Button {
                    submitAttendee()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .accessibilityLabel(Strings.EditMeeting.AttendeesSection.AttendeesField.SubmitButton.accessibilityLabel.text)
                }
                .disabled(newAttendeeName.isEmpty)
            }
        } header: {
            Text(Strings.EditMeeting.AttendeesSection.title.text)
        }
    }

    // MARK: - Helper

    private func submitAttendee() {
        draft.attendees.append(.init(name: newAttendeeName))
        newAttendeeName = ""
        focusedField = .attendeeName
    }
}

extension EditScrumView {

    enum Action: Hashable {
        case noAction
    }

    enum Field: Hashable {
        case scrumName
        case attendeeName
    }
}

private extension DailyScrum {
    var lengthDouble: Double {
        get { Double(lengthInMinutes) }
        set { lengthInMinutes = Int(newValue) }
    }
}
