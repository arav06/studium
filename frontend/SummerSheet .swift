import SwiftUI

struct SummarySheet: View {
    var summaryText: String

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📜 AI Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.top, 30)

                ScrollView {
                    Text(summaryText)
                        .font(.body)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .padding()
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 6)

                Spacer()
            }
            .padding()
            .background(Color(red: 249/255, green: 244/255, blue: 233/255))
            .navigationBarTitleDisplayMode(.inline)
                    }
    }
}

struct SummarySheet_Previews: PreviewProvider {
    static var previews: some View {
        SummarySheet(summaryText: "This is a sample AI summary text that would normally be much longer!")
    }
}
