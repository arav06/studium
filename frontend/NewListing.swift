import SwiftUI

struct NewListingPage: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession

    @State private var study = ""
    @State private var duration = ""
    @State private var startTime = ""
    @State private var selectedLocation = ""
    @State private var roomNumber = ""

    @State private var showLocationSearch = false

    var onSubmit: (() -> Void)?  // 🔥 callback to HomePage refresh

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Study Topic", text: $study)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                TextField("Duration (e.g. 2 hours)", text: $duration)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                TextField("Start Time (e.g. 5:00 PM)", text: $startTime)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                Button {
                    showLocationSearch = true
                } label: {
                    HStack {
                        Text(selectedLocation.isEmpty ? "Select Location" : selectedLocation)
                            .foregroundColor(selectedLocation.isEmpty ? .gray : .white)
                        Spacer()
                        Image(systemName: "location.fill")
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .sheet(isPresented: $showLocationSearch) {
                    LocationSearchView(selectedLocation: $selectedLocation)
                }

                TextField("Room Number", text: $roomNumber)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                Button {
                    submitListing()
                } label: {
                    Text("Submit Listing")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("New Listing")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black)
            .preferredColorScheme(.dark)
        }
    }

    func submitListing() {
        let combinedLocation = "Room \(roomNumber), \(selectedLocation)"

        guard let url = URL(string: "https://able-only-chamois.ngrok-free.app/add_study_event") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": userSession.email,
            "study": study,
            "chapter": study,
            "name": userSession.name,
            "location": combinedLocation,
            "duration": duration,
            "startTime": startTime,
            "school": userSession.school
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to POST: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
                onSubmit?() // 🔥 Call HomePage refresh
            }
        }.resume()
    }
}

