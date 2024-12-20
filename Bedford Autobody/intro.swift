import SwiftUI

struct IntroScreen: View {
    @State private var showMainScreen = false // Tracks navigation state
    
    var body: some View {
        ZStack {
            // Background color
            Color.white
                .ignoresSafeArea()

            VStack {
                Button {
                    showMainScreen = true // Navigate to main screen when tapped
                } label: {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .accessibilityLabel("App Logo")
                }
            }
            .padding()
        }
        // Trigger full-screen transition to the LoginOptions screen
        .fullScreenCover(isPresented: $showMainScreen) {
            LoginOptions() // Always navigate to LoginOptions
        }
    }
}
