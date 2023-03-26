/*
 See LICENSE folder for this sample’s licensing information.
 */

import Foundation
import IdentifiedCollections

struct History: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let date: Date
    var attendees: IdentifiedArrayOf<DailyScrum.Attendee>
    var lengthInMinutes: Int
    var transcript: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        attendees: IdentifiedArrayOf<DailyScrum.Attendee>,
        lengthInMinutes: Int = 5,
        transcript: String? = nil
    ) {
        self.id = id
        self.date = date
        self.attendees = attendees
        self.lengthInMinutes = lengthInMinutes
        self.transcript = transcript
    }
}

extension History {

    static var mock: Self {
        History(attendees: [DailyScrum.Attendee(name: "Jon"), DailyScrum.Attendee(name: "Darla"), DailyScrum.Attendee(name: "Luis")], lengthInMinutes: 10, transcript: "Darla, would you like to start today? Sure, yesterday I reviewed Luis' PR and met with the design team to finalize the UI...")
    }
}
