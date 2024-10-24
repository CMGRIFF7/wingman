const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { google } = require("googleapis");
const dialogflow = require("@google-cloud/dialogflow");

admin.initializeApp();

// Google TTS Function
exports.textToSpeech = functions.https.onRequest(async (req, res) => {
  const client = new google.auth.JWT({
    email: functions.config().service_account.client_email,
    key: functions.config().service_account.private_key,
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
  });

  const textToSpeech = google.texttospeech({
    version: "v1",
    auth: client,
  });

  try {
    const response = await textToSpeech.text.synthesize({
      input: { text: req.body.text },
      voice: { languageCode: "en-US", ssmlGender: "NEUTRAL" },
      audioConfig: { audioEncoding: "MP3" },
    });

    res.status(200).send(response.data.audioContent);
  } catch (error) {
    console.error("Error in textToSpeech:", error);
    res.status(500).send("Error with TTS");
  }
});

// Google Dialogflow Integration
exports.dialogflowDetectIntent = functions.https.onRequest(async (req, res) => {
  const sessionClient = new dialogflow.SessionsClient();
  const sessionPath = sessionClient.projectAgentSessionPath(
    "wingman-12196", 
    "YOUR_SESSION_ID"
  );

  const request = {
    session: sessionPath,
    queryInput: {
      text: {
        text: req.body.text,
        languageCode: "en",
      },
    },
  };

  try {
    const responses = await sessionClient.detectIntent(request);
    const result = responses[0].queryResult;
    res.status(200).send(result.fulfillmentText);
  } catch (error) {
    console.error("Error in Dialogflow:", error);
    res.status(500).send("Error with Dialogflow");
  }
});
