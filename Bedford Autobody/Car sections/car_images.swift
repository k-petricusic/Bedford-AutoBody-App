//
//  car_images.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/14/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct CarImageCarousel: View {
    var carImages: [String]
    var isLoading: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView("Loading Images...")
                } else if carImages.isEmpty {
                    Text("No images available")
                        .foregroundColor(.gray)
                } else {
                    ForEach(carImages, id: \.self) { imageUrl in
                        WebImage(url: URL(string: imageUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 100)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
}
