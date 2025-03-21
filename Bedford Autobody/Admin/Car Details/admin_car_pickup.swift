//
//  admin_car_pickup.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 3/5/25.
//

import SwiftUI
import FirebaseFirestore

struct PickupDateUpdateSection: View {
    var car: Car
    @State private var newPickupDate = Date()
    @State private var showUpdateAlert = false
    @State private var currentPickupDate: String = "Not Set"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Update Estimated Pickup Date")
                .font(.title2)
                .bold()

            HStack {
                Text("Current: \(currentPickupDate)")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.bottom, 5)

            DatePicker("Select New Date", selection: $newPickupDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding(.horizontal)

            Button(action: { showUpdateAlert = true }) {
                Text("Save Pickup Date")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .alert("Confirm Update", isPresented: $showUpdateAlert) {
            Button("Save", action: updatePickupDate)
            Button("Cancel", role: .cancel, action: {})
        }
        .onAppear {
            fetchCurrentPickupDate()
        }
    }

    private func fetchCurrentPickupDate() {
        guard let carId = car.id, let ownerId = car.ownerId else { return }

        let db = Firestore.firestore()
        db.collection("users")
            .document(ownerId)
            .collection("cars")
            .document(carId)
            .getDocument { document, error in
                if let document = document, document.exists {
                    if let date = document.data()?["estimatedPickupDate"] as? String {
                        DispatchQueue.main.async {
                            currentPickupDate = date
                        }
                    }
                }
            }
    }

    private func updatePickupDate() {
        guard let carId = car.id, let ownerId = car.ownerId else { return }

        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let formattedDate = dateFormatter.string(from: newPickupDate)

        db.collection("users")
            .document(ownerId)
            .collection("cars")
            .document(carId)
            .updateData(["estimatedPickupDate": formattedDate]) { error in
                if let error = error {
                    print("❌ Error updating pickup date: \(error.localizedDescription)")
                } else {
                    print("✅ Pickup date updated successfully!")
                    sendPickupDateUpdateNotification(ownerId: ownerId, carId: carId, newDate: formattedDate)
                    DispatchQueue.main.async {
                        currentPickupDate = formattedDate
                    }
                }
            }
    }

    private func sendPickupDateUpdateNotification(ownerId: String, carId: String, newDate: String) {
        NotificationHelper.sendPushNotification(
            to: ownerId,
            title: "Pickup Date Updated",
            body: "Your car \(car.make) \(car.model) is now scheduled for pickup on \(newDate)."
        )
    }
}

