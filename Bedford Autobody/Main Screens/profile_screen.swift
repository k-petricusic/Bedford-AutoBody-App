//
//  profile_screen.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/6/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeaderView()
                    
                    // Personal Info
                    PersonalInfoView()

                    // Account Settings
                    AccountSettingsView()

                    // Help & Support
                    HelpSupportView()

                    // Logout Button
                    LogoutButtonView()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
