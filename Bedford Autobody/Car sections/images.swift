import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

struct ImagesScreen: View {
    var carId: String
    @State private var images: [String] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var selectedImage: IdentifiableIndex? = nil

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Images...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .font(.headline)
                            .foregroundColor(.red)
                        Button("Retry") {
                            fetchImages()
                        }
                        .padding()
                    }
                } else if images.isEmpty {
                    Text("No images found.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                            ForEach(images.indices, id: \.self) { index in
                                WebImage(url: URL(string: images[index]))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedImage = IdentifiableIndex(id: index)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Car Images")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: fetchImages)
            .fullScreenCover(item: $selectedImage) { imageItem in
                ImageFullScreenView(images: images, selectedIndex: imageItem.id)
            }
        }
    }
    
    private func fetchImages() {
        fetchCarImages(carId: carId) { images, error in
            self.images = images
            self.errorMessage = error
            self.isLoading = false
        }
    }
}

struct ImageFullScreenView: View {
    let images: [String]
    @State var selectedIndex: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(images.indices, id: \.self) { index in
                WebImage(url: URL(string: images[index]))
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        )
    }
}
