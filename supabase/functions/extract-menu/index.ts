// Menu AI Extraction Edge Function
// Uses Claude Vision API to extract dish information from menu images/PDFs

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Anthropic API types
interface AnthropicMessage {
  role: "user" | "assistant";
  content: Array<{
    type: "image" | "text";
    source?: {
      type: "base64";
      media_type: string;
      data: string;
    };
    text?: string;
  }>;
}

interface AnthropicResponse {
  content: Array<{
    type: string;
    text?: string;
  }>;
}

interface ExtractedDish {
  name: string;
  description: string;
  price: number;
  category: string;
  dietary_tags: string[];
}

interface ExtractionRequest {
  menu_upload_id: string;
  file_url: string;
  file_type: string;
}

serve(async (req) => {
  // CORS headers
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  try {
    const { menu_upload_id, file_url, file_type }: ExtractionRequest = await req.json();

    console.log(`Processing menu upload ${menu_upload_id}`);

    // Initialize Supabase client with service role key
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Update status to processing
    await supabase
      .from("menu_uploads")
      .update({ status: "processing" })
      .eq("id", menu_upload_id);

    const startTime = Date.now();

    // Fetch the image/PDF from URL
    console.log(`Fetching file from ${file_url}`);
    const imageResponse = await fetch(file_url);
    if (!imageResponse.ok) {
      throw new Error(`Failed to fetch file: ${imageResponse.statusText}`);
    }

    const imageData = await imageResponse.arrayBuffer();
    const base64Image = btoa(String.fromCharCode(...new Uint8Array(imageData)));

    console.log(`Calling Claude Vision API for ${file_type}`);

    // Call Claude Vision API
    const anthropicApiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!anthropicApiKey) {
      throw new Error("ANTHROPIC_API_KEY not configured");
    }

    const message: AnthropicMessage = {
      role: "user",
      content: [
        {
          type: "image",
          source: {
            type: "base64",
            media_type: file_type,
            data: base64Image,
          },
        },
        {
          type: "text",
          text: `Analyze this restaurant menu and extract all dishes. For each dish, provide:
- name: The dish name exactly as shown
- description: A brief description (if visible on the menu, otherwise generate a reasonable one based on the dish name and category)
- price: The price as a number (USD, no currency symbol). If no price is shown, use 0.
- category: One of: Appetizers, Soups, Salads, Main Courses, Pasta, Sushi & Sashimi, Tacos & Burritos, Pizza, Seafood, Desserts, Drinks, Sides
- dietary_tags: Array of applicable tags from: ["vegetarian", "vegan", "gluten-free", "spicy"]

Return ONLY a JSON array with no additional text or markdown formatting. Example:
[
  {"name": "Margherita Pizza", "description": "Fresh tomato, mozzarella, and basil", "price": 18.95, "category": "Pizza", "dietary_tags": ["vegetarian"]},
  {"name": "Caesar Salad", "description": "Romaine lettuce with parmesan and croutons", "price": 12.50, "category": "Salads", "dietary_tags": []},
  {"name": "Grilled Salmon", "description": "Atlantic salmon with seasonal vegetables", "price": 28.00, "category": "Seafood", "dietary_tags": []}
]

Important: 
- Extract ALL dishes visible on the menu
- Be accurate with prices
- Use the exact dish names as they appear
- If a dish is clearly vegetarian/vegan/gluten-free/spicy based on ingredients, include those tags`,
        },
      ],
    };

    const anthropicResponse = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": anthropicApiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-20250514",
        max_tokens: 4096,
        messages: [message],
      }),
    });

    if (!anthropicResponse.ok) {
      const errorText = await anthropicResponse.text();
      throw new Error(`Claude API error: ${anthropicResponse.status} ${errorText}`);
    }

    const response: AnthropicResponse = await anthropicResponse.json();
    const processingTime = Date.now() - startTime;

    console.log(`Claude API response received in ${processingTime}ms`);

    // Extract the text content from Claude's response
    const extractedText = response.content
      .find((c) => c.type === "text")?.text || "";

    if (!extractedText) {
      throw new Error("No text content in Claude response");
    }

    // Parse the JSON array of dishes
    // Remove any markdown code blocks if present
    const cleanedText = extractedText
      .replace(/```json\n?/g, "")
      .replace(/```\n?/g, "")
      .trim();

    let dishes: ExtractedDish[];
    try {
      dishes = JSON.parse(cleanedText);
    } catch (parseError) {
      console.error("Failed to parse dishes JSON:", cleanedText);
      throw new Error(`Invalid JSON from Claude: ${parseError.message}`);
    }

    if (!Array.isArray(dishes)) {
      throw new Error("Claude response is not an array");
    }

    console.log(`Successfully extracted ${dishes.length} dishes`);

    // Validate extracted dishes
    for (const dish of dishes) {
      if (!dish.name || typeof dish.name !== "string") {
        throw new Error("Invalid dish: missing or invalid name");
      }
      if (typeof dish.price !== "number") {
        throw new Error(`Invalid price for dish "${dish.name}"`);
      }
    }

    // Save extraction results
    const { error: insertError } = await supabase.from("menu_extractions").insert({
      menu_upload_id,
      extracted_dishes: dishes,
      confidence_score: 0.85, // Could be enhanced with actual confidence scoring
      processing_time_ms: processingTime,
      status: "draft",
    });

    if (insertError) {
      throw new Error(`Failed to save extraction: ${insertError.message}`);
    }

    // Update upload status to completed
    const { error: updateError } = await supabase
      .from("menu_uploads")
      .update({
        status: "completed",
        processed_at: new Date().toISOString(),
      })
      .eq("id", menu_upload_id);

    if (updateError) {
      throw new Error(`Failed to update upload status: ${updateError.message}`);
    }

    console.log(`Successfully completed extraction for upload ${menu_upload_id}`);

    return new Response(
      JSON.stringify({
        success: true,
        dish_count: dishes.length,
        processing_time_ms: processingTime,
      }),
      {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Error processing menu:", error);

    // Try to update the upload with error status
    try {
      const { menu_upload_id } = await req.json();
      if (menu_upload_id) {
        const supabase = createClient(
          Deno.env.get("SUPABASE_URL")!,
          Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
        );

        await supabase
          .from("menu_uploads")
          .update({
            status: "failed",
            error_message: error.message || "Unknown error",
          })
          .eq("id", menu_upload_id);
      }
    } catch (updateError) {
      console.error("Failed to update error status:", updateError);
    }

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || "Unknown error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});
