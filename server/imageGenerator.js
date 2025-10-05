import { GoogleGenAI, Modality } from "@google/genai";
import * as fs from "node:fs";
import dotenv from "dotenv";
import sharp from "sharp";
import * as Jimp from "jimp";

dotenv.config();

const ai = new GoogleGenAI({apiKey: process.env.GEMINI_API_KEY});


export async function generateSingleImage(name, description) {
  try {
    // 1️⃣ Generate the image with Gemini
    const prompt = `Create a pixel art image of a weapon:
Name: ${name}
Description: ${description}
Format: PNG, 512x512, square, make the weapon point DIRECTLY up, that is the hilt is on the bottom, DO NOT HAVE IT UPSIDE DOWN.
Background color: use a color that isnt used in the weapon. must be a flat color. NO GRADIENT, NO BORDERS. ONLY PURE ONE COLOR.
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

export async function generateCombinedImage(name, description, image1, image2) {
    try {

        newImage = combineBase64Images({image1, image2})
        // 1️⃣ Generate the image with Gemini
    
        const prompt = [{ text: `Create a pixel art image of a weapon:
            Name: ${name}
            Description: ${description}
            Note: Combine the two weapons in the given image into one new form fitting the name and description. These two seperate swords should become one new whole.
            Format: PNG, 512x512, square, make the weapon point DIRECTLY up, that is the hilt is on the bottom, DO NOT HAVE IT UPSIDE DOWN.
            Background color: use a color that isnt used in the weapon. must be a flat color. NO GRADIENT, NO BORDERS. ONLY PURE ONE COLOR.
            No text or watermark.`},
            {
              inlineData: {
                mimeType: "image/png",
                data: base64Image,
              },
            },
          ];
        
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

async function combineBase64Images(base64Images) {
    const images = await Promise.all(base64Images.map(async (base64) => {
        return await Jimp.read(Buffer.from(base64.split(',')[1], 'base64'));
    }));

    let totalWidth = 0;
    let maxHeight = 0;

    images.forEach(img => {
        totalWidth += img.bitmap.width;
        if (img.bitmap.height > maxHeight) {
            maxHeight = img.bitmap.height;
        }
    });

    const newImage = await new Jimp(totalWidth, maxHeight, 0xFFFFFFFF); // White background

    let currentX = 0;
    images.forEach(img => {
        newImage.composite(img, currentX, 0);
        currentX += img.bitmap.width;
    });

    return await newImage.getBase64Async(Jimp.MIME_PNG); // Or Jimp.MIME_JPEG etc.
}

