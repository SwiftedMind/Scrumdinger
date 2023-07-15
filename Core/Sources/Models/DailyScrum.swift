/*
 See LICENSE folder for this sample’s licensing information.
 */

import Foundation
import IdentifiedCollections

public struct DailyScrum: Identifiable, Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var title: String
    public var attendees: IdentifiedArrayOf<Attendee>
    public var lengthInMinutes: Int
    public var theme: Theme
    public var history: IdentifiedArrayOf<History>

    public init(
        id: UUID = UUID(),
        title: String,
        attendees: IdentifiedArrayOf<Attendee>,
        lengthInMinutes: Int,
        theme: Theme,
        history: IdentifiedArrayOf<History> = []
    ) {
        self.id = id
        self.title = title
        self.attendees = attendees
        self.lengthInMinutes = lengthInMinutes
        self.theme = theme
        self.history = history
    }
}

extension DailyScrum {
    public struct Attendee: Identifiable, Codable, Equatable, Hashable, Sendable {
        public var id: UUID
        public var name: String

        public init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
    }

    public struct Data {
        public var title: String = ""
        public var attendees: IdentifiedArrayOf<Attendee> = []
        public var lengthInMinutes: Double = 5
        public var theme: Theme = .seafoam
    }

    public var data: Data {
        Data(
            title: title,
            attendees: attendees,
            lengthInMinutes: Double(lengthInMinutes),
            theme: theme
        )
    }

    public mutating func update(from data: Data) {
        title = data.title
        attendees = data.attendees
        lengthInMinutes = Int(data.lengthInMinutes)
        theme = data.theme
    }

    public init(data: Data) {
        id = UUID()
        title = data.title
        attendees = data.attendees
        lengthInMinutes = Int(data.lengthInMinutes)
        theme = data.theme
        history = []
    }
}
