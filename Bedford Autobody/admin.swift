import SwiftUI

struct AdminMenu: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("View Users", destination: UsersList())
                NavigationLink("Current Repairs", destination: CurrentRepairsScreen())
            }
            .navigationTitle("Admin Menu")
            
            
        }
    }
}
