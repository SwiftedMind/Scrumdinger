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

extension ScrumDetail {

    /// A `ScrumDetail` view whose scrum input is automatically managed and updated via the `ScrumStore`.
    ///
    /// - Note: If the provided scrum is not in the `ScrumStore`, it will simply be passed along to the `ScrumDetail` view without being managed.
    struct Managed: Provider {

        /// The scrum detail interface.
        var interface: Interface<ScrumDetail.Action>

        /// The managed scrum. Its identifier will be used to always display the up-to-date version of this scrum from the `ScrumStore`.
        var scrum: DailyScrum

        /// The queryable that provides us with the means to edit a scrum.
        var editScrum: Queryable<DailyScrum, DailyScrum?>.Trigger

        private var managedScrum: DailyScrum {
            scrumStore.scrums[id: scrum.id] ?? scrum
        }

        @EnvironmentObject private var scrumStore: ScrumStore
        @TargetStateSetter<ScrumDetail.TargetState> private var scrumDetailTargetState

        var entryView: some View {
            ScrumDetail(
                interface: interface,
                dataInterface: .consume(handleDataInterface),
                scrum: managedScrum
            )
            .targetStateSetter(scrumDetailTargetState)
        }

        @MainActor
        private func handleDataInterface(_ action: ScrumDetail.DataAction) {
            switch action {
            case .editButtonTapped:
                queryEditScrum()
            }
        }

        // MARK: - State Configurations

        func applyTargetState(_ state: TargetState) {
            switch state {
            case .editScrum:
                queryEditScrum()
            }
        }

        // MARK: - Queries

        @MainActor
        private func queryEditScrum() {
            Task {
                do {
                    if let newScrum = try await editScrum.query(with: scrum) {
                        scrumStore.saveScrum(newScrum)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension ScrumDetail.Managed {
    enum TargetState {
        case editScrum
    }
}
