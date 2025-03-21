//
//  AdminChatViewWrapper.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 3/4/25.
//


import SwiftUI

struct AdminChatViewWrapper: UIViewControllerRepresentable {
    var userId: String

    func makeUIViewController(context: Context) -> AdminChatView {
        return AdminChatView(userId: userId)
    }

    func updateUIViewController(_ uiViewController: AdminChatView, context: Context) {}
}
