import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MaintenanceLogScreen: View {
    @Binding var car: Car?
    @State private var maintenanceType: String = ""
    @State private var showAlert = false
    @State private var logs: [MaintenanceLog] = [] // Container for all logs

    var body: some View {
        VStack {
            Text("Maintenance Log")
                .font(.largeTitle)
                .padding()
            
            if let car = car {
                List(logs) { log in
                    VStack(alignment: .leading) {
                        Text(log.type)
                            .font(.headline)
                        Text("Date: \(log.date.formatted())")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: {
                    showAlert = true
                }) {
                    Text("Add Maintenance Log")
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert("Add Maintenance Log", isPresented: $showAlert) {
                    TextField("Maintenance Type", text: $maintenanceType)
                    Button("Save") {
                        addMaintenanceLog()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } else {
                Text("No car selected. Please select a car first")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            fetchMaintenanceLogs()  // Listen for real-time updates
        }
    }
    
    private func addMaintenanceLog() {
        guard let carId = car?.id else {
            print("Car ID is nil. Cannot create Maintenance Log.")
            return
        }
        
        if maintenanceType.isEmpty {
            print("Maintenance type is empty. Log not created.")
            return
        }
        
        let newLog = MaintenanceLog(
            id: UUID().uuidString,
            carId: carId,
            type: maintenanceType,
            date: Date()
        )
        
        saveLogToFirestore(log: newLog)
        logs.append(newLog) // Update local logs immediately after adding
        maintenanceType = ""
    }
    
    private func saveLogToFirestore(log: MaintenanceLog) {
        guard let carId = car?.id else { return }
        let db = Firestore.firestore()
        
        do {
            try db.collection("cars").document(carId).collection("maintenanceLogs")
                .document(log.id ?? "PROBLEM HERE")
                .setData(from: log) { error in
                    if let error = error {
                        print("Error saving log to Firestore: \(error.localizedDescription)")
                    } else {
                        print("Log successfully saved!")
                    }
                }
        } catch {
            print("Error encoding log: \(error.localizedDescription)")
        }
    }
    
    private func fetchMaintenanceLogs() {
        guard let carId = car?.id else { return }
        let db = Firestore.firestore()

        // Listen for real-time updates in the 'maintenanceLogs' collection
        db.collection("cars").document(carId).collection("maintenanceLogs")
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
