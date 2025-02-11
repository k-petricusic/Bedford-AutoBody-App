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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repair Progress")
                .font(.footnote)
                .foregroundColor(.gray)

            HStack {
                Text(selectedCar?.currentRepairState ?? "No repair state available")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: animatedProgress * UIScreen.main.bounds.width * 0.8, height: 6)

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
            .padding(.vertical, 8)

            if let selectedCar = selectedCar {
                NavigationLink(destination: RepairDetailsView(selectedCar: selectedCar)) {
                    Text("View Details")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .frame(maxWidth: UIScreen.main.bounds.width * 0.92)
        .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6)))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 4)
        .confettiCannon(counter: $confettiCounter, num: 50, colors: [.blue, .green, .yellow, .red]) // Confetti effect
    }
}
