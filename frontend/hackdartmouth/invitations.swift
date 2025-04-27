import SwiftUI

struct InvitationsPage: View {
    @EnvironmentObject var tabRouter: TabRouter

    @State private var receivedInvite: String? = nil
    @State private var sid: String? = nil
    @State private var accepted = false
    @State private var isLoading = true
    @State private var timer: Timer? = nil
    @State private var email: String = ""
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .padding(.top, 100)
            }
            else if accepted {
                VStack(spacing: 20) {
                    Text("🎉 You have a StudyBuddy! 🔥🔥🔥")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: {
                        tabRouter.currentTab = .matches
                    }) {
                        Text("Go to Your Study Match 🚀")
                            .font(.headline)
                            .frame(width: 300, height: 60)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding(.top, 150)
            }
            else if let invite = receivedInvite {
                Text("Invitations Received")
                    .foregroundColor(.black)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 50)

                VStack(spacing: 20) {
                    HStack {
                        Text(invite)
                            .font(.headline)
                            .foregroundColor(.black)

                        Spacer()

                        Button(action: {
                            acceptInvite()
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green)
                        }

                        Button(action: {
                            declineInvite()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }
                .padding(.top, 10)
            }
            else {
                Text("No Invites Found")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.top, 100)
            }

            Spacer()
        }
        .background(Color(red: 249/255, green: 244/255, blue: 233/255))
        .ignoresSafeArea()
        .onAppear {
            fetchInvite()
            startRefreshing()
        }
        .onDisappear {
            stopRefreshing()
        }
    }

    func fetchInvite() {
        let email = email
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://able-only-chamois.ngrok-free.app/view_invites?email=\(encodedEmail)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let data = data {
                if let decoded = try? JSONDecoder().decode(InviteResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.receivedInvite = decoded.name
                        self.sid = decoded.sid
                    }
                } else {
                    print("❌ Could not decode invite")
                }
            } else if let error = error {
                print("❌ Error fetching invite: \(error.localizedDescription)")
            }
        }.resume()
    }

    func acceptInvite() {
        guard let sid = sid else { return }

        guard let url = URL(string: "https://able-only-chamois.ngrok-free.app/accept_invite?sid=\(sid)") else {
            print("Invalid Accept URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error accepting invite: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                withAnimation {
                    receivedInvite = nil
                    accepted = true
                    stopRefreshing()
                }
            }
        }.resume()
    }

    func declineInvite() {
        withAnimation {
            receivedInvite = nil
        }
    }

    func startRefreshing() {
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            fetchInvite()
        }
    }

    func stopRefreshing() {
        timer?.invalidate()
        timer = nil
    }
}

struct InviteResponse: Codable {
    let fromEmail: String
    let name: String
    let sid: String
}

struct InvitationsPage_Previews: PreviewProvider {
    static var previews: some View {
        InvitationsPage()
            .environmentObject(TabRouter())
    }
}
