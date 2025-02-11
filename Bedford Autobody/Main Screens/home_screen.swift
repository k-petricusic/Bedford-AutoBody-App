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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Welcome Message
                    WelcomeMessage(firstName: firstName, colorScheme: colorScheme)
                        .padding(.top, 20)
                    
                    // Add Space Before Estimate Section
                    Spacer().frame(height: 10)

                    if selectedCar == nil {
                        VStack {
                            Text("Please select a car")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .padding()

                            Button(action: {
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
                            }) {
                                Text("Select Car")
                                    .font(.headline)
                                    .padding()
                                    .frame(minWidth: 200)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 20)
                        }
                        .padding()
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
    }
}
