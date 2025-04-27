import SwiftUI
import MapKit

struct MatchesPage: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3398, longitude: -71.0882),
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    )

    @State private var showSmallMap = false
    @State private var showNotesPage = false
    @State private var isMatched = false // 🔥 whether match is accepted
    @State private var timer: Timer? = nil
    @State private var email: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if isMatched {
                Text("Your Study Match")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 70)
                    .padding(.bottom, 20)

                // Matched Users
                HStack(spacing: 25) {
                    VStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        Text("You")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }

                    VStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.purple)
                        Text("Partner")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(25)
                .frame(maxWidth: .infinity)
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                .padding(.horizontal)
                .padding(.bottom, 20)

                // Study Session Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("📚 Topic: Chemistry - Organic")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("⏰ Duration: 3 hours")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(width: 370, height: 100)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                .padding(.horizontal)

                // Small Map
                if showSmallMap {
                    ZStack(alignment: .bottomTrailing) {
                        Map(coordinateRegion: $region, annotationItems: [SnellLibrary()]) { place in
                            MapMarker(coordinate: place.coordinate, tint: .red)
                        }
                        .frame(height: 250)
                        .cornerRadius(25)
                        .padding()
                        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)

                        Button(action: {
                            openInAppleMaps()
                        }) {
                            Text("Go 📍")
                                .font(.subheadline)
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .padding()
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: showSmallMap)
                }

                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        withAnimation {
                            showSmallMap.toggle()
                        }
                    }) {
                        Text(showSmallMap ? "Hide Map 🗺️" : "Open Location 📍")
                            .font(.headline)
                            .frame(width: 340, height: 100)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }

                    Button(action: {
                        showNotesPage = true
                    }) {
                        Text("Notes 📝")
                            .font(.headline)
                            .frame(width: 340, height: 100)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)

                Spacer()
            } else {
                VStack {
                    Text("No Matches Yet 😔")
                        .font(.largeTitle.bold())
                        .padding(.top, 150)
                        .foregroundColor(.gray)

                    Text("Keep checking back or send more invites!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showNotesPage) {
            NotesPage()
        }
        .background(Color(red: 249/255, green: 244/255, blue: 233/255))
        .ignoresSafeArea()
        .onAppear {
            startCheckingStatus()
        }
        .onDisappear {
            stopCheckingStatus()
        }
    }

    func openInAppleMaps() {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.3398, longitude: -71.0882)))
        destination.name = "Snell Library"
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }

    // 🔥 CHECK MATCH STATUS EVERY 15 SECONDS
    func startCheckingStatus() {
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            checkInviteStatus()
        }
    }

    func stopCheckingStatus() {
        timer?.invalidate()
        timer = nil
    }

    func checkInviteStatus() {
        
        guard let url = URL(string: "https://able-only-chamois.ngrok-free.app/check_invite_status?email=\(email)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let response = json["response"] as? String else {
                return
            }
            DispatchQueue.main.async {
                if response == "y" {
                    self.isMatched = true
                    self.stopCheckingStatus() // 🛑 stop timer when match confirmed
                }
            }
        }.resume()
    }
}

struct SnellLibrary: Identifiable {
    let id = UUID()
    let coordinate = CLLocationCoordinate2D(latitude: 42.3398, longitude: -71.0882)
}

struct MatchesPage_Previews: PreviewProvider {
    static var previews: some View {
        MatchesPage()
    }
}
