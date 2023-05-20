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
import Models

struct EditScrumView: View {
    @FocusState private var focusedField: Field?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var interface: Interface<Action>
    var state: ViewState

    private var layout: AnyLayout {
        dynamicTypeSize >= .accessibility2 ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())
    }

    var body: some View {
        List {
            infoSection
            attendeesSection
        }
        .animation(.default, value: state.attendees)
        .onAppear { focusedField = .scrumName }
    }

    @ViewBuilder @MainActor
    private var infoSection: some View {
        Section {
            TextField(
                Strings.EditMeeting.InfoSection.NameField.placeholder.text,
                text: interface.binding(state.name, to: { .nameChanged($0) })
            )
            .focused($focusedField, equals: .scrumName)
            .onSubmit { focusedField = nil }
            .submitLabel(.next)
            layout {
                Slider(
                    value: interface.binding(state.length, to: { .lengthChanged($0) }),
                    in: 5...30
                )
                Text(Strings.EditMeeting.InfoSection.LengthSlider.value(Int(state.length)))
            }
            Picker(
                Strings.EditMeeting.InfoSection.ThemePicker.title.text,
                selection: interface.binding(state.theme, to: { .themeChanged($0) })
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
            ForEach(state.attendees) { attendee in
                Text(attendee.name)
            }
            .onDelete(perform: { interface.fire(.attendeesDeleted(atOffsets: $0)) })
            HStack {
                TextField(
                    Strings.EditMeeting.AttendeesSection.AttendeesField.placeholder.text,
                    text: interface.binding(state.newAttendeeName, to: { .newAttendeeNameChanged($0) })
                )
                .focused($focusedField, equals: .attendeeName)
                .onSubmit {
                    interface.fire(.submittedAttendeeName)
                    focusedField = .attendeeName
                }
                Button {
                    interface.fire(.submittedAttendeeName)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .accessibilityLabel(Strings.EditMeeting.AttendeesSection.AttendeesField.SubmitButton.accessibilityLabel.text)
                }
                .disabled(state.newAttendeeName.isEmpty)
            }
        } header: {
            Text(Strings.EditMeeting.AttendeesSection.title.text)
        }
    }
}

extension EditScrumView {

    enum Field: Hashable {
        case scrumName
        case attendeeName
    }

    struct ViewState {

        var name: String
        var length: Double
        var theme: Theme
        var attendees: IdentifiedArrayOf<DailyScrum.Attendee>
        var newAttendeeName: String

        static var mock: Self {
            .init(
                name: "Planning",
                length: 5,
                theme: .bubblegum,
                attendees: [.init(name: "James")],
                newAttendeeName: ""
            )
        }
    }

    enum Action {
        case nameChanged(String)
        case newAttendeeNameChanged(String)
        case attendeesDeleted(atOffsets: IndexSet)
        case lengthChanged(Double)
        case themeChanged(Theme)
        case submittedAttendeeName
    }
}

struct EditScrumView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Preview(EditScrumView.init, state: .mock) { action, $state in
                switch action {
                case let .nameChanged(newValue):
                    state.name = newValue
                case let .lengthChanged(newValue):
                    state.length = newValue
                case let .newAttendeeNameChanged(newValue):
                    state.newAttendeeName = newValue
                case .submittedAttendeeName:
                    state.attendees.append(.init(name: state.newAttendeeName))
                case .attendeesDeleted(atOffsets: let offsets):
                    state.attendees.remove(atOffsets: offsets)
                case .themeChanged(let newTheme):
                    state.theme = newTheme
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Strings.dismiss.text) { }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Strings.add.text) { }
                        .bold()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

