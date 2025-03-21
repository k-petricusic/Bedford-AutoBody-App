import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class AdminChatView: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    private let currentUser = Sender(senderId: "admin", displayName: "Admin")
    private let db = Firestore.firestore()
    private var messages = [MessageType]()
    private var selectedUserId: String // The customer ID for this chat
    private let timeIntervalThreshold: TimeInterval = 300 // 5 minutes
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(userId: String) {
        self.selectedUserId = userId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        setupMessageKit()
        fetchMessages(for: selectedUserId)
    }
    
    private func setupActivityIndicator() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    private func setupMessageKit() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholder = "Type a message..."
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newMessage = Message(
            sender: currentUser,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(text)
        )

        saveMessageToFirestore(newMessage)
        
        DispatchQueue.main.async {
            self.messages.append(newMessage)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }

        // ✅ Fetch messages again to ensure UI is updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fetchMessages(for: self.selectedUserId)
        }

        inputBar.inputTextView.text = ""
        
        // Notify the customer about the new message
        sendNotificationToCustomer(message: text)
    }


    private func saveMessageToFirestore(_ message: Message) {
        let text = extractText(from: message)

        let messageData: [String: Any] = [
            "senderId": message.sender.senderId, // ✅ Correct sender ID
            "receiverId": selectedUserId, // ✅ Message is for the customer
            "userId": selectedUserId, // ✅ User ID must match the customer
            "displayName": message.sender.displayName,
            "messageId": message.messageId,
            "sentDate": message.sentDate,
            "text": text,
            "isRead": false // ✅ Admin messages should be unread for the customer
        ]

        db.collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("❌ Error saving message: \(error.localizedDescription)")
            } else {
                print("✅ Message saved successfully with isRead: false")
            }
        }
    }



    private func sendNotificationToCustomer(message: String) {
        let db = Firestore.firestore()

        db.collection("users").document(selectedUserId).getDocument { document, error in
            if let document = document, document.exists {
                if let fcmToken = document.data()?["fcmToken"] as? String {
                    print("📢 Sending push notification to customer with token: \(fcmToken)")

                    // Send the push notification
                    NotificationHelper.sendPushNotification(
                        to: self.selectedUserId,
                        title: "New Message from Bedford Autobody",
                        body: message
                    )
                } else {
                    print("⚠️ No FCM token found for user \(self.selectedUserId)")
                }
            } else {
                print("⚠️ User document does not exist")
            }
        }
    }


    private func fetchMessages(for userId: String) {
        activityIndicator.startAnimating()

        db.collection("messages")
            .whereField("userId", isEqualTo: userId)
            .order(by: "sentDate")
            .addSnapshotListener { querySnapshot, error in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("❌ Error fetching messages: \(error.localizedDescription)")
                    return
                }

                var unreadMessageIds: [String] = []

                self.messages = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let senderId = data["senderId"] as? String,
                          let displayName = data["displayName"] as? String,
                          let messageId = data["messageId"] as? String,
                          let sentDate = (data["sentDate"] as? Timestamp)?.dateValue(),
                          let text = data["text"] as? String,
                          let isRead = data["isRead"] as? Bool else { return nil }

                    let docId = document.documentID

                    // ✅ Collect unread messages sent by the customer
                    if senderId != "admin" && !isRead {
                        unreadMessageIds.append(docId)
                    }

                    return Message(sender: Sender(senderId: senderId, displayName: displayName), messageId: messageId, sentDate: sentDate, kind: .text(text))
                } ?? []

                // ✅ Mark all unread messages as read
                self.markMessagesAsRead(unreadMessageIds)

                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
    }



    private func markMessagesAsRead(_ messageIds: [String]) {
        guard !messageIds.isEmpty else { return }

        let db = Firestore.firestore()

        for messageId in messageIds {
            db.collection("messages").document(messageId).updateData(["isRead": true]) { error in
                if let error = error {
                    print("❌ Error marking message as read: \(error.localizedDescription)")
                } else {
                    print("✅ Message marked as read: \(messageId)")
                }
            }
        }
    }


    private func extractText(from message: MessageType) -> String {
        switch message.kind {
        case .text(let messageText):
            return messageText
        default:
            return ""
        }
    }
    
    // MARK: - MessagesDataSource
    var currentSender: any MessageKit.SenderType {
        return currentUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> any MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    // MARK: - MessagesLayoutDelegate
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section == 0 {
            return formatTimestamp(for: message.sentDate)
        }
        let previousMessage = messages[indexPath.section - 1]
        if message.sentDate.timeIntervalSince(previousMessage.sentDate) > timeIntervalThreshold {
            return formatTimestamp(for: message.sentDate)
        }
        return nil
    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return cellTopLabelAttributedText(for: message, at: indexPath) != nil ? 40 : 0
    }

    private func formatTimestamp(for date: Date) -> NSAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        return NSAttributedString(
            string: dateString,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.gray
            ]
        )
    }
    
    // MARK: - MessagesDisplayDelegate
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == currentUser.senderId ? UIColor.systemBlue : UIColor.lightGray
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == currentUser.senderId ? UIColor.white : UIColor.black
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func avatarImage(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIImage? {
        if message.sender.senderId == currentUser.senderId {
            // Admin's avatar: Use the custom image
            return UIImage(named: "logo_small")
        } else {
            // Customer's avatar: Handled in `configureAvatarView`
            return nil
        }
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == currentUser.senderId {
            // Admin's avatar: Use the custom image
            avatarView.image = UIImage(named: "logo_small")
        } else {
            // Customer's avatar: Use the first letter of their first name
            let db = Firestore.firestore()
            
            db.collection("users").document(selectedUserId).getDocument { document, error in
                if let document = document, document.exists {
                    let firstName = document.data()?["firstName"] as? String ?? "C"
                    let initials = String(firstName.prefix(1))
                    DispatchQueue.main.async {
                        avatarView.set(avatar: Avatar(initials: initials))
                    }
                } else {
                    DispatchQueue.main.async {
                        avatarView.set(avatar: Avatar(initials: "C"))
                    }
                }
            }
        }
    }

}

