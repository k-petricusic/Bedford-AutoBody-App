import SwiftUI

struct CarDetailsSection: View {
    var car: Car

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Car Details")
                .font(.title2)
                .bold()
            Text("Make: \(car.make)")
            Text("Model: \(car.model)")
            Text("Year: \(car.year)")
            Text("VIN: \(car.vin)")
            Text("Color: \(car.color)")
            Text("Current Repair State: \(car.currentRepairState)")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
