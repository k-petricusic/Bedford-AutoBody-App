//
//  notification_struct.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 12/31/24.
//

import Foundation
import FirebaseFirestore

struct Notification: Identifiable, Codable {
    @DocumentID var id: String?           // Unique ID for the notification
    var userId: String                    // User ID for whom the notification is intended
    var title: String                     // Title of the notification
    var body: String                      // Notification body text
    var type: String                      // Type of notification (repair, message, etc.)
    var date: Date?                        // Timestamp when the notification was created
    var isRead: Bool                      // Whether the notification has been read
    var data: [String: String]?           // Optional additional data for navigation or context
}

struct NotificationHelper {
    static func createNotification(for userId: String, title: String, body: String, type: String, data: [String: String]?) {
        let db = Firestore.firestore()
        let notificationRef = db.collection("users").document(userId).collection("notifications").document()

        let notificationData: [String: Any] = [
            "id": notificationRef.documentID,
            "title": title,
            "body": body,
            "type": type,
            "date": Timestamp(date: Date()), // Save the current timestamp
            "isRead": false,
            "userId": userId,
            "data": data ?? [:]
        ]

        notificationRef.setData(notificationData) { error in
            if let error = error {
                print("Error creating notification: \(error.localizedDescription)")
            } else {
                print("Notification created successfully!")
            }
        }
    }
}
