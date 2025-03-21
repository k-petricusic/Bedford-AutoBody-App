import SwiftUI
import ConfettiSwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appData: AppDataViewModel
    @StateObject private var homeViewModel = HomeViewModel()

    @State private var animatedProgress: Double = 0.0
    @State private var carOffsetY: CGFloat = 0.0
    @State private var confettiCounter = 0
    @State private var selectedPDFURL: URL? = nil
    @State private var showPDFViewer = false
    @State private var showingAddCarView = false

    var body: some View {
        NavigationView {
            HomeContent(
                appData: appData,
                homeViewModel: homeViewModel,
                animatedProgress: $animatedProgress,
                carOffsetY: $carOffsetY,
                confettiCounter: $confettiCounter,
                selectedPDFURL: $selectedPDFURL,
                showPDFViewer: $showPDFViewer,
                showingAddCarView: $showingAddCarView
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingAddCarView) {
            DisplayCars(selectedCar: $homeViewModel.selectedCar)
        }
        .sheet(isPresented: $showPDFViewer) {
            PDFViewerWrapper(url: selectedPDFURL)
        }
        .onAppear {
            fetchCars { cars, selectedCar in
                DispatchQueue.main.async {
                    homeViewModel.cars = cars
                    homeViewModel.selectedCar = selectedCar ?? cars.first
                }
            }
        }
        .onChange(of: homeViewModel.selectedCar) {
            if let newCar = homeViewModel.selectedCar {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    updateProgress(for: newCar)
                }
            }
        }
        .onChange(of: selectedPDFURL) {
            if selectedPDFURL != nil {
                showPDFViewer = true
            }
        }
    }

    private func updateProgress(for car: Car?) {
        guard let car = car else { return }

        print("🔄 updateProgress CALLED for car: \(car.make) - \(car.currentRepairState)")

        let repairStages = [
            "Estimate Updates", "Parts Ordered", "Repair in Progress", "Painting",
            "Final Inspection", "Ready for pickup"
        ]

        if let index = repairStages.firstIndex(of: car.currentRepairState) {
            let newProgress = (index == repairStages.count - 1) ? 1.0 : Double(index) / Double(repairStages.count - 1)

            print("✅ Progress Updated: \(newProgress)")

            animateProgress(
                selectedCar: car,
                animatedProgress: $animatedProgress,
                carOffsetY: $carOffsetY,
                confettiCounter: $confettiCounter
            )
        } else {
            print("⚠️ ERROR: Current repair state not found in repairStages")
        }
    }
}

struct HomeContent: View {
    @Environment(\.colorScheme) var colorScheme
    var appData: AppDataViewModel
    @ObservedObject var homeViewModel: HomeViewModel

    @Binding var animatedProgress: Double
    @Binding var carOffsetY: CGFloat
    @Binding var confettiCounter: Int
    @Binding var selectedPDFURL: URL?
    @Binding var showPDFViewer: Bool
    @Binding var showingAddCarView: Bool

    var body: some View {
        ScrollView {
            VStack {
                WelcomeMessage(firstName: appData.firstName, colorScheme: colorScheme)

                Spacer().frame(height: 10)

                if homeViewModel.selectedCar == nil {
                    DefaultScreen(showingAddCarView: $showingAddCarView)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    EstimateSection(
                        selectedCar: homeViewModel.selectedCar,
                        selectedPDFURL: $selectedPDFURL,
                        showPDFViewer: $showPDFViewer
                    )
                    .padding(.top, 10)

                    EstimatedPickupView(selectedCar: homeViewModel.selectedCar)
                        .padding(.top, 10)
                        .padding(.bottom, 20)

                    RepairProgressView(
                        selectedCar: homeViewModel.selectedCar,
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
}
