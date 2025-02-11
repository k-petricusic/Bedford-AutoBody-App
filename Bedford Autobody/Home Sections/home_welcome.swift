//
//  home_welcome.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 1/17/25.
//

import SwiftUI

struct WelcomeMessage: View {
    var firstName: String?
    var colorScheme: ColorScheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, \(firstName ?? "User")")
                    .font(.title3) // Slightly smaller than title
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Text("Welcome to Bedford Autobody")
                    .font(.footnote) // Smaller than subheadline
                    .foregroundColor(.gray)
            }
            Spacer() // Pushes content to the left
        }
        .padding(.horizontal) // Ensures it's aligned properly within the screen
        .padding(.top, 8)
    }
}
