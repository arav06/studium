import SwiftUI
import MapKit

struct LocationSearchView: View {
    @Binding var selectedLocation: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @StateObject private var completerDelegate = SearchCompleterDelegate()
    private let searchCompleter = MKLocalSearchCompleter()
    
    init(selectedLocation: Binding<String>) {
        self._selectedLocation = selectedLocation
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a location", text: $searchText)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                List(completerDelegate.results, id: \.self) { completion in
                    Button {
                        selectedLocation = completion.title
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(completion.title)
                                .font(.headline)
                            Text(completion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            searchCompleter.delegate = completerDelegate
            searchCompleter.resultTypes = [.address, .pointOfInterest]
        }
        .onChange(of: searchText) { newValue in
            searchCompleter.queryFragment = newValue
        }
    }
}

