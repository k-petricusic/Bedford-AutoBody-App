import SwiftUI

struct AdminMenu: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("View Users", destination: UsersList())
                NavigationLink("Manage Cars", destination: Text("Manage Cars Screen"))
                NavigationLink("System Settings", destination: Text("System Settings Screen"))
            }
            .navigationTitle("Admin Menu")
        }
    }
}
