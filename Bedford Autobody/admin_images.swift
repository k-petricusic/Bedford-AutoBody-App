import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct AdminImages: View {
    var car: Car
    @State private var images: [String] = [] // Array to hold image URLs
    @State private var isLoading = true // Loading state

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Images...")
                    .padding()
            } else if images.isEmpty {
                Text("No images available for this car.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                        ForEach(images, id: \ .self) { imageUrl in
                            WebImage(url: URL(string: imageUrl))
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Images for \(car.make) \(car.model)")
        .onAppear(perform: fetchImages)
    }

    private func fetchImages() {
        guard let carId = car.id, let ownerId = car.ownerId else {
            print("Error: Missing car or owner ID.")
            isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(ownerId)
            .collection("cars")
            .document(carId)
            .collection("images")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching images: \(error.localizedDescription)")
                } else {
                    self.images = snapshot?.documents.compactMap { document in
                        return document.data()["url"] as? String
                    } ?? []
                }
                isLoading = false
            }
    }
}
