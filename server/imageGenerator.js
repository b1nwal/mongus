import { GoogleGenAI, Modality } from "@google/genai";
import * as fs from "node:fs";
import dotenv from "dotenv";
import sharp from "sharp";

dotenv.config();

const ai = new GoogleGenAI({apiKey: process.env.GEMINI_API_KEY});


export async function generateWeaponImage(name, description, bgColor = "#FF00FF", targetSize = 32) {
  try {
    // 1️⃣ Generate the image with Gemini
    const prompt = `Create a pixel art image of a weapon:
Name: ${name}
Description: ${description}
Format: PNG, 512x512, square, make the weapon point DIRECTLY up
Background color: use this exact color without any gradients or changes. It must be EXACTLY this hexcode for future use. Absolutely no borders.
No text or watermark.`;


    
    const response = await ai.models.generateContent({
        model: "gemini-2.5-flash-image",
        contents: prompt,
        config: {
            imageConfig: {
              aspectRatio: "1:1",
            },
          }
    });

    for (const part of response.candidates[0].content.parts) {
        if (part.text) {
          console.log(part.text);
        } else if (part.inlineData) {
          const imageData = part.inlineData.data;
          const buffer = Buffer.from(imageData, "base64");
          const transparentBuffer = await makeIconTransparent(buffer)
          return transparentBuffer.toString('base64');
        }
    }
  } catch (err) {
    console.error("Error generating weapon image:", err);
    throw err;
  }
    
}

/**
 * Converts an image buffer to a 256x256 icon with a transparent background.
 * Assumes a near-solid background in one corner.
 *
 * @param {Buffer} inputBuffer - The input image buffer.
 * @param {Object} options - Optional settings.
 * @param {number} [options.tolerance=5] - RGB tolerance for background detection.
 * @returns {Promise<Buffer>} - A PNG buffer with transparent background.
 */
async function makeIconTransparent(inputBuffer, options = {}) {
    const tolerance = options.tolerance ?? 5;

    // Load image as raw RGB
    const image = sharp(inputBuffer);
    const { data, info } = await image.raw().toBuffer({ resolveWithObject: true });
    const { width, height, channels } = info;

    if (channels < 3) throw new Error("Image must have at least 3 channels (RGB)");

    // Sample top-left corner pixel as background
    const bgR = data[0];
    const bgG = data[1];
    const bgB = data[2];

    // Helper function to check if a pixel is background
    function isBackground(r, g, b) {
        return (
            Math.abs(r - bgR) <= tolerance &&
            Math.abs(g - bgG) <= tolerance &&
            Math.abs(b - bgB) <= tolerance
        );
    }

    // Create RGBA buffer with transparency
    const rgbaData = Buffer.alloc(width * height * 4);

    for (let i = 0; i < width * height; i++) {
        const r = data[i * channels];
        const g = data[i * channels + 1];
        const b = data[i * channels + 2];

        rgbaData[i * 4] = r;
        rgbaData[i * 4 + 1] = g;
        rgbaData[i * 4 + 2] = b;
        rgbaData[i * 4 + 3] = isBackground(r, g, b) ? 0 : 255; // alpha
    }

    // Create PNG from RGBA buffer and resize to 256x256
    const outputBuffer = await sharp(rgbaData, { raw: { width, height, channels: 4 } })
        .resize(256, 256, { fit: "contain" })
        .png()
        .toBuffer();

    return outputBuffer;
}
