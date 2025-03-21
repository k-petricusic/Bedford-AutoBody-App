//
//  LoadingScreen.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 3/11/25.
//
import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        VStack {
            ProgressView("Checking permissions...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        }
    }
}
