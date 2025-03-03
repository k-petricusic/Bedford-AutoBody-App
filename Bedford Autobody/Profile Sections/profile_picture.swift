import SwiftUI
import PhotosUI
import FirebaseStorage

struct ProfileHeaderView: View {
    @State private var profileImage: UIImage? = nil
    @State private var profileImageURL: String? = nil
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isUploading = false

    var body: some View {
        VStack {
            ZStack {
                if isUploading {
                    ProgressView()
                        .frame(width: 100, height: 100)
                        .background(Circle().fill(Color(.systemGray6)))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .background(Circle().fill(Color(.systemGray6)))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else if let profileImageURL = profileImageURL, let url = URL(string: profileImageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                        default:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                        }
                    }
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .background(Circle().fill(Color(.systemGray6)))
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .background(Circle().fill(Color(.systemGray6)))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }

                // Edit Button Overlay
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "pencil")
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .offset(x: 35, y: 35)
            }
        }
        .onAppear {
            fetchProfilePictureURL { url in
                DispatchQueue.main.async {
                    self.profileImageURL = url
                }
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            if let newItem = newItem {
                loadSelectedImage(from: newItem)
            }
        }
    }

    private func loadSelectedImage(from item: PhotosPickerItem) {
        isUploading = true
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.profileImage = uiImage
                        uploadProfilePicture(image: uiImage) { url in
                            DispatchQueue.main.async {
                                self.profileImageURL = url
                                self.isUploading = false
                            }
                        }
                    } else {
                        self.isUploading = false
                    }
                case .failure(let error):
                    print("Error loading image: \(error.localizedDescription)")
                    self.isUploading = false
                }
            }
        }
    }
}
