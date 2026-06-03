const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.donationStatusNotification =
functions.firestore
.document("donations/{donationId}")
.onUpdate(async (change, context) => {

  const before = change.before.data();
  const after = change.after.data();

  if (before.status === after.status) {
    return null;
  }

  const donorDoc = await admin
      .firestore()
      .collection("users")
      .doc(after.donorId)
      .get();

  if (!donorDoc.exists) return null;

  const token = donorDoc.data().fcmToken;

  if (!token) return null;

  let title = "";
  let body = "";

  switch (after.status) {

    case "accepted":
      title = "Donation Accepted";
      body = `${after.ngoName} accepted your donation`;
      break;

    case "pickup_started":
      title = "Pickup Started";
      body = `${after.ngoName} is on the way`;
      break;

    case "arrived":
      title = "NGO Arrived";
      body = "NGO has reached your location";
      break;

    case "completed":
      title = "Donation Completed";
      body = "Thank you for donating food";
      break;

    default:
      return null;
  }

  await admin.messaging().send({
    token: token,
    notification: {
      title: title,
      body: body,
    },
  });

  return null;
});