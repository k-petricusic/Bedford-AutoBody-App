import FirebaseFirestore
import FirebaseFunctions

struct NotificationHelper {
    static func sendPushNotification(to userId: String, title: String, body: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let token = document.data()?["fcmToken"] as? String {
                    let message: [String: Any] = [
                        "to": token,
                        "notification": ["title": title, "body": body, "sound": "default"],
                        "data": ["click_action": "FLUTTER_NOTIFICATION_CLICK"]
                    ]

                    // Send to Firebase Cloud Function
                    sendToFirebase(message: message)
                }
            }
        }
    }

    static func sendToFirebase(message: [String: Any]) {
        let functions = Functions.functions()
        functions.httpsCallable("sendPushNotification").call(message) { result, error in
            if let error = error {
                print("❌ Error sending push notification: \(error.localizedDescription)")
            } else {
                print("✅ Push notification sent successfully!")
            }
        }
    }
}
