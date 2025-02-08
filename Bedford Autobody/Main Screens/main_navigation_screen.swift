//
//  main_navigation_screen.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/7/25.
//

import SwiftUI

struct NaviView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Content Area
            ZStack {
                switch selectedTab {
                case 0: HomeView()
                case 1: CarView()
                case 2: ChatViewTEST()
                case 3: FAQView()
                case 4: ProfileView()
                default: HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 15) // Adds space above the bottom bar

            // Custom Bottom Bar
            BottomMenuView(selectedTab: $selectedTab)
                .background(Color(.systemGray6).ignoresSafeArea(edges: .bottom)) // Prevents clipping
                .shadow(radius: 2)
        }
    }
}
