/*
 See LICENSE folder for this sample’s licensing information.
 */

import Foundation
import IdentifiedCollections

public struct History: Identifiable, Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var date: Date
    public var attendees: IdentifiedArrayOf<DailyScrum.Attendee>
    public var lengthInMinutes: Int
    public var transcript: String?

    public init(
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
