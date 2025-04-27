import Foundation

class UserSession: ObservableObject {
    @Published var isLoggedIn = false
    @Published var hasSelectedSubject = false
    @Published var email = ""
    @Published var name = ""
    @Published var school = ""
    @Published var phoneNumber = ""
    @Published var study = ""

    @Published var confirmedSessions: [String] = []
    @Published var myCreatedSessions: [String] = []
    @Published var availableStudyEvents: [StudyEvent] = []  // 🔥 Correct way to store study events
}

