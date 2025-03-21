//
//  profile_screen.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/6/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var appData: AppDataViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeaderView(appData: appData)
                    
                    // Personal Info
                    PersonalInfoView()

                    // Account Settings
                    //AccountSettingsView()

                    // Help & Support
                    HelpSupportView()
                    
                    AccountDeletionSection()
                    
                    // Switch to Admin mode
                    SwitchToAdminView()

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
