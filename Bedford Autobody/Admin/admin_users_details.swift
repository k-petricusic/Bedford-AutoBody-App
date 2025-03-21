import SwiftUI
import FirebaseFirestore

struct UserDetailView: View {
    var user: User
    @State private var cars: [Car] = []
    @State private var showAdminChatView = false // State variable for AdminChatView navigation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // User Information Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("User Details")
                        .font(.title)
                        .bold()

                    HStack {
                        Text("Name:")
                            .font(.headline)
                        Spacer()
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.body)
                    }

                    HStack {
                        Text("Email:")
                            .font(.headline)
                        Spacer()
                        Text("\(user.email)")
                            .font(.body)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)

                // Cars Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Cars")
                        .font(.title)
                        .bold()

                    if cars.isEmpty {
                        Text("No cars found for this user.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(cars, id: \.id) { car in
                            NavigationLink(destination: CarDetailView(car: car)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(car.year) \(car.make) \(car.model)")
                                            .font(.headline)
                                        Text("Color: \(car.color)")
                                            .font(.subheadline)
                                        Text("VIN: \(car.vin)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "car.fill")
                                        .foregroundColor(.blue)
                                        .imageScale(.large)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)

                // Admin Chat Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Admin Actions")
                        .font(.title)
                        .bold()

                    Button(action: {
                        showAdminChatView = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Go to Admin Chat")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            .padding()
        }
        .navigationTitle("User Details")
        .onAppear {
            fetchCarsForUser() // Fetch the user's cars on appearance
        }

        // NavigationLink to AdminChatView
        .navigationDestination(isPresented: $showAdminChatView) {
            AdminChatViewWrapper(userId: user.id)
                .navigationTitle("\(user.firstName) \(user.lastName)")
                .padding(.top, 20)
        }
    }

    // Fetch cars associated with the user
    func fetchCarsForUser() {
        let db = Firestore.firestore()

        db.collection("users").document(user.id).collection("cars").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching cars: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            self.cars = documents.compactMap { document in
                try? document.data(as: Car.self)
            }
        }
    }
}
