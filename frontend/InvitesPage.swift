import SwiftUI

struct InvitesPage: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        VStack {
            Text("Your Created Study Groups")
                .font(.title)
                .bold()
                .padding(.bottom)

            List(userSession.myCreatedSessions, id: \.self) { session in
                Text(session)
                    .padding()
            }
        }
        .navigationTitle("Invites")
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}

