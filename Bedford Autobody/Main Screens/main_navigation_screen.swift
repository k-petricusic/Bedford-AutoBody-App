//
//  main_navigation_screen.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/7/25.
//

import SwiftUI

struct NaviView: View {
    @StateObject private var appData = AppDataViewModel() // ✅ Load global data once
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case 0: HomeView(appData: appData) // ✅ Pass only where needed
                    case 1: CarView()
                    case 2: ChatView()
                    case 3: FAQView()
                    case 4: ProfileView(appData: appData)
                    default: HomeView(appData: appData)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 15)

                BottomMenuView(selectedTab: $selectedTab)
                    .background(Color(.systemGray6).ignoresSafeArea(edges: .bottom))
                    .shadow(radius: 2)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
