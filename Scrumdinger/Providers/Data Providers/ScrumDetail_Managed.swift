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

private struct ScrumDetail_Managed: Provider {
    @EnvironmentObject private var scrumStore: ScrumStore

    var interface: Interface<ScrumDetail.Action>
    var scrum: DailyScrum
    var scrumEdit: QueryableItem<DailyScrum, DailyScrum?>.Trigger

    var entryView: some View {
        ScrumDetail(
            interface: interface,
            scrum: scrumStore.scrums[id: scrum.id] ?? scrum,
            scrumEdit: scrumEdit
        )
    }

    // MARK: - State Configurations

    func applyStateConfiguration(_ configuration: StateConfiguration) {
        switch configuration {
        case .reset:
            break
        }
    }
}

extension ScrumDetail_Managed {

    enum StateConfiguration {
        case reset
    }
}

extension ScrumDetail {

    /// A `ScrumDetail` view whose scrum input is automatically managed and updated via the `ScrumStore`.
    ///
    /// - Note: If the provided scrum is not in the `ScrumStore`, it will simply be passed along to the `ScrumDetail` view without being managed.
    /// - Parameters:
    ///   - interface: The scrum detail interface
    ///   - scrum: The managed scrum. Its identifier will be used to always display the up-to-date version of this scrum from the `ScrumStore`.
    /// - Returns: A modified `ScrumDetail` view whose scrum input is automatically managed and updated via the `ScrumStore`.
    static func managed(
        interface: Interface<ScrumDetail.Action>,
        scrum: DailyScrum,
        scrumEdit: QueryableItem<DailyScrum, DailyScrum?>.Trigger
    ) -> some View {
        ScrumDetail_Managed(interface: .forward(to: interface), scrum: scrum, scrumEdit: scrumEdit)
    }
}
