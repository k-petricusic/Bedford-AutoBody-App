import SwiftUI

struct AdminDashboard: View {
    @State private var navigateToCustomerView = false // ✅ Track navigation state

    var body: some View {
        VStack(spacing: 20) {
            Text("Admin Dashboard")
                .font(.largeTitle)
                .bold()
            
            NavigationLink("View Users", destination: UsersList())
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

            NavigationLink("Current Repairs", destination: CurrentRepairsScreen())
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

            NavigationLink("View Chats", destination: AdminChatsListView())
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

            // 🔹 New Button to Switch to Customer Mode
            Button(action: {
                navigateToCustomerView = true
            }) {
                Text("Switch to Customer Mode")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationDestination(isPresented: $navigateToCustomerView) {
            NaviView().navigationBarBackButtonHidden(true)
        }
    }
}
