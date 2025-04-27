import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()

                // Profile Icon
                Image(systemName: "graduationcap.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)

                // Email Display
                Text(userSession.email.isEmpty ? "No Email" : userSession.email)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                Spacer()

                // Logout Button
                Button(action: logout) {
                    Text("Logout")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Profile")
            .preferredColorScheme(.dark)
        }
    }

    func logout() {
        userSession.isLoggedIn = false
        userSession.email = ""
        userSession.name = ""
        userSession.school = ""    // ✅ Corrected
        userSession.phoneNumber = ""
        userSession.study = ""     // ✅ Also reset study
    }
}

