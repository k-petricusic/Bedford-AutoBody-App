from firebase_functions import firestore_fn
from firebase_admin import initialize_app, messaging, firestore

# Initialize Firebase Admin SDK
initialize_app()

# Define Firestore trigger for new messages
@firestore_fn.on_document_created("messages/{messageId}")
def notify_new_message(event: firestore_fn.Event[firestore.DocumentSnapshot]) -> None:
    # Get the new message document data
    message_data = event.data.to_dict()

    sender_id = message_data.get("senderId")
    receiver_id = message_data.get("receiverId")
    message_text = message_data.get("text")

    if not receiver_id:
        print("No receiver ID found, skipping notification.")
        return

    # Fetch receiver's FCM token
    db = firestore.client()
    user_doc = db.collection("users").document(receiver_id).get()

    if not user_doc.exists:
        print(f"User with ID {receiver_id} not found.")
        return

    user_data = user_doc.to_dict()
    fcm_token = user_data.get("fcmToken")

    if not fcm_token:
        print(f"No FCM token found for user {receiver_id}.")
        return

    # Build the notification payload
    notification = messaging.Notification(
        title="New Message",
        body=f"You have a new message: '{message_text}'",
    )
    message = messaging.Message(
        notification=notification,
        token=fcm_token,
        data={"senderId": sender_id, "messageId": event.params["messageId"]},
    )

    # Send the notification via Firebase Cloud Messaging
    try:
        response = messaging.send(message)
        print(f"Successfully sent notification: {response}")
    except Exception as e:
        print(f"Error sending notification: {e}")
