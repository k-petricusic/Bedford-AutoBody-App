import SwiftUI

struct CarInfoView: View {
    var selectedCar: Car? // Ensure this is explicitly declared as optional

    init(selectedCar: Car?) { // Explicitly define the initializer
        self.selectedCar = selectedCar
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(selectedCar?.year ?? "Unknown") \(selectedCar?.make ?? "Unknown") \(selectedCar?.model ?? "Unknown")")
                .font(.title)
                .bold()

            Text("Color: \(selectedCar?.color ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("VIN: \(selectedCar?.vin ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
