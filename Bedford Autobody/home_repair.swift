//
//  home_repair.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 1/17/25.
//

import SwiftUI
import ConfettiSwiftUI

struct RepairProgressView: View {
    var selectedCar: Car?
    @Binding var animatedProgress: Double
    @Binding var carOffsetY: CGFloat
    @Binding var confettiCounter: Int

    var body: some View {
        VStack {
            Text("Repair Progress")
                .font(.headline)
                .padding(.bottom, 10)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)

                Rectangle()
                    .fill(Color.blue)
                    .frame(width: animatedProgress * UIScreen.main.bounds.width * 0.8, height: 4)
                    .cornerRadius(2)

                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
                .offset(x: animatedProgress * UIScreen.main.bounds.width * 0.8 - 18, y: carOffsetY)
            }
            .padding(.horizontal)

            if let currentRepairState = selectedCar?.currentRepairState,
               let repairStates = selectedCar?.repairStates,
               let currentIndex = repairStates.firstIndex(of: currentRepairState) {
                Text("\(currentRepairState) (\(currentIndex + 1) of \(repairStates.count))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else {
                Text("No repair state available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .confettiCannon(counter: $confettiCounter, num: 50, colors: [.blue, .green, .yellow, .red]) // Confetti effect
    }
}
