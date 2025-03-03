import SwiftUI
import SDWebImageSwiftUI

struct CarView: View {
    @State private var selectedCar: Car? = nil
    @State private var carImages: [String] = []
    @State private var isLoading = true
    @State private var showAddCar = false // Controls Add Car screen visibility
    @State private var showDisplayCars = false
    @State private var showImagesScreen = false

    var body: some View {
        NavigationStack {
            VStack {
                if selectedCar == nil {
                    // 🔹 Show Default Screen When No Car is Selected
                    DefaultScreen(showingAddCarView: $showAddCar)
                } else {
                    // Car Details Section
                    CarInfoView(selectedCar: selectedCar)

                    // Image Carousel
                    CarImageCarousel(carImages: carImages, isLoading: isLoading)

                    // Action Buttons
                    CarActionButtons(selectedCarId: selectedCar?.id)
                }

                Spacer()
            }
            .navigationTitle("Car Information")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchCarData()
            }
        }
        .sheet(isPresented: $showAddCar) {
            DisplayCars(selectedCar: $selectedCar)
        }
    }

    private func fetchCarData() {
        fetchCars { cars, selected in
            self.selectedCar = selected
            if let carId = selected?.id {
                fetchCarImages(carId: carId) { images, error in
                    DispatchQueue.main.async {
                        self.carImages = images
                        self.isLoading = false
                    }
                }
            }
        }
    }
}
