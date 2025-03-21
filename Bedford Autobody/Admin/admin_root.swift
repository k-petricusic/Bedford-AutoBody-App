import SwiftUI

struct AdminRootView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Admin Content Area
            ZStack {
                switch selectedTab {
                case 0:
                    AdminDashboard()
                case 1:
                    UsersList()
                case 2:
                    CurrentRepairsScreen()
                case 3:
                    AdminChatsListView() // ✅ Show chats screen when selected
                default:
                    AdminDashboard()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 15)

            // Custom Admin Bottom Bar
            AdminBottomMenu(selectedTab: $selectedTab)
                .background(Color(.systemGray6).ignoresSafeArea(edges: .bottom))
                .shadow(radius: 2)
        }
    }
}
