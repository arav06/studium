import SwiftUI

struct HomePage: View {
    @EnvironmentObject var userSession: UserSession

    @State private var showNewListing = false
    @State private var requestedSessionIDs: Set<String> = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Study Listings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        showNewListing = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding(10)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: Color.orange.opacity(0.6), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showNewListing) {
                        NewListingPage(
                            onSubmit: { refreshStudyEvents() } // 🔥 Callback to refresh listings
                        )
                        .environmentObject(userSession)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 80)

                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(userSession.availableStudyEvents) { event in
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Name: \(event.name)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Text("Chapter: \(event.chapter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("Duration: \(event.duration)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("Start Time: \(event.startTime)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Button(action: {
                                    sendStudyRequest(toEmail: event.email, sessionId: event._id)
                                }) {
                                    Text(requestedSessionIDs.contains(event._id) ? "Requested" : "Request Invite")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(requestedSessionIDs.contains(event._id) ? Color.gray : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 10)
                                .disabled(requestedSessionIDs.contains(event._id))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.black)
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
        }
    }

    func sendStudyRequest(toEmail: String, sessionId: String) {
        guard let url = URL(string: "https://able-only-chamois.ngrok-free.app/send_study_request") else {
            print("❌ Invalid URL")
            return
        }

        let body: [String: String] = [
            "from": userSession.email,
            "to": toEmail,
            "sid": sessionId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error sending request: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 201 {
                        print("✅ Study request sent successfully!")
                        requestedSessionIDs.insert(sessionId)
                    } else {
                        print("⚠️ Failed with status code: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }

    func refreshStudyEvents() {
        print("🔄 Refreshing study listings...")

        guard let url = URL(string: "https://able-only-chamois.ngrok-free.app/view_study_events?email=\(userSession.email)&topic=\(userSession.study)&school=\(userSession.school)") else {
            print("❌ Invalid refresh URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to refresh: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("❌ No data received during refresh")
                    return
                }

                do {
                    let events = try JSONDecoder().decode([StudyEvent].self, from: data)
                    userSession.availableStudyEvents = events
                    print("✅ Refreshed \(events.count) events")
                } catch {
                    print("❌ JSON Decode error during refresh: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

