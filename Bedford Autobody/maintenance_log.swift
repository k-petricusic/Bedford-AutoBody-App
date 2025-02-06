import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MaintenanceLogScreen: View {
    @Binding var car: Car?
    @State private var maintenanceType: String = ""
    @State private var showAlert = false
    @State private var logs: [MaintenanceLog] = [] // Container for all logs
    @State private var currentUserEmail: String? = nil // Tracks the current user's email
    @State private var opacity: Double = 0.0 // For fade-in animation

    var body: some View {
        VStack {
            Text("Maintenance Log")
                .font(.largeTitle)
                .padding()
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        opacity = 1.0
                    }
                }
            
            if let car = car {
                if logs.isEmpty {
                    Text("No maintenance logs available for this car.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .opacity(opacity) // Apply fade-in effect
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.0)) {
                                opacity = 1.0
                            }
                        }
                } else {
                    List(logs) { log in
                        VStack(alignment: .leading) {
                            Text(log.type)
                                .font(.headline)
                            Text("Date: \(log.date.formatted())")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .opacity(opacity) // Apply fade-in effect for each log
                        .onAppear {
                            withAnimation(.easeIn(duration: 0.5)) {
                                opacity = 1.0
                            }
                        }
                    }
                }
            } else {
                Text("No car selected. Please select a car first.")
                    .foregroundColor(.gray)
                    .opacity(opacity) // Apply fade-in effect
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.0)) {
                            opacity = 1.0
                        }
                    }
            }
        }
        .onAppear {
            fetchMaintenanceLogs()  // Listen for real-time updates
            fetchCurrentUserEmail() // Fetch the current user's email
        }
    }
    
    private func fetchCurrentUserEmail() {
        if let user = Auth.auth().currentUser {
            currentUserEmail = user.email
            print("Fetched Email: \(currentUserEmail ?? "No email found")") // Debugging line
        } else {
            print("No user is logged in.") // Debugging line
        }
    }

    private func fetchMaintenanceLogs() {
        guard let car = car, let carId = car.id else { return }
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        // Listen for real-time updates in the 'maintenanceLogs' collection
        db.collection("users")
            .document(user.uid)
            .collection("cars")
            .document(carId)
            .collection("maintenanceLogs")
            .order(by: "date", descending: true)  // Optional: to show most recent first
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching logs: \(error.localizedDescription)")
                    return
                }

                // Update the local `logs` array whenever data changes
                self.logs = snapshot?.documents.compactMap { document in
                    try? document.data(as: MaintenanceLog.self)
                } ?? []
            }
    }
}
