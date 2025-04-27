import SwiftUI

struct StudyEvent: Codable, Identifiable {
    var id = UUID()

    var _id: String  // 🔥 server ID
    var name: String
    var email: String // 🔥 creator's email
    var chapter: String
    var duration: String
    var startTime: String

    private enum CodingKeys: String, CodingKey {
        case _id, name, email, chapter, duration, startTime
    }
}

