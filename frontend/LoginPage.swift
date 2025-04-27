import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var userSession: UserSession

    @State private var email = ""
    @State private var password = ""
    @State private var loginError = ""
    @State private var showCreateAccount = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "graduationcap.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text("Studium")
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

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button("Login") {
                login()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            if !loginError.isEmpty {
                Text(loginError)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Button("Create Account") {
                showCreateAccount = true
            }
            .foregroundColor(.blue)
            .padding(.top, 10)
            .sheet(isPresented: $showCreateAccount) {
                CreateAccountPage()
                    .environmentObject(userSession)
            }

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    func login() {
        guard let url = URL(string: "https://able-only-chamois.ngrok-free.app/login") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "password": password
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    loginError = error.localizedDescription
                }
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                DispatchQueue.main.async {
                    if decoded.status == "success" {
                        userSession.isLoggedIn = true
                        userSession.email = decoded.email
                        userSession.name = decoded.name
                        userSession.school = decoded.school
                    } else {
                        loginError = decoded.message
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    loginError = "Failed to parse server response."
                }
            }
        }.resume()
    }
}

struct LoginResponse: Codable {
    var status: String
    var message: String
    var email: String
    var name: String
    var school: String
}

