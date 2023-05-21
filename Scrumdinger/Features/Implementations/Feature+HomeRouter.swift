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

extension Feature {
    @MainActor
    final class HomeRouter: ObservableObject {
        @Published var path: [Destination] = []
        @Published var scrumEdit: DailyScrum? = nil
        @Published var scrumAdd: DailyScrum? = nil

        enum Destination: Hashable {
            case scrumDetail(DailyScrum)
            case meeting(for: DailyScrum)
            case history(History)
        }

        func push(_ destination: Destination) {
            self.path.append(destination)
        }

        @discardableResult
        func pop() -> Destination? {
            path.popLast()
        }

        func setPath(_ stack: [Destination]) {
            self.path = stack
        }

        func queryEditScrum(_ scrum: DailyScrum) throws {
            // Check if editor is already open and throw if needed
            scrumAdd = nil
            scrumEdit = scrum
        }

        func queryAddScrum(withDraft draft: DailyScrum) throws {
            // Check if editor is already open and throw if needed
            scrumEdit = nil
            scrumAdd = draft
        }
    }
}
