import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class AdminChatView: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    private let currentUser = Sender(senderId: "admin", displayName: "Admin")
    private let db = Firestore.firestore()
    private var messages = [MessageType]()
    private var selectedUserId: String
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
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
        inputBar.inputTextView.text = ""
    }

    private func saveMessageToFirestore(_ message: Message) {
        let text = extractText(from: message)
        let messageData: [String: Any] = [
            "senderId": message.sender.senderId,
            "userId": selectedUserId,
            "displayName": (message.sender as? Sender)?.displayName ?? "",
            "messageId": message.messageId,
            "sentDate": message.sentDate,
            "text": text
        ]
        db.collection("messages").addDocument(data: messageData)
    }

    private func fetchMessages(for userId: String) {
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
        // Show timestamp for the first message in the list
        if indexPath.section == 0 {
            return formatTimestamp(for: message.sentDate)
        }

        // Show timestamp if the time gap between messages exceeds the threshold
        let previousMessage = messages[indexPath.section - 1] as! MessageType
        if message.sentDate.timeIntervalSince(previousMessage.sentDate) > timeIntervalThreshold {
            return formatTimestamp(for: message.sentDate)
        }

        return nil
    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        // Allocate space for the timestamp label if it’s displayed
        return cellTopLabelAttributedText(for: message, at: indexPath) != nil ? 30 : 0
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
}
