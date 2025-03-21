import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EstimateSection: View {
    var selectedCar: Car?
    @Binding var selectedPDFURL: URL?
    @Binding var showPDFViewer: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Estimate")
                .font(.footnote)
                .foregroundColor(.gray)

            HStack {
                Text("$\(String(format: "%.2f", selectedCar?.estimateTotal ?? 0.00))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()
            }

            if let estimateTotal = selectedCar?.estimateTotal, estimateTotal > 0 {
                Button(action: {
                    guard let carId = selectedCar?.id, let ownerId = Auth.auth().currentUser?.uid else {
                        print("❌ Error: Missing car or user ID.")
                        return
                    }

                    fetchPDFURL(forCarId: carId, ownerId: ownerId) { urlString in
                        guard let urlString = urlString, !urlString.isEmpty else {
                            print("❌ Error: Invalid or missing PDF URL.")
                            return
                        }
                        
                        guard let url = URL(string: urlString) else {
                            print("❌ Error: Could not convert to URL: \(urlString)")
                            return
                        }

                        print("✅ Fetched PDF URL: \(url)")

                        DispatchQueue.main.async {
                            selectedPDFURL = url
                            showPDFViewer = true
                            print("✅ showPDFViewer set to: \(showPDFViewer)")
                        }
                    }
                }) {
                    Text("View Estimate")
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
        .frame(maxWidth: UIScreen.main.bounds.width * 0.92) // Makes it slightly wider
        .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6)))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 4) // Reduces padding slightly for a wider look
    }
}


