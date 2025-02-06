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
            
            Button(action: {
                selectedTab = 2
            }) {
                VStack {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 24))
                    Text("Notifications")
                        .font(.caption)
                }
            }
            .foregroundColor(selectedTab == 2 ? .blue : .gray)
            .padding()

            Spacer()
            
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
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity) // Ensure it stretches across the screen
        .background(Color(.systemGray6).ignoresSafeArea(edges: .bottom)) // Extend background past safe area
        .shadow(radius: 2)
    }
}
