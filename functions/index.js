const functions = require("firebase-functions")
const admin = require("firebase-admin")

admin.initializeApp()

// Cloud Function to send push notifications
exports.sendNotification = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notification = snap.data()

    if (notification.processed) {
      return null // Already processed
    }

    try {
      // Send the notification
      const response = await admin.messaging().send({
        token: notification.to,
        notification: notification.notification,
        data: notification.data,
        android: notification.android,
        apns: notification.apns,
      })

      console.log("Successfully sent message:", response)

      // Mark as processed
      await snap.ref.update({ processed: true })

      return response
    } catch (error) {
      console.error("Error sending message:", error)

      // Mark as failed
      await snap.ref.update({
        processed: true,
        error: error.message,
      })

      return null
    }
  })

// Optional: Clean up old notifications every 24 hours
exports.cleanupNotifications = functions.pubsub.schedule("every 24 hours").onRun(async (context) => {
  const cutoff = new Date()
  cutoff.setDate(cutoff.getDate() - 7) // Delete notifications older than 7 days

  const query = admin.firestore().collection("notifications").where("timestamp", "<", cutoff)
  const snapshot = await query.get()

  if (snapshot.empty) {
    console.log("No old notifications to delete")
    return null
  }

  const batch = admin.firestore().batch()
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref)
  })

  await batch.commit()
  console.log(`Deleted ${snapshot.size} old notifications`)

  return null
})