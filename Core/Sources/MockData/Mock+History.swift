import Foundation
import Models

extension Mock {
    public enum History {
        public static var example: Models.History {
            Models.History(
                attendees: [
                    Models.DailyScrum.Attendee(name: "Jon"),
                    Models.DailyScrum.Attendee(name: "Darla"),
                    Models.DailyScrum.Attendee(name: "Luis")
                ],
                lengthInMinutes: 10,
                transcript: "Darla, would you like to start today? Sure, yesterday I reviewed Luis' PR and met with the design team to finalize the UI..."
            )
        }
    }
}
