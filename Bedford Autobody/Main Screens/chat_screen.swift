import SwiftUI

struct ChatView: View {
    var body: some View {
        ChatViewControllerWrapper() // ✅ Directly loads the UIKit-based chat screen
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
    }
}
