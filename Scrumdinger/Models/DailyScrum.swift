/*
 See LICENSE folder for this sample’s licensing information.
 */

import Foundation
import IdentifiedCollections

struct DailyScrum: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    var title: String
    var attendees: IdentifiedArrayOf<Attendee>
    var lengthInMinutes: Int
    var theme: Theme
    var history: IdentifiedArrayOf<History>

    init(
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
    struct Attendee: Identifiable, Codable, Equatable, Hashable, Sendable {
        let id: UUID
        var name: String

        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
    }

    struct Data {
        var title: String = ""
        var attendees: IdentifiedArrayOf<Attendee> = []
        var lengthInMinutes: Double = 5
        var theme: Theme = .seafoam
    }

    var data: Data {
        Data(
            title: title,
            attendees: attendees,
            lengthInMinutes: Double(lengthInMinutes),
            theme: theme
        )
    }

    mutating func update(from data: Data) {
        title = data.title
        attendees = data.attendees
        lengthInMinutes = Int(data.lengthInMinutes)
        theme = data.theme
    }

    init(data: Data) {
        id = UUID()
        title = data.title
        attendees = data.attendees
        lengthInMinutes = Int(data.lengthInMinutes)
        theme = data.theme
        history = []
    }
}

extension DailyScrum.Attendee {
    static var mock: DailyScrum.Attendee {
        IdentifiedArrayOf<DailyScrum>.mockList[0].attendees[0]
    }
}

extension IdentifiedArrayOf where Element == DailyScrum.Attendee {
    static var mockList: IdentifiedArrayOf<DailyScrum.Attendee> {
        IdentifiedArrayOf<DailyScrum>.mockList[0].attendees
    }
}

extension DailyScrum {
    static var draft: Self {
        DailyScrum(
            title: "",
            attendees: [],
            lengthInMinutes: 5,
            theme: .allCases.randomElement()!,
            history: []
        )
    }

    static var mock: Self {
        DailyScrum(
            title: "Expansive Meetings",
            attendees: .init(uniqueElements: ["James", "Naomi", "Amos", "Alex"].map { Attendee(name: $0) }),
            lengthInMinutes: 42,
            theme: .navy,
            history: [.mock]
        )
    }
}

extension IdentifiedArrayOf where Element == DailyScrum {
    static var mockList: IdentifiedArrayOf<DailyScrum> {
        [
            DailyScrum(
                title: "Design",
                attendees: .init(
                    uniqueElements: ["Cathy", "Daisy", "Simon", "Jonathan", "James", "Naomi"].map { DailyScrum.Attendee(name: $0) }
                ),
                lengthInMinutes: 1,
                theme: .yellow,
                history: [.mock]
            ),
            DailyScrum(
                title: "App Dev",
                attendees: .init(
                    uniqueElements: ["Katie", "Gray", "Euna", "Luis", "Darla"].map { DailyScrum.Attendee(name: $0) }
                ),
                lengthInMinutes: 5,
                theme: .orange
            ),
            DailyScrum(
                title: "Web Dev",
                attendees: .init(
                    uniqueElements: ["Chella", "Chris", "Christina", "Eden", "Karla",
                                     "Lindsey", "Aga", "Chad", "Jenn", "Sarah"].map { DailyScrum.Attendee(name: $0) }
                ),
                lengthInMinutes: 5,
                theme: .poppy
            )
        ]
    }
}

extension [DailyScrum] {
    static var mockList: [DailyScrum] {
        IdentifiedArrayOf<DailyScrum>.mockList.elements
    }
}
