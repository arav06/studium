import SwiftUI

struct SuccessAnimationView: View {
    @State private var animate = false

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: animate ? 150 : 50, height: animate ? 150 : 50)
                .foregroundColor(.blue)
                .scaleEffect(animate ? 1.2 : 0.5)
                .animation(.easeOut(duration: 1.5), value: animate)
                .onAppear {
                    animate = true
                }

            Text("Account Created!")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .opacity(animate ? 1 : 0)
                .animation(.easeOut(duration: 1.5).delay(0.5), value: animate)

            Spacer()
        }
        .background(Color.black.opacity(0.9).ignoresSafeArea())
    }
}

