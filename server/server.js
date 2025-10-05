import express from "express";
import { GoogleGenerativeAI, SchemaType } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();
const app = express();
app.use(express.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

app.post("/generate", async (req, res) => {
  try {
    const { prompt } = req.body;

    const model = genAI.getGenerativeModel({
      model: "gemini-2.0-flash", // ✅ valid model name
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: {
          type: SchemaType.OBJECT,
          properties: {
            ideas: {
              type: SchemaType.ARRAY,
              items: {
                type: SchemaType.STRING,
              },
            },
          },
        },
      },
    });

    const result = await model.generateContent(prompt);

    // result.response is an object, not a string
    const text = result.response.text();

    res.json({ success: true, data: JSON.parse(text) });
  } catch (err) {
    console.error("Gemini error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

app.listen(3000, () => {
  console.log("✅ Gemini bridge running on http://localhost:3000");
});
