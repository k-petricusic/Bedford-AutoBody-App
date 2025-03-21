import SwiftUI
import FirebaseFirestore

struct EstimateManagementSection: View {
    var car: Car
    @State private var showEstimateAlert = false
    @State private var newEstimate: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Estimate Management")
                .font(.title2)
                .bold()

            Button(action: { showEstimateAlert = true }) {
                Text("Update Estimate Total")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .alert("Update Estimate Total", isPresented: $showEstimateAlert) {
                VStack {
                    TextField("Enter new estimate", text: $newEstimate)
                        .keyboardType(.decimalPad)
                    Button("Save", action: updateEstimateTotal)
                    Button("Cancel", role: .cancel, action: {})
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private func updateEstimateTotal() {
        guard let carId = car.id, let ownerId = car.ownerId else {
            print("❌ Error: Missing car or owner ID.")
            return
        }

        guard let newEstimateValue = Double(newEstimate) else {
            print("❌ Error: Invalid estimate value.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(ownerId)
            .collection("cars")
            .document(carId)
            .updateData(["estimateTotal": newEstimateValue]) { error in
                if let error = error {
                    print("❌ Error updating estimate total: \(error.localizedDescription)")
                } else {
                    print("✅ Estimate total updated successfully!")
                }
            }
    }
}
