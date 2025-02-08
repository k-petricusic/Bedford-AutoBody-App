import SwiftUI
import ConfettiSwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var firstName: String? = nil
    @State private var lastName: String? = nil
    @State private var cars: [Car] = []
    @State private var selectedCar: Car? = nil
    @State private var animatedProgress: Double = 0.0
    @State private var carOffsetY: CGFloat = 0.0
    @State private var confettiCounter = 0

    var body: some View {
        ScrollView {
            VStack {
                // Welcome Message
                WelcomeMessage(firstName: firstName, lastName: lastName, colorScheme: colorScheme)
                    .padding(.top, 20)

                // Repair Progress
                RepairProgressView(
                    selectedCar: selectedCar,
                    animatedProgress: $animatedProgress,
                    carOffsetY: $carOffsetY,
                    confettiCounter: $confettiCounter
                )
                .padding(.top, 20)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .onAppear {
            fetchUserName { firstName, lastName in
                self.firstName = firstName
                self.lastName = lastName
            }
            
            fetchCars { cars, selectedCar in
                self.cars = cars
                self.selectedCar = selectedCar
                if selectedCar != nil {
                    animateProgress(
                        selectedCar: selectedCar,
                        animatedProgress: $animatedProgress,
                        carOffsetY: $carOffsetY,
                        confettiCounter: $confettiCounter
                    )
                }
            }
        }
    }
    
    
}
