import SwiftUI

struct EstimatedPickupView: View {
    var selectedCar: Car?
    @Environment(\.colorScheme) var colorScheme
    @State private var estimatedPickupDate: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estimated Pickup Date")
                .font(.footnote)
                .foregroundColor(.gray)

            HStack {
                Text(estimatedPickupDate ?? "Waiting for Drop-off")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: UIScreen.main.bounds.width * 0.92)
        .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6)))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 4)
        .onAppear {
            fetchPickupDate()
        }
    }

    private func fetchPickupDate() {
        guard let carId = selectedCar?.id, let ownerId = selectedCar?.ownerId else { return }
        fetchEstimatedPickupDate(userId: ownerId, carId: carId) { date in
            DispatchQueue.main.async {
                estimatedPickupDate = date ?? "Waiting for Drop-off"
            }
        }
    }
}
