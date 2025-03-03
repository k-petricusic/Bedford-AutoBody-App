//
//  car_buttons.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/14/25.
//

import SwiftUI

struct CarActionButtons: View {
    var selectedCarId: String?

    var body: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: ImagesScreen(carId: selectedCarId ?? "")) {
                ActionButton(title: "View All Images", icon: "photo.on.rectangle.angled")
            }

            NavigationLink(destination: DisplayCars(selectedCar: .constant(nil))) {
                ActionButton(title: "Change Car", icon: "arrow.2.squarepath")
            }
        }
        .padding()
    }
}

// 🔹 Styled Button Component
struct ActionButton: View {
    var title: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
