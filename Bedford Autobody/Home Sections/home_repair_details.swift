//
//  RepairDetailsView.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/10/25.
//

import SwiftUI

struct RepairDetailsView: View {
    var selectedCar: Car

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Repair Details")
                .font(.title2)
                .fontWeight(.bold)

            Divider()

            // Current Repair State Section
            Text("Current Repair Stage:")
                .font(.headline)
                .foregroundColor(.gray)

            Text(selectedCar.currentRepairState)
                .font(.title)
                .fontWeight(.bold)

            // Repair Description
            Text(getRepairDescription(for: selectedCar.currentRepairState))
                .font(.body)
                .foregroundColor(.black)
                .padding(.top, 5)

            Divider()

            // Repair Progress Section
            Text("Repair Progress:")
                .font(.headline)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(selectedCar.repairStates.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: index <= selectedCar.repairStates.firstIndex(of: selectedCar.currentRepairState) ?? 0 ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(index <= selectedCar.repairStates.firstIndex(of: selectedCar.currentRepairState) ?? 0 ? .green : .gray)

                        Text(selectedCar.repairStates[index])
                            .font(index == selectedCar.repairStates.firstIndex(of: selectedCar.currentRepairState) ? .headline : .body)
                            .foregroundColor(index == selectedCar.repairStates.firstIndex(of: selectedCar.currentRepairState) ? .black : .gray)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Repair Details")
    }

    // Function to return a description for the current repair state
    private func getRepairDescription(for state: String) -> String {
        let repairDescriptions: [String: String] = [
            "Estimate Updates": "We are currently reviewing your car's condition and preparing an accurate estimate for the repairs needed.",
            "Parts Ordered": "The necessary parts for your repair have been ordered. We're waiting for their arrival before proceeding.",
            "Repair in Progress": "Our technicians are actively working on your vehicle, ensuring all required fixes and adjustments are being made.",
            "Painting": "Your car is in the painting stage. We're applying fresh coats to restore its look and match the original color.",
            "Final Inspection": "The repairs are almost complete. We're doing a final quality check to ensure everything is perfect before pickup.",
            "Ready for pickup": "Your vehicle is ready! You can come to the shop to pick it up at your convenience."
        ]
        
        return repairDescriptions[state] ?? "No description available."
    }
}
