import SwiftUI
import FirebaseFirestore

struct CurrentRepairsScreen: View {
    @State private var cars: [Car] = [] // List of cars fetched from Firestore
    @State private var isLoading = true // Loading state
    @State private var errorMessage: String? = nil // Error handling

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
            } else if cars.isEmpty {
                Text("No ongoing repairs.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(cars, id: \.id) { car in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(car.year) \(car.make) \(car.model)")
                            .font(.headline)
                        Text("Current State: \(car.currentRepairState)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Current Repairs")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchOngoingRepairs { cars, errorMessage in
                self.cars = cars
                self.errorMessage = errorMessage
                self.isLoading = false
            }
        }
    }
}
