import SwiftUI

struct DefaultScreen: View {
    @Binding var showingAddCarView: Bool
    @State private var carOffsetY: CGFloat = 0 // Bounce animation state
    @State private var isAnimationReady = false // Delays animation to avoid screen bounce

    var body: some View {
        VStack {
            Text("No car selected")
                .font(.title2)
                .foregroundColor(.gray)

            ZStack {
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 50)
                    .foregroundColor(.blue)
                    .offset(y: isAnimationReady ? carOffsetY : 0) // Start animation only when ready
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // ✅ Delays animation start
                            isAnimationReady = true
                            startBounceAnimation()
                        }
                    }
            }
            .frame(height: 100)

            Button(action: {
                showingAddCarView = true
            }) {
                Text("Add a Car")
                    .font(.headline)
                    .frame(width: 180) // ✅ Smaller button width
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 20) // ✅ Added more padding from the top
        }
        .padding(.top, 30) // ✅ Ensures overall spacing from welcome message
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures screen stays stable
    }

    // 🔹 Bounce animation function
    private func startBounceAnimation() {
        withAnimation(
            Animation
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            carOffsetY = -10 // ✅ Moves only the car icon
        }
    }
}
