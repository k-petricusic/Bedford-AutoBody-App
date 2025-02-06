import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotificationsScreen: View {
    @State private var notifications: [Notification] = [] // List of notifications
    @State private var isLoading = true // Loading state
    @State private var errorMessage: String? = nil // Error state
    @State private var isPulsing = false // Pulse animation state

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Notifications...")
                    .padding()
            } else if let errorMessage = errorMessage {
                VStack(spacing: 10) {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: fetchAndMarkAsRead) {
                        Text("Retry")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else if notifications.isEmpty {
                VStack(spacing: 20) {
                    Text("No notifications available.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .opacity(isPulsing ? 1 : 0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)

                    Image(systemName: "bell.slash.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .scaleEffect(isPulsing ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                }
                .padding()
                .onAppear {
                    isPulsing = true
                }
            } else {
                List {
                    ForEach(notifications) { notification in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(notification.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(notification.body)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if let date = notification.date {
                                Text(formatDate(date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            Color(notification.isRead ? .clear : .blue.opacity(0.1))
                                .animation(.easeInOut(duration: 1.5), value: notification.isRead) // Smooth fade animation
                        )
                        .cornerRadius(8)
                    }
                    .onDelete(perform: deleteNotifications)
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    fetchAndMarkAsRead()
                }
            }
        }
        .padding()
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchAndMarkAsRead)
    }

    func fetchAndMarkAsRead() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in."
            isLoading = false
            return
        }

        db.collection("users").document(userId).collection("notifications")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                    self.errorMessage = "Failed to fetch notifications."
                } else {
                    self.notifications = snapshot?.documents.compactMap { document in
                        try? document.data(as: Notification.self)
                    } ?? []

                    // Mark unread notifications as read
                    let unreadNotifications = self.notifications.filter { !$0.isRead }
                    for notification in unreadNotifications {
                        markAsRead(notification, userId: userId)
                    }
                }
                self.isLoading = false
            }
    }

    func markAsRead(_ notification: Notification, userId: String) {
        guard let notificationId = notification.id else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("notifications").document(notificationId)
            .updateData(["isRead": true]) { error in
                if let error = error {
                    print("Error marking notification as read: \(error.localizedDescription)")
                } else {
                    if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                        withAnimation {
                            notifications[index].isRead = true
                        }
                    }
                }
            }
    }

    func deleteNotifications(at offsets: IndexSet) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }

        for index in offsets {
            let notification = notifications[index]
            guard let notificationId = notification.id else { continue }

            db.collection("users").document(userId).collection("notifications").document(notificationId)
                .delete { error in
                    if let error = error {
                        print("Error deleting notification: \(error.localizedDescription)")
                    } else {
                        print("Notification deleted successfully!")
                    }
                }
        }

        notifications.remove(atOffsets: offsets)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
