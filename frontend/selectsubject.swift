import SwiftUI

struct SelectSubjectPage: View {
    @EnvironmentObject var userSession: UserSession

    @State private var subjectText: String = ""
    @State private var navigateToMain = false
    @State private var loading = false
    @State private var apiError = ""

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("You have 24 hours to make a move and match with a group!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                TextField("Enter your subject...", text: $subjectText)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                    .background(Color.clear)
                    .submitLabel(.done)
                    .onSubmit { hideKeyboard() }

                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            VStack(spacing: 20) {
                Button(action: {
                    fetchStudyEvents()
                }) {
                    if loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(12)
                    } else {
                        Text("Look for Study Groups")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)

            if !apiError.isEmpty {
                Text(apiError)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            NavigationLink(destination: MainTabView(), isActive: $navigateToMain) {
                EmptyView()
            }
        }
        .background(Color.black.ignoresSafeArea())
    }

    func fetchStudyEvents() {
        guard let url = URL(string: "https://able-only-chamois.ngrok-free.app/view_study_events?email=\(userSession.email)&topic=\(subjectText)&school=\(userSession.school)") else {
            print("❌ Invalid URL")
            return
        }

        loading = true
        apiError = ""

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                loading = false

                if let error = error {
                    apiError = "Failed to fetch events: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    apiError = "No data received"
                    return
                }

                do {
                    let events = try JSONDecoder().decode([StudyEvent].self, from: data)
                    userSession.availableStudyEvents = events
                    navigateToMain = true
                } catch {
                    apiError = "Failed to decode events"
                    print("❌ JSON Decode Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

