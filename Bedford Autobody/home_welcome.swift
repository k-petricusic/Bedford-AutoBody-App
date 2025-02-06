//
//  home_welcome.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 1/17/25.
//

import SwiftUI

struct WelcomeMessage: View {
    var firstName: String?
    var lastName: String?
    var colorScheme: ColorScheme

    var body: some View {
        Text("Welcome, \(firstName ?? "User") \(lastName ?? "")!")
            .font(.largeTitle)
            .bold()
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.top, 20)
    }
}

