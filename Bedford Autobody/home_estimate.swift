import SwiftUI

struct JobEstimateSection: View {
    var selectedCar: Car?
    var fetchPDFURL: (@escaping (String?) -> Void) -> Void
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
                
                // Show the button only if estimateTotal > 0
                if estimateTotal > 0 {
                    Button(action: {
                        fetchPDFURL { urlString in
                            guard let urlString = urlString, let url = URL(string: urlString) else {
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
