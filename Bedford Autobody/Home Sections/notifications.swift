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
                                .animation(.easeInOut(duration: 1.5), value: notification.isRead)
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
        fetchNotifications { fetchedNotifications, error in
            if let error = error {
                self.errorMessage = error
            } else {
                self.notifications = fetchedNotifications
                markAllAsRead()
            }
            self.isLoading = false
        }
    }

    func markAllAsRead() {
        for index in notifications.indices where !notifications[index].isRead {
            if let notificationId = notifications[index].id {
                markNotificationAsRead(notificationId: notificationId) { success in
                    if success {
                        withAnimation {
                            notifications[index].isRead = true
                        }
                    }
                }
            }
        }
    }

    func deleteNotifications(at offsets: IndexSet) {
        for index in offsets {
            if let notificationId = notifications[index].id {
                deleteNotification(notificationId: notificationId) { success in
                    if success {
                        notifications.remove(atOffsets: offsets)
                    }
                }
            }
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
