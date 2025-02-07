import SwiftUI
import FirebaseAuth

struct JobEstimateSection: View {
    var selectedCar: Car?
    @Binding var selectedPDFURL: URL?
    @Binding var showPDFViewer: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Job Estimate")
                .font(.title2)
                .bold()
                .foregroundColor(.blue)

            if let estimateTotal = selectedCar?.estimateTotal {
                Text("Estimate Total: $\(String(format: "%.2f", estimateTotal))")
                    .font(.headline)
                    .foregroundColor(estimateTotal > 0 ? .green : .black)

                // Show "View Estimate" button only if estimateTotal > 0
                if estimateTotal > 0 {
                    Button(action: {
                        guard let carId = selectedCar?.id, let ownerId = Auth.auth().currentUser?.uid else {
                            print("Error: Missing car or user ID.")
                            return
                        }

                        fetchPDFURL(forCarId: carId, ownerId: ownerId) { urlString in
                            guard let urlString = urlString, let url = URL(string: urlString) else {
                                print("Error: Invalid or missing PDF URL.")
                                return
                            }
                            print("Fetched URL: \(url)")
                            DispatchQueue.main.async {
                                selectedPDFURL = url
                                showPDFViewer = true
                            }
                        }
                    }) {
                        Text("View Estimate")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Text("Estimate Total: Not Available")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.top, 20)
    }
}
