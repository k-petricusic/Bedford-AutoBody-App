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
        .onAppear(perform: fetchOngoingRepairs)
    }

    func fetchOngoingRepairs() {
        let db = Firestore.firestore()

        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                self.errorMessage = "Failed to fetch users."
                self.isLoading = false
                return
            }

            guard let userDocuments = snapshot?.documents else {
                self.errorMessage = "No users found."
                self.isLoading = false
                return
            }

            let group = DispatchGroup()
            var fetchedCars: [Car] = []

            for userDocument in userDocuments {
                group.enter()
                db.collection("users")
                    .document(userDocument.documentID)
                    .collection("cars")
                    .whereField("currentRepairState", isNotEqualTo: "Ready for pickup") // Exclude "Ready for pickup" cars
                    .getDocuments { carSnapshot, carError in
                        if let carError = carError {
                            print("Error fetching cars: \(carError.localizedDescription)")
                        } else if let carDocuments = carSnapshot?.documents {
                            fetchedCars += carDocuments.compactMap { try? $0.data(as: Car.self) }
                        }
                        group.leave()
                    }
            }

            group.notify(queue: .main) {
                self.cars = fetchedCars
                self.isLoading = false
            }
        }
    }
}
