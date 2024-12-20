import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HomeScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var email: String
    @State private var firstName: String? = nil
    @State private var lastName: String? = nil
    @State private var isLoggedOut = false
    @State private var cars: [Car] = []
    @State private var selectedCar: Car? = nil
    @State private var showCarSelection = false
    @State private var showMaintenanceLog = false
    @State private var showChatView = false // State variable for ChatView navigation
    @State private var showAdminMenu = false // State for Admin Menu

    // Define the admin email
    let adminEmail = "K@gmail.com"

    // Fetch user information from Firestore
    func fetchUserName() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                self.firstName = "User"
                self.lastName = ""
            } else if let document = document, document.exists {
                let data = document.data()
                self.firstName = data?["firstName"] as? String ?? "User"
                self.lastName = data?["lastName"] as? String ?? ""
            } else {
                self.firstName = "User"
                self.lastName = ""
            }
        }
    }

    func fetchCarsFromFirestore() {
        guard let user = Auth.auth().currentUser else { return }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("cars")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching cars: \(error.localizedDescription)")
                } else {
                    self.cars = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Car.self)
                    } ?? []

                    db.collection("users").document(user.uid).getDocument { document, error in
                        if let error = error {
                            print("Error fetching last selected car ID: \(error.localizedDescription)")
                        } else if let document = document, document.exists {
                            if let lastSelectedCarId = document.data()?["lastSelectedCarId"] as? String {
                                if let car = self.cars.first(where: { $0.id == lastSelectedCarId }) {
                                    self.selectedCar = car
                                }
                            }
                        }
                    }
                }
            }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome, \(firstName ?? "User") \(lastName ?? "")!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 50)

                if selectedCar == nil {
                    VStack {
                        Text("Please select a car")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding()

                        Button(action: {
                            showCarSelection = true
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
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Car:")
                            .font(.headline)

                        HStack {
                            Text("Year:")
                                .font(.subheadline)
                                .bold()
                            Text(selectedCar?.year ?? "N/A")
                                .font(.subheadline)
                        }

                        HStack {
                            Text("Maker:")
                                .font(.subheadline)
                                .bold()
                            Text(selectedCar?.make ?? "N/A")
                                .font(.subheadline)
                        }

                        HStack {
                            Text("Model:")
                                .font(.subheadline)
                                .bold()
                            Text(selectedCar?.model ?? "N/A")
                                .font(.subheadline)
                        }

                        HStack {
                            Text("Color:")
                                .font(.subheadline)
                                .bold()
                            Text(selectedCar?.color ?? "N/A")
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.top, 20)
                }

                // New "Go to Chat" button moved above Logout
                Button(action: {
                    showChatView = true
                }) {
                    Text("Go to Chat")
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)

                // Admin Menu Button only for admin email
                if email == adminEmail {
                    Button(action: {
                        showAdminMenu = true
                    }) {
                        Text("Admin Menu")
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 200)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }

                // Logout button
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        isLoggedOut = true
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                }) {
                    Text("Logout")
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(10)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                fetchUserName()
                fetchCarsFromFirestore()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink(destination: DisplayCars(cars: $cars, selectedCar: $selectedCar)) {
                            Label("Your Cars", systemImage: "car.fill")
                        }

                        NavigationLink(destination: MaintenanceLogScreen(car: $selectedCar)) {
                            Label("Maintenance Log", systemImage: "wrench.fill")
                        }

                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                                isLoggedOut = true
                            } catch let signOutError as NSError {
                                print("Error signing out: %@", signOutError)
                            }
                        }) {
                            Label("Logout", systemImage: "arrow.right.circle.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
            }

            NavigationLink(destination: LoginOptions(), isActive: $isLoggedOut) {
                EmptyView()
            }

            NavigationLink(destination: DisplayCars(cars: $cars, selectedCar: $selectedCar), isActive: $showCarSelection) {
                EmptyView()
            }

            NavigationLink(destination: MaintenanceLogScreen(car: $selectedCar), isActive: $showMaintenanceLog) {
                EmptyView()
            }

            // NavigationLink to ChatView
            NavigationLink(
                destination: VStack {
                    ChatViewWrapper()
                        .navigationTitle("Bedford Autobody")
                        .padding(.top, 20) // Adds space below the title
                },
                isActive: $showChatView
            ) {
                EmptyView()
            }

            // NavigationLink to AdminMenu
            NavigationLink(destination: AdminMenu(), isActive: $showAdminMenu) {
                EmptyView()
            }
        }
    }
}

// Wrapper for ChatView (UIKit in SwiftUI)
struct ChatViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ChatView {
        return ChatView()
    }

    func updateUIViewController(_ uiViewController: ChatView, context: Context) {}
}
