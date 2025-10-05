import express from "express";
import dotenv from "dotenv";
import { initializeApp } from "firebase/app";
import { getFirestore, doc, getDoc, setDoc } from "firebase/firestore";
import md5 from "md5";
import { GoogleGenAI, Type } from "@google/genai";

dotenv.config();

const app = express();
app.use(express.json());

// --- Firebase Web SDK setup ---
const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: "stormhacks2025-9fb81.firebaseapp.com",
  projectId: "stormhacks2025-9fb81",
  storageBucket: "stormhacks2025-9fb81.firebasestorage.app",
  messagingSenderId: "371303287311",
  appId: "1:371303287311:web:af26b64f550b6bd5e7b17a",
  measurementId: "G-F3P4XYHWG5",
};

const ai = new GoogleGenAI({apiKey: process.env.GEMINI_API_KEY});
const firebaseApp = initializeApp(firebaseConfig);
const db = getFirestore(firebaseApp);

// --- Gemini API setup ---

// --- Predefined schemas ---
const SCHEMAS = {
  weapon: {
    type: Type.ARRAY,
    items: {
      type: Type.OBJECT,
      properties: {
        name: { type: Type.STRING },
        description: { type: Type.STRING },
        rarity: { type: Type.STRING },
      },
      propertyOrdering: ["name", "description", "rarity"]
    } 
  }
};

// --- Firebase cache helpers ---
async function getCachedResponse(hash) {
  const docRef = doc(db, "gemini_cache", hash);
  const snapshot = await getDoc(docRef);
  return snapshot.exists() ? snapshot.data() : null;
}

async function saveCachedResponse(hash, data) {
  const docRef = doc(db, "gemini_cache", hash);
  await setDoc(docRef, data);
}

// --- Main route ---
app.post("/generate", async (req, res) => {
  try {
    const { type, payload } = req.body;

    if (!payload) return res.status(400).json({ success: false, error: "No payload provided" });
    if (!SCHEMAS[type]) return res.status(400).json({ success: false, error: "Unknown type" });

    console.log("Schema shape" + JSON.stringify(SCHEMAS[type]))
    console.log("Prompt" + payload)

    const hash = md5(type + ":" + payload);

    // Check cache first
    const cached = await getCachedResponse(hash);
    if (cached) {
      console.log("Cache hit for type:", type);
      return res.json({ success: true, data: cached, cached: true });
    }

    console.log("Cache miss. Generating new response for type:", type);

    // Create model with schema
    const response = await ai.models.generateContent({
      model: "gemini-2.0-flash",
      contents: payload,
      config: {
        responseMimeType: "application/json",
        responseSchema: SCHEMAS[type]
      }
    });

    const data = JSON.parse(response.text)[0];
    console.log(data)

    // Save to cache
    await saveCachedResponse(hash, data);

    res.json({ success: true, data, cached: false });
  } catch (err) {
    console.error("Gemini error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// --- Start server ---
app.listen(3000, () => {
  console.log("✅ Gemini bridge with typed schema + Firestore cache running on http://localhost:3000");
});
