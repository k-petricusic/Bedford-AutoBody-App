import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
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
                HomeScreen(email: .constant(user.email ?? ""))
            } else {
                // User is not logged in, show the IntroScreen
                IntroScreen()
            }
        }
    }
}
