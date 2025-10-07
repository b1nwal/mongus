import express from "express";
import dotenv from "dotenv";
import { initializeApp } from "firebase/app";
import { getFirestore, doc, getDoc, setDoc, collection, getDocs } from "firebase/firestore";
import md5 from "md5";
import { GoogleGenAI, Type } from "@google/genai";
import { generateSingleImage } from "./imageGenerator.js";

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
        swingSpeed: {type: Type.NUMBER},
        slashAngle: {type: Type.INTEGER},
        cooldown: {type: Type.NUMBER},
        damage: { type: Type.INTEGER},
        scaleFactor: {type: Type.NUMBER}
      },
      required: [
        "name",
        "description",
        "rarity",
        "swingSpeed",
        "slashAngle",
        "cooldown",
        "scaleFactor",
        "damage"
      ]
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
    if (type == "weapon") {

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

      console.log(response.text)

      const base64Image = await generateSingleImage(
        data["name"],
        data["description"]
      );

      data["image"] = base64Image
      // Save to cache
      await saveCachedResponse(hash, data);

      res.json({ success: true, data, cached: false });
    } else if (type == "merge") {
      console.log("\n\n---------MERGING----------\n\n")
      var payloadJSON = JSON.parse(payload)

      var id1 = payloadJSON["id1"]
      var id2 = payloadJSON["id2"]

      const hash = md5(id1 + ":" + id2);
      const cached = await getCachedResponse(hash);
      if (cached) {
        console.log("Cache hit for type:", type);
        return res.json({ success: true, data: cached, cached: true });
      }

      
     

     
      const response1 = await getCachedResponse(id1);
      const response2 = await getCachedResponse(id2);

      console.log(response1["description"])
      const prompt = "Generate a weapon which is a combination of these two weapons. IT MUST BE ONE WEAPON AFTERWARDS; A THEMATIC MERGE. Stats should be balanced, not a straight addition." + 
      "Weapon 1: Name, " + response1["name"] + " Description, " + response1["description"] + " Damage, " + response1["damage"] + " Cooldown, " + response1["cooldown"] + " slashAngle, " + response1["slash_angle"] + response1["swing_speed"] +
      "Weapon 2: Name, " + response2["name"] + " Description, " + response2["description"] + " Damage, " + response2["damage"] + " Cooldown, " + response2["cooldown"] + " slashAngle, " + response2["slash_angle"] + response2["swing_speed"] + 
      "It should have a name, a flavour-text description (purely cosmetic), damage number (integer, positive, scaling based on rarity, " +
       "between 1 and 1000 NO HIGHER), a swing speed (between 0.3 and 3) which is inversely proportional to the swing angle, a swing angle " + 
       "(between 65 and 275), a scale factor (between 1.0 and 1.5 depending on heft), a cooldown (time between attacks, 0.9-2 seconds), and " + 
       "should have a rarity similar to the two base items. NO TEXT OR WATERMARK."
      
      
      const response = await ai.models.generateContent({
        model: "gemini-2.0-flash",
        contents: prompt,
        config: {
          responseMimeType: "application/json",
          responseSchema: SCHEMAS["weapon"]
        }
      });
      const data = JSON.parse(response.text)[0];

      const base64Image = await generateCombinedImage(
        data["name"],
        data["description"],
        response1["image"],
        response2["image"]
      );

      

      console.log(response.text)

      data["image"] = base64Image
      // Save to cache
      await saveCachedResponse(hash, data);

      res.json({ success: true, data, cached: false });

    }
  } catch (err) {
    console.error("Gemini error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// --- Score Management Endpoints ---

// Save player score to Firestore
app.post("/api/save-score", async (req, res) => {
  try {
    const { name, experience, timestamp } = req.body;
    
    if (!name || experience === undefined) {
      return res.status(400).json({ success: false, error: "Name and experience are required" });
    }
    
    // Create a unique document ID
    const docId = `${name}_${timestamp}`;
    
    // Save to Firestore
    await setDoc(doc(db, "scores", docId), {
      name: name,
      experience: experience,
      timestamp: timestamp
    });
    
    console.log(`Score saved: ${name} - ${experience} XP`);
    res.json({ success: true, message: "Score saved successfully" });
  } catch (error) {
    console.error("Error saving score:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get leaderboard from Firestore
app.get("/api/leaderboard", async (req, res) => {
  try {
    // Get all scores from Firestore
    const scoresRef = collection(db, "scores");
    const snapshot = await getDocs(scoresRef);
    
    const scores = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      scores.push({
        name: data.name,
        experience: data.experience,
        timestamp: data.timestamp
      });
    });
    
    // Sort by experience (highest first)
    scores.sort((a, b) => b.experience - a.experience);
    
    // Return top 10
    const topScores = scores.slice(0, 10);
    
    res.json(topScores);
  } catch (error) {
    console.error("Error getting leaderboard:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// --- Start server ---
app.listen(3000, () => {
  console.log("✅ Gemini bridge with typed schema + Firestore cache running on http://localhost:3000");
  
});