import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        NavigationStack {
            if !userSession.isLoggedIn {
                LoginPage()
            } else if !userSession.hasSelectedSubject {
                SelectSubjectPage()
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

