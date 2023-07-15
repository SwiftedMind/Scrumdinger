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
import Models
import IdentifiedCollections
import Puddles

extension Router {
    /// The router that is handling the navigation for the Home module.
    ///
    /// All submodules inside the Home module have access to it via the environment.
    @MainActor final class Home: NavigationRouter {
        @Published var path: [Destination] = []
        @Published var scrumEdit: DailyScrum? = nil
        @Published var scrumAdd: DailyScrum? = nil
        @Published var meetingDetail: DailyScrum?

        /// The navigation destinations for the `NavigationStack`.
        enum Destination: Hashable {
            case scrumDetail(DailyScrum)
            case history(History)
        }

        func reset() {
            path.removeAll()
            scrumEdit = nil
            scrumAdd = nil
            meetingDetail = nil
        }
    }
}

