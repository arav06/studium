import SwiftUI

struct CreateAccountPage: View {
    @EnvironmentObject var userSession: UserSession

    @State private var email = ""
    @State private var name = ""
    @State private var school = ""   // 🔥 CHANGED from university
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var study = ""

    @State private var signupError = ""
    @State private var showSelectSubject = false

    var body: some View {
        if showSelectSubject {
            SelectSubjectPage()
                .environmentObject(userSession)
        } else {
            VStack(spacing: 20) {
                Spacer()

                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 15) {
                    TextField("University Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)

                    TextField("Full Name", text: $name)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)

                    TextField("School Name", text: $school)  // 🔥 Field changed
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)

                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)

                    TextField("What are you studying?", text: $study)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button("Submit") {
                    createAccount()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)

                if !signupError.isEmpty {
                    Text(signupError)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .preferredColorScheme(.dark)
        }
    }

    func createAccount() {
        guard let url = URL(string: "https://able-only-chamois.ngrok-free.app/add_user") else {
            signupError = "Invalid URL."
            return
        }

        let user = [
            "email": email,
            "name": name,
            "school": school,   // 🔥 Changed from university -> school
            "phoneNumber": phoneNumber,
            "password": password,
            "study": study
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: user) else {
            signupError = "Failed to encode user data."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    signupError = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    signupError = "Invalid server response."
                    return
                }

                if httpResponse.statusCode == 201 {
                    userSession.email = email
                    userSession.name = name
                    userSession.school = school
                    userSession.phoneNumber = phoneNumber
                    userSession.study = study
                    userSession.isLoggedIn = true
                    showSelectSubject = true
                } else {
                    signupError = "Failed to create account. (Status code: \(httpResponse.statusCode))"
                }
            }
        }.resume()
    }
}

