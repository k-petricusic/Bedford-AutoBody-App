import SwiftUI
import FirebaseFirestore

struct UsersList: View {
    @State private var users: [User] = []

    var body: some View {
        List(users, id: \.id) { user in
            NavigationLink(destination: UserDetailView(user: user)) {
                VStack(alignment: .leading) {
                    Text(user.email)
                        .font(.headline)
                    Text("Name: \(user.firstName) \(user.lastName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            fetchUsersFromFirestore()
        }
        .navigationTitle("Users List")
    }

    func fetchUsersFromFirestore() {
        let db = Firestore.firestore()

        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            self.users = documents.compactMap { document in
                let data = document.data()
                return User(
                    id: document.documentID,
                    email: data["email"] as? String ?? "",
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? ""
                )
            }
        }
    }
}

struct User: Identifiable {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
}

struct UserDetailView: View {
    var user: User
    @State private var cars: [Car] = []
    @State private var showAdminChatView = false // New state variable for AdminChatView

    var body: some View {
        VStack(alignment: .leading) {
            Text("Details for \(user.firstName) \(user.lastName)")
                .font(.title)
                .padding()

            Text("Email: \(user.email)")
                .font(.subheadline)
                .padding(.bottom, 20)

            Text("Cars:")
                .font(.headline)
                .padding(.bottom, 10)

            if cars.isEmpty {
                Text("No cars found for this user.")
                    .foregroundColor(.gray)
            } else {
                List(cars, id: \Car.id) { car in
                    NavigationLink(destination: CarDetailView(car: car)) {
                        VStack(alignment: .leading) {
                            Text("\(car.year) \(car.make) \(car.model)")
                                .font(.headline)
                            Text("Color: \(car.color)")
                                .font(.subheadline)
                            Text("VIN: \(car.vin)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }

            // Button to navigate to AdminChatView
            Button(action: {
                showAdminChatView = true // Trigger navigation to AdminChatView
            }) {
                Text("Go to Admin Chat")
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 200)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .navigationTitle("User Details")
        .onAppear {
            fetchCarsForUser()
        }

        // NavigationLink to AdminChatView
        NavigationLink(
            destination: VStack {
                AdminChatViewWrapper(userId: user.id)
                    .navigationTitle("\(user.firstName) \(user.lastName)")
                    .padding(.top, 20) // Adds space below the title
            },
            isActive: $showAdminChatView
        ) {
            EmptyView()
        }

    }

    func fetchCarsForUser() {
        let db = Firestore.firestore()

        db.collection("users").document(user.id).collection("cars").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching cars: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            self.cars = documents.compactMap { document in
                try? document.data(as: Car.self) // Reuse the existing Car model and decoding logic
            }
        }
    }
}


struct AdminChatViewWrapper: UIViewControllerRepresentable {
    var userId: String

    func makeUIViewController(context: Context) -> AdminChatView {
        return AdminChatView(userId: userId) // Pass the userId
    }

    func updateUIViewController(_ uiViewController: AdminChatView, context: Context) {
        // Handle updates if necessary
    }
}



struct CarDetailView: View {
    var car: Car

    var body: some View {
        VStack(alignment: .leading) {
            Text("Details for \(car.year) \(car.make) \(car.model)")
                .font(.title)
                .padding()

            Text("Color: \(car.color)")
                .font(.subheadline)
                .padding(.bottom, 10)

            Text("VIN: \(car.vin)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)

            Spacer()
        }
        .padding()
        .navigationTitle("Car Details")
    }
}
