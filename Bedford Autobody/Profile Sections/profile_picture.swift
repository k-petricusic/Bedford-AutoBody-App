import SwiftUI
import PhotosUI

struct ProfileHeaderView: View {
    @ObservedObject var appData: AppDataViewModel // ✅ Uses preloaded data
    @State private var profileImage: UIImage? = nil
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
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .background(Circle().fill(Color(.systemGray6)))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else if let urlString = appData.profilePictureURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure(_):
                            Image(systemName: "person.crop.circle.fill").resizable()
                        default:
                            ProgressView() // ✅ Placeholder while loading
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .background(Circle().fill(Color(.systemGray6)))
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
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
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) {
            if let newItem = selectedItem {
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
                                self.profileImage = nil // ✅ Clear local image so AsyncImage reloads
                                appData.profilePictureURL = url // ✅ Update global profile picture URL
                                self.isUploading = false
                            }
                        }
                    } else {
                        self.isUploading = false
                    }
                case .failure(let error):
                    print("❌ Error loading image: \(error.localizedDescription)")
                    self.isUploading = false
                }
            }
        }
    }
}
