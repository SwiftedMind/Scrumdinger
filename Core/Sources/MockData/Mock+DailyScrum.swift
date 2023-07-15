import Foundation
import IdentifiedCollections
import Models

extension Mock {
    public enum DailyScrum {

        public static let all: IdentifiedArrayOf<Models.DailyScrum> = [
            Models.DailyScrum(
                title: "Design",
                attendees: .init(
                    uniqueElements: ["Cathy", "Daisy", "Simon", "Jonathan", "James", "Naomi"].map { Models.DailyScrum.Attendee(name: $0) }
                ),
                lengthInMinutes: 1,
                theme: .yellow,
                history: [Mock.History.example]
            ),
            Models.DailyScrum(
                title: "App Dev",
                attendees: .init(
                    uniqueElements: ["Katie", "Gray", "Euna", "Luis", "Darla"].map { Models.DailyScrum.Attendee(name: $0) }
                ),
                lengthInMinutes: 5,
                theme: .orange
            ),
            Models.DailyScrum(
                title: "Web Dev",
                attendees: .init(
                    uniqueElements: ["Chella", "Chris", "Christina", "Eden", "Karla",
                                     "Lindsey", "Aga", "Chad", "Jenn", "Sarah"].map { Models.DailyScrum.Attendee(name: $0) }
                ),
                lengthInMinutes: 5,
                theme: .poppy
            )
        ]

        public static var attendee: Models.DailyScrum.Attendee {
            all[0].attendees[0]
        }

        public static var attendees: IdentifiedArrayOf<Models.DailyScrum.Attendee> {
            all[0].attendees
        }

        public static var draft: Models.DailyScrum {
            Models.DailyScrum(
                title: "",
                attendees: [],
                lengthInMinutes: 5,
                theme: .allCases.randomElement()!,
                history: []
            )
        }

        public static var example: Models.DailyScrum {
            Models.DailyScrum(
                title: "Expansive Meetings",
                attendees: .init(uniqueElements: ["James", "Naomi", "Amos", "Alex"].map { Models.DailyScrum.Attendee(name: $0) }),
                lengthInMinutes: 42,
                theme: .navy,
                history: [Mock.History.example]
            )
        }
    }
}
