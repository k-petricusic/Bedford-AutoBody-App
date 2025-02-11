//
//  bottom_bar.swift
//  Bedford Autobody
//
//  Created by Kris at Bedford Autobody on 2/6/25.
//
import SwiftUI

struct BottomMenuView: View {
    @Binding var selectedTab: Int // Keeps track of the active tab
    var body: some View {
        HStack {
            Spacer()
            
            // Home Button
            Button(action: {
                selectedTab = 0
            }) {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                    Text("Home")
                        .font(.caption)
                }
            }
            .foregroundColor(selectedTab == 0 ? .blue : .gray)
            .padding()

            Spacer()
            
            // Cars Button
            Button(action: {
                selectedTab = 1
            }) {
                VStack {
                    Image(systemName: "car.fill")
                        .font(.system(size: 24))
                    Text("Cars")
                        .font(.caption)
                }
            }
            .foregroundColor(selectedTab == 1 ? .blue : .gray)
            .padding()

            Spacer()
            
            // Chat Button
            Button(action: {
                selectedTab = 2
            }) {
                VStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 24))
                    Text("Chat")
                        .font(.caption)
                }
            }
            .foregroundColor(selectedTab == 2 ? .blue : .gray)
            .padding()

            Spacer()
            
            // FAQ Button
            Button(action: {
                selectedTab = 3
            }) {
                VStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 24))
                    Text("FAQ")
                        .font(.caption)
                }
            }
            .foregroundColor(selectedTab == 3 ? .blue : .gray)
            .padding()

            Spacer()
            
            // Profile/User Settings Button
            Button(action: {
                selectedTab = 4
            }) {
                VStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                    Text("Profile")
                        .font(.caption)
                }
            }
            .foregroundColor(selectedTab == 4 ? .blue : .gray)
            .padding()
            
            Spacer()
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6).ignoresSafeArea(edges: .bottom))
        .shadow(radius: 2)
    }
}
