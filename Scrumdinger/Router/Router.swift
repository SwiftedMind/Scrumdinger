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

@MainActor final class Router: ObservableObject {
    static let shared: Router = .init()

    var home: Home = .init()

    // Destinations for the app
    enum Destination: Hashable {
        case root
        case scrumDetail(DailyScrum)
        case newMeeting(forScrum: DailyScrum)
        case history(History, forScrum: DailyScrum)
        case addScrum(draft: DailyScrum)
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .root:
            home.reset()
        case .scrumDetail(let scrum):
            home.reset()
            home.setPath([.scrumDetail(scrum)])
        case .newMeeting(forScrum: let scrum):
            home.setPath([.scrumDetail(scrum)])
            home.meetingDetail = scrum
        case .history(let history, let scrum):
            home.reset()
            home.setPath([.scrumDetail(scrum), .history(history)])
        case .addScrum(let draft):
            home.reset()
            home.scrumAdd = draft
        }
    }

    func dismissMeetingDetail() {
        home.meetingDetail = nil
    }

    func showMeetingDetail(meeting: DailyScrum) {
        guard case .scrumDetail = home.path.last else { return }
        home.meetingDetail = meeting
    }

    func queryEditScrum(_ scrum: DailyScrum) throws {
        home.scrumAdd = nil
        home.scrumEdit = scrum
    }

    func queryAddScrum(withDraft draft: DailyScrum) throws {
        home.scrumEdit = nil
        home.scrumAdd = draft
    }
}
