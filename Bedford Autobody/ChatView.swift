import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseAuth

class ChatView: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    private let currentUser = Sender(senderId: "self", displayName: "Customer")
    private let db = Firestore.firestore()
    private var messages = [MessageType]()
    private let timeIntervalThreshold: TimeInterval = 300 // 5 minutes
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var adminId: String? // Admin user ID will be fetched dynamically

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        setupMessageKit()
        fetchAdminId() // Fetch the admin ID on view load
        fetchMessages()
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
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
        inputBar.inputTextView.text = ""
        
        // Notify the admin about the new message
        sendNotificationToAdmin(message: text)
    }

    private func fetchAdminId() {
        db.collection("users").whereField("email", isEqualTo: "K@gmail.com").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching admin ID: \(error.localizedDescription)")
            } else if let document = snapshot?.documents.first {
                self.adminId = document.documentID
                print("Admin ID fetched: \(self.adminId ?? "Unknown")")
            } else {
                print("Admin account not found.")
            }
        }
    }

    private func saveMessageToFirestore(_ message: Message) {
        guard let userId = Auth.auth().currentUser?.uid, let adminId = adminId else { return }
        let text = extractText(from: message)
        let messageData: [String: Any] = [
            "senderId": message.sender.senderId,
            "receiverId": adminId,
            "userId": userId,
            "displayName": (message.sender as? Sender)?.displayName ?? "",
            "messageId": message.messageId,
            "sentDate": message.sentDate,
            "text": text
        ]
        db.collection("messages").addDocument(data: messageData)
    }

    private func fetchMessages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        activityIndicator.startAnimating()

        db.collection("messages")
            .whereField("userId", isEqualTo: userId)
            .order(by: "sentDate")
            .addSnapshotListener { querySnapshot, error in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                self.messages = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard
                        let senderId = data["senderId"] as? String,
                        let displayName = data["displayName"] as? String,
                        let messageId = data["messageId"] as? String,
                        let sentDate = (data["sentDate"] as? Timestamp)?.dateValue(),
                        let text = data["text"] as? String
                    else { return nil }
                    return Message(sender: Sender(senderId: senderId, displayName: displayName), messageId: messageId, sentDate: sentDate, kind: .text(text))
                } ?? []
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
    }

    private func sendNotificationToAdmin(message: String) {
        guard let adminId = adminId, let userId = Auth.auth().currentUser?.uid else {
            print("Admin ID or user ID is missing.")
            return
        }

        // Fetch the current user's name
        db.collection("users").document(userId).getDocument { document, error in
            var customerName = "Customer" // Default name if not found
            if let document = document, document.exists {
                if let data = document.data(),
                   let firstName = data["firstName"] as? String,
                   let lastName = data["lastName"] as? String {
                    customerName = "\(firstName) \(lastName)"
                }
            }

            // Notification data
            let notificationData: [String: Any] = [
                "title": "New Message from \(customerName)",
                "body": message,
                "type": "message",
                "date": Timestamp(date: Date()),
                "isRead": false,
                "userId": adminId, // Admin user ID
                "data": ["senderId": userId, "text": message]
            ]

            // Save notification to Firestore
            self.db.collection("users").document(adminId).collection("notifications")
                .addDocument(data: notificationData) { error in
                    if let error = error {
                        print("Error sending notification to admin: \(error.localizedDescription)")
                    } else {
                        print("Notification sent to admin successfully!")
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
        let previousMessage = messages[indexPath.section - 1] as! MessageType
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
            // Customer's avatar (current user): Handled in `configureAvatarView`
            return nil
        } else {
            // Admin's avatar: Use the custom image
            return UIImage(named: "logo_small") // Replace with the custom image
        }
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == currentUser.senderId {
            // Customer's avatar: Use the first letter of their first name
            let userId = Auth.auth().currentUser?.uid ?? ""
            let db = Firestore.firestore()
            
            db.collection("users").document(userId).getDocument { document, error in
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
        } else {
            // Admin's avatar: Use the custom image
            avatarView.image = UIImage(named: "logo_small")
        }
    }
}
