import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendPushNotification = functions.https.onCall(
  async (request) => {
    try {
      const {to, notification, data} = request.data;

      const message = {
        token: to,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: data,
      };

      const response = await admin.messaging().send(message);
      console.log("✅ Push notification sent:", response);
      return {success: true};
    } catch (error) {
      console.error("❌ Error sending push notification:", error);
      return {success: false, error: (error as Error).message};
    }
  }
);

