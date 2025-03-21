import SwiftUI
import FirebaseFirestore

struct RepairStateSection: View {
    @State private var selectedState: String
    @State private var showConfirmation = false
    var car: Car
    @Environment(\.presentationMode) var presentationMode

    init(car: Car) {
        self.car = car
        self._selectedState = State(initialValue: car.currentRepairState)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Repair State Management")
                .font(.title2)
                .bold()

            Text("Change Repair State:")
                .font(.headline)

            Picker("Repair State", selection: $selectedState) {
                ForEach(car.repairStates, id: \.self) { state in
                    Text(state).tag(state)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)

            Button(action: { showConfirmation = true }) {
                Text("Save New State")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .alert("Confirm Update", isPresented: $showConfirmation) {
            Button("Update", action: updateRepairState)
            Button("Cancel", role: .cancel, action: {})
        }
    }

    private func updateRepairState() {
        guard let carId = car.id, let ownerId = car.ownerId else { return }

        let db = Firestore.firestore()
        db.collection("users")
            .document(ownerId)
            .collection("cars")
            .document(carId)
            .updateData(["currentRepairState": selectedState]) { error in
                if let error = error {
                    print("Error updating repair state: \(error.localizedDescription)")
                } else {
                    print("✅ Repair state updated successfully!")

                    // Send notification using NotificationHelper
                    NotificationHelper.sendPushNotification(
                        to: ownerId,
                        title: "Car Repair Update",
                        body: "Your car is now in \(selectedState) state."
                    )
                }
            }
    }
}
