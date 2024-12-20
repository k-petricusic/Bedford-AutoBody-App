//
//  chat_helper.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 12/19/24.
//
import UIKit
import MessageKit
import FirebaseFirestore
import FirebaseAuth


// Sender struct to represent both the current user and the bodyshop user
struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

// Message struct to represent each message
struct Message: MessageType {
    var sender: any MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}
