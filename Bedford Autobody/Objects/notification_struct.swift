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

