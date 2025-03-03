//
//  chat_wrapper.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/14/25.
//

import SwiftUI
import UIKit

struct ChatViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Chat {
        return Chat() // ✅ Initializes and returns the UIKit-based Chat view
    }

    func updateUIViewController(_ uiViewController: Chat, context: Context) {
        // No updates needed
    }
}
