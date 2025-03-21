import SwiftUI
import FirebaseFirestore

struct UsersList: View {
    @State private var users: [User] = []
    @State private var filteredUsers: [User] = [] // Users filtered by search
    @State private var searchText: String = ""    // Text entered in the search bar
    @State private var isDeleteMode: Bool = false // Track delete mode state
    @State private var showConfirmationDialog = false
    @State private var selectedUser: User? = nil

    var body: some View {
        VStack {
            // Search bar
            TextField("Search users...", text: $searchText)
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)

            // Explanation of delete mode (if active)
            if isDeleteMode {
                Text("Tap the trash icon next to a user to delete.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }

            // List of users
            List {
                ForEach(filteredUsers, id: \.id) { user in
                    HStack {
                        NavigationLink(destination: UserDetailView(user: user)) {
                            VStack(alignment: .leading) {
                                Text(user.email)
                                    .font(.headline)
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        if isDeleteMode {
                            Button(action: {
                                selectedUser = user
                                showConfirmationDialog = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
            }
            .onAppear {
                fetchUsers() // Load users when the view appears
            }
            .alert(isPresented: $showConfirmationDialog) {
                Alert(
                    title: Text("Delete User"),
                    message: Text("Are you sure you want to delete \(selectedUser?.firstName ?? "this user")?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let user = selectedUser {
                            deleteUser(user)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onChange(of: searchText) {
            applySearchFilter() // No need for `_ in`, directly call function
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isDeleteMode ? "Done" : "Delete") {
                    isDeleteMode.toggle() // Toggle delete mode
                }
                .foregroundColor(isDeleteMode ? .red : .blue)
            }
        }
        .navigationTitle("Users List")
    }

    // Fetch users from Firestore
    func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            self.users = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                return User(
                    id: doc.documentID,
                    email: data["email"] as? String ?? "",
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? ""
                )
            } ?? []
            self.applySearchFilter() // Apply the search filter to initialize filteredUsers
        }
    }

    // Filter users based on the search text
    func applySearchFilter() {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { user in
                user.email.lowercased().contains(searchText.lowercased()) ||
                user.firstName.lowercased().contains(searchText.lowercased()) ||
                user.lastName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    // Delete a user
    func deleteUser(_ user: User) {
        let db = Firestore.firestore()
        db.collection("users").document(user.id).delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("User deleted successfully.")
                fetchUsers() // Refresh the list
            }
        }
    }
}

// User model
struct User: Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
}
