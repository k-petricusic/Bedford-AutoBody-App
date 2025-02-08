import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import SwiftUI
import FirebaseAuth


class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()

        // Request Notification Permissions
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            } else {
                print("Notification permissions granted: \(granted)")
            }
        }

        // Register for remote notifications
        application.registerForRemoteNotifications()

        // Set Messaging Delegate
        Messaging.messaging().delegate = self

        return true
    }

    // Handle APNs Device Token Registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass the device token to Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
        print("APNs device token registered: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }

    // Handle APNs Device Token Registration Failure
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // Handle FCM Token Refresh
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            print("FCM Token refreshed: \(fcmToken)")
            // Send the FCM token to your server or use it for debugging
        } else {
            print("Failed to retrieve FCM Token")
        }
    }

    // Handle Incoming Notification in Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        print("Notification received while app in foreground: \(content.title) - \(content.body)")
        completionHandler([.banner, .sound]) // Display banner and play sound
    }

    // Handle Notification Tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        print("Notification tapped: \(content.title) - \(content.body)")
        completionHandler()
    }

    // Optional: Add debugging for Auto Layout Constraint Issues
    override func awakeFromNib() {
        super.awakeFromNib()
        NSLayoutConstraint.activate([])
        print("Debugging activated: Constraint issues will be logged.")
    }
}


@main
struct Bedford_AutobodyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            // Check if the user is logged in
            if let user = Auth.auth().currentUser {
                // User is logged in, show the HomeScreen
                NaviView()
            } else {
                // User is not logged in, show the IntroScreen
                IntroScreen()
            }
        }
    }
}
