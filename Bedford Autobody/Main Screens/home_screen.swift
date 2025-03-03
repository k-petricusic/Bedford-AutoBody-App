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
    @State private var selectedPDFURL: URL? = nil
    @State private var showPDFViewer = false
    @State private var showingAddCarView = false // Tracks if the Add Car screen is open

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Welcome Message
                    WelcomeMessage(firstName: firstName, colorScheme: colorScheme)
                        .padding(.top, 20)

                    Spacer().frame(height: 10)

                    if selectedCar == nil {
                        // 🔹 Ensures Only the Car Icon Bounces, Not the Whole Screen
                        DefaultScreen(showingAddCarView: $showingAddCarView)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Estimate Section
                        EstimateSection(
                            selectedCar: selectedCar,
                            selectedPDFURL: $selectedPDFURL,
                            showPDFViewer: $showPDFViewer
                        )
                        .padding(.top, 10)

                        // Estimated Pickup Date Section
                        EstimatedPickupView()
                            .padding(.top, 10)
                            .padding(.bottom, 20)

                        // Repair Progress
                        RepairProgressView(
                            selectedCar: selectedCar,
                            animatedProgress: $animatedProgress,
                            carOffsetY: $carOffsetY,
                            confettiCounter: $confettiCounter
                        )
                    }
                }
                .padding()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
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
        .sheet(isPresented: $showingAddCarView) {
            DisplayCars(selectedCar: $selectedCar)
        }
    }
}
