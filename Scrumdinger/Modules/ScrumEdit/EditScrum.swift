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

struct EditScrum: Provider {

    var interface: Interface<Action>
    @State private var draft: DailyScrum
    @State private var newAttendeeName: String = ""

    private var commitButtonTitle: String

    init(interface: Interface<Action>, scrum: DailyScrum = .draft, isNew: Bool = true) {
        self.interface = interface
        self._draft = .init(initialValue: scrum)
        commitButtonTitle = isNew ? Strings.add.text : Strings.save.text
    }
    var entryView: some View {
        NavigationStack {
            EditScrumView(
                interface: .consume(handleViewInterface),
                state: .init(
                    name: draft.title,
                    length: Double(draft.lengthInMinutes),
                    theme: draft.theme,
                    attendees: draft.attendees,
                    newAttendeeName: newAttendeeName
                )
            )
            .toolbar { toolbarContent }
        }
    }

    // MARK: - Interface Handler

    private func handleViewInterface(_ action: EditScrumView.Action) {
        switch action {
        case .nameChanged(let newValue):
            draft.title = newValue
        case .newAttendeeNameChanged(let newValue):
            newAttendeeName = newValue
        case .attendeesDeleted(atOffsets: let offsets):
            draft.attendees.remove(atOffsets: offsets)
        case .lengthChanged(let newValue):
            draft.lengthInMinutes = Int(newValue)
        case .themeChanged(let newValue):
            draft.theme = newValue
        case .submittedAttendeeName:
            draft.attendees.append(.init(name: newAttendeeName))
            newAttendeeName = ""
        }
    }

    // MARK: - State Configurations

    @MainActor
    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            break
        }
    }

    // MARK: - Utility

    @ToolbarContentBuilder @MainActor
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(Strings.dismiss.text, role: .cancel) {
                interface.fire(.canceled)
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(commitButtonTitle) {
                interface.fire(.scrumSubmitted(draft))
            }
            .disabled(draft.title.isEmpty)
            .bold()
        }
    }
}

extension EditScrum {

    enum TargetState {
        case reset
    }

    enum Action: Hashable {
        case canceled
        case scrumSubmitted(DailyScrum)
    }
}

