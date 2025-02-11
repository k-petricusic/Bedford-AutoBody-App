//
//  home_car_info.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 1/17/25.
//

import SwiftUI

struct CarDetailsView: View {
    var selectedCar: Car?

    var body: some View {
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
}
