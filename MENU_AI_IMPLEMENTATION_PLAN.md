# Menu AI Feature - Implementation Plan

## Overview

**Goal:** Allow restaurant owners to upload menu photos/PDFs → AI extracts dish information → Owner reviews/edits → Dishes added to restaurant.

**User Story:** As a restaurant owner, I want to upload my menu and have dishes automatically extracted so I can quickly populate my restaurant's listing without manual data entry.

---

## Architecture Analysis

### Current Stack
- **iOS:** SwiftUI + Supabase Swift SDK
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **Admin:** Web dashboard (JavaScript + Supabase client)

### Current Data Flow
```
iOS App → SupabaseService.swift → Supabase PostgreSQL
                                → Supabase Storage (photos)
```

### Proposed Menu AI Flow
```
1. User uploads menu image/PDF
2. File stored in Supabase Storage
3. Edge Function triggered with file URL
4. Claude Vision API analyzes menu
5. Extracted dishes returned as JSON
6. User reviews/edits extracted dishes
7. Approved dishes saved to `dishes` table
```

---

## Phase 1: Backend Infrastructure

### 1.1 New Supabase Tables

```sql
-- Track menu upload requests
CREATE TABLE menu_uploads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES profiles(id),
    storage_path TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL, -- 'image/jpeg', 'image/png', 'application/pdf'
    status TEXT DEFAULT 'pending', -- pending, processing, completed, failed
    page_count INTEGER DEFAULT 1,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

-- Store extraction results (can be edited before final save)
CREATE TABLE menu_extractions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_upload_id UUID NOT NULL REFERENCES menu_uploads(id) ON DELETE CASCADE,
    extracted_dishes JSONB NOT NULL DEFAULT '[]',
    -- JSONB structure: [{name, description, price, category, dietary_tags}]
    confidence_score DECIMAL(3,2), -- 0.00 to 1.00
    processing_time_ms INTEGER,
    status TEXT DEFAULT 'draft', -- draft, approved, rejected
    created_at TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES profiles(id)
);

CREATE INDEX idx_menu_uploads_restaurant ON menu_uploads(restaurant_id);
CREATE INDEX idx_menu_uploads_status ON menu_uploads(status);
CREATE INDEX idx_menu_extractions_upload ON menu_extractions(menu_upload_id);
```

### 1.2 Supabase Storage Bucket

- **Bucket name:** `menu-uploads`
- **Access:** Public read (for processing), authenticated write
- **File types:** `.jpg`, `.jpeg`, `.png`, `.pdf`
- **Max size:** 10MB per file

### 1.3 Supabase Edge Function: `extract-menu`

```typescript
// supabase/functions/extract-menu/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Anthropic from 'https://esm.sh/@anthropic-ai/sdk'

const anthropic = new Anthropic({
  apiKey: Deno.env.get('ANTHROPIC_API_KEY'),
})

serve(async (req) => {
  const { menu_upload_id, file_url, file_type } = await req.json()
  
  // Update status to processing
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )
  
  await supabase
    .from('menu_uploads')
    .update({ status: 'processing' })
    .eq('id', menu_upload_id)

  try {
    const startTime = Date.now()
    
    // Fetch the image/PDF
    const imageResponse = await fetch(file_url)
    const imageData = await imageResponse.arrayBuffer()
    const base64Image = btoa(String.fromCharCode(...new Uint8Array(imageData)))
    
    // Call Claude Vision API
    const response = await anthropic.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 4096,
      messages: [{
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
- description: A brief description (if visible, otherwise generate a reasonable one)
- price: The price as a number (USD, no currency symbol)
- category: One of: Appetizers, Soups, Salads, Main Courses, Pasta, Sushi & Sashimi, Tacos & Burritos, Pizza, Seafood, Desserts, Drinks, Sides
- dietary_tags: Array of applicable tags from: ["vegetarian", "vegan", "gluten-free", "spicy"]

Return ONLY a JSON array with no additional text. Example:
[
  {"name": "Margherita Pizza", "description": "Fresh tomato, mozzarella, and basil", "price": 18.95, "category": "Pizza", "dietary_tags": ["vegetarian"]},
  {"name": "Caesar Salad", "description": "Romaine lettuce with parmesan and croutons", "price": 12.50, "category": "Salads", "dietary_tags": []}
]`
          }
        ],
      }],
    })

    const processingTime = Date.now() - startTime
    
    // Parse the extracted dishes
    const extractedText = response.content[0].type === 'text' ? response.content[0].text : ''
    const dishes = JSON.parse(extractedText)
    
    // Save extraction results
    await supabase.from('menu_extractions').insert({
      menu_upload_id,
      extracted_dishes: dishes,
      confidence_score: 0.85, // Could be enhanced with actual confidence
      processing_time_ms: processingTime,
      status: 'draft'
    })
    
    // Update upload status
    await supabase
      .from('menu_uploads')
      .update({ 
        status: 'completed',
        processed_at: new Date().toISOString()
      })
      .eq('id', menu_upload_id)

    return new Response(JSON.stringify({ success: true, dish_count: dishes.length }), {
      headers: { 'Content-Type': 'application/json' },
    })
    
  } catch (error) {
    // Update with error
    await supabase
      .from('menu_uploads')
      .update({ 
        status: 'failed',
        error_message: error.message
      })
      .eq('id', menu_upload_id)

    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
```

### 1.4 Environment Setup

Required Supabase secrets:
```bash
supabase secrets set ANTHROPIC_API_KEY=sk-ant-xxxxx
```

---

## Phase 2: iOS Implementation

### 2.1 New Supabase Models

Add to `SupabaseService.swift`:

```swift
// MARK: - Menu Upload Models

struct MenuUpload: Codable, Identifiable {
    let id: UUID
    let restaurantId: UUID
    let uploadedBy: UUID
    let storagePath: String
    let fileUrl: String
    let fileType: String
    let status: String
    let pageCount: Int?
    let errorMessage: String?
    let createdAt: Date?
    let processedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case restaurantId = "restaurant_id"
        case uploadedBy = "uploaded_by"
        case storagePath = "storage_path"
        case fileUrl = "file_url"
        case fileType = "file_type"
        case status
        case pageCount = "page_count"
        case errorMessage = "error_message"
        case createdAt = "created_at"
        case processedAt = "processed_at"
    }
}

struct MenuExtraction: Codable, Identifiable {
    let id: UUID
    let menuUploadId: UUID
    var extractedDishes: [ExtractedDish]
    let confidenceScore: Double?
    let processingTimeMs: Int?
    let status: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case menuUploadId = "menu_upload_id"
        case extractedDishes = "extracted_dishes"
        case confidenceScore = "confidence_score"
        case processingTimeMs = "processing_time_ms"
        case status
        case createdAt = "created_at"
    }
}

struct ExtractedDish: Codable, Identifiable, Equatable {
    var id = UUID() // Client-side ID for editing
    var name: String
    var description: String
    var price: Double
    var category: String
    var dietaryTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, description, price, category
        case dietaryTags = "dietary_tags"
    }
    
    // Custom init to handle missing id from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0
        self.category = try container.decodeIfPresent(String.self, forKey: .category) ?? "Main Courses"
        self.dietaryTags = try container.decodeIfPresent([String].self, forKey: .dietaryTags) ?? []
    }
}
```

### 2.2 New Service Methods

Add to `SupabaseService.swift`:

```swift
// MARK: - Menu Upload & Extraction

/// Upload a menu image and trigger AI extraction
func uploadMenu(
    restaurantId: UUID,
    imageData: Data,
    fileType: String = "image/jpeg"
) async throws -> MenuUpload {
    guard let userId = client.auth.currentUser?.id else {
        throw SupabaseServiceError.notAuthenticated
    }
    
    // 1. Upload to storage
    let fileName = "\(restaurantId.uuidString)/menu_\(Date().timeIntervalSince1970).jpg"
    
    _ = try await client.storage
        .from("menu-uploads")
        .upload(fileName, data: imageData, options: FileOptions(contentType: fileType))
    
    let publicUrl = try client.storage
        .from("menu-uploads")
        .getPublicURL(path: fileName)
    
    // 2. Create menu_upload record
    struct NewMenuUpload: Codable {
        let restaurantId: UUID
        let uploadedBy: UUID
        let storagePath: String
        let fileUrl: String
        let fileType: String
        
        enum CodingKeys: String, CodingKey {
            case restaurantId = "restaurant_id"
            case uploadedBy = "uploaded_by"
            case storagePath = "storage_path"
            case fileUrl = "file_url"
            case fileType = "file_type"
        }
    }
    
    let newUpload = NewMenuUpload(
        restaurantId: restaurantId,
        uploadedBy: userId,
        storagePath: fileName,
        fileUrl: publicUrl.absoluteString,
        fileType: fileType
    )
    
    let upload: MenuUpload = try await client
        .from("menu_uploads")
        .insert(newUpload)
        .select()
        .single()
        .execute()
        .value
    
    // 3. Trigger Edge Function for processing
    try await triggerMenuExtraction(uploadId: upload.id, fileUrl: publicUrl.absoluteString, fileType: fileType)
    
    return upload
}

/// Trigger the Edge Function to extract menu items
private func triggerMenuExtraction(uploadId: UUID, fileUrl: String, fileType: String) async throws {
    struct ExtractionRequest: Codable {
        let menu_upload_id: String
        let file_url: String
        let file_type: String
    }
    
    let request = ExtractionRequest(
        menu_upload_id: uploadId.uuidString,
        file_url: fileUrl,
        file_type: fileType
    )
    
    // Call Edge Function
    try await client.functions.invoke(
        "extract-menu",
        options: FunctionInvokeOptions(body: request)
    )
}

/// Fetch extraction results for a menu upload
func fetchMenuExtraction(uploadId: UUID) async throws -> MenuExtraction? {
    let extractions: [MenuExtraction] = try await client
        .from("menu_extractions")
        .select()
        .eq("menu_upload_id", value: uploadId.uuidString)
        .order("created_at", ascending: false)
        .limit(1)
        .execute()
        .value
    
    return extractions.first
}

/// Check status of menu upload
func fetchMenuUpload(id: UUID) async throws -> MenuUpload {
    let upload: MenuUpload = try await client
        .from("menu_uploads")
        .select()
        .eq("id", value: id.uuidString)
        .single()
        .execute()
        .value
    
    return upload
}

/// Save approved dishes from extraction
func saveExtractedDishes(
    restaurantId: UUID,
    dishes: [ExtractedDish],
    extractionId: UUID
) async throws -> [SupabaseDish] {
    guard let userId = client.auth.currentUser?.id else {
        throw SupabaseServiceError.notAuthenticated
    }
    
    var savedDishes: [SupabaseDish] = []
    
    for dish in dishes {
        let newDish = NewDish(
            restaurantId: restaurantId,
            name: dish.name,
            description: dish.description.isEmpty ? nil : dish.description,
            price: dish.price > 0 ? dish.price : nil,
            category: dish.category,
            dietaryTags: dish.dietaryTags.isEmpty ? nil : dish.dietaryTags,
            submittedBy: userId
        )
        
        let saved: SupabaseDish = try await client
            .from("dishes")
            .insert(newDish)
            .select()
            .single()
            .execute()
            .value
        
        savedDishes.append(saved)
    }
    
    // Update extraction status to approved
    try await client
        .from("menu_extractions")
        .update(["status": "approved", "approved_at": Date().ISO8601Format(), "approved_by": userId.uuidString])
        .eq("id", value: extractionId.uuidString)
        .execute()
    
    return savedDishes
}
```

### 2.3 New Views

#### `MenuUploadView.swift`

```swift
import SwiftUI
import PhotosUI

struct MenuUploadView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isUploading = false
    @State private var uploadProgress: String = ""
    @State private var menuUpload: MenuUpload?
    @State private var extraction: MenuExtraction?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var pollTimer: Timer?
    
    private let service = SupabaseService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let extraction = extraction {
                    // Show extraction review
                    MenuExtractionReviewView(
                        restaurant: restaurant,
                        extraction: extraction,
                        onSave: { savedDishes in
                            // Refresh restaurant data
                            Task {
                                await restaurantViewModel.refreshRestaurants()
                            }
                            dismiss()
                        },
                        onCancel: {
                            dismiss()
                        }
                    )
                } else if isUploading {
                    // Processing state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text(uploadProgress)
                            .font(.headline)
                        
                        Text("This may take a minute...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Upload interface
                    uploadInterface
                }
            }
            .navigationTitle("Add from Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        stopPolling()
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onDisappear {
                stopPolling()
            }
        }
    }
    
    private var uploadInterface: some View {
        VStack(spacing: 24) {
            // Instructions
            VStack(spacing: 12) {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                Text("Upload Your Menu")
                    .font(.title2.weight(.bold))
                
                Text("Take a photo of your menu and our AI will automatically extract all the dishes.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Image preview or picker
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
                VStack(spacing: 16) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                    
                    HStack(spacing: 16) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Change Photo")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                        }
                        
                        Button {
                            withAnimation {
                                selectedItem = nil
                                selectedImageData = nil
                            }
                        } label: {
                            Text("Remove")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        
                        Text("Select Menu Photo")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text("JPG, PNG supported")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Upload button
            Button {
                uploadMenu()
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Extract Dishes")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedImageData != nil ? Color.orange : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(selectedImageData == nil)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data),
                       let compressed = uiImage.jpegData(compressionQuality: 0.8) {
                        selectedImageData = compressed
                    } else {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    private func uploadMenu() {
        guard let imageData = selectedImageData else { return }
        
        isUploading = true
        uploadProgress = "Uploading menu..."
        
        Task {
            do {
                // 1. Upload the menu
                let upload = try await service.uploadMenu(
                    restaurantId: restaurant.id,
                    imageData: imageData
                )
                menuUpload = upload
                uploadProgress = "Analyzing menu with AI..."
                
                // 2. Start polling for results
                startPolling(uploadId: upload.id)
                
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isUploading = false
            }
        }
    }
    
    private func startPolling(uploadId: UUID) {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task {
                await checkExtractionStatus(uploadId: uploadId)
            }
        }
    }
    
    private func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }
    
    private func checkExtractionStatus(uploadId: UUID) async {
        do {
            let upload = try await service.fetchMenuUpload(id: uploadId)
            
            switch upload.status {
            case "completed":
                stopPolling()
                // Fetch extraction results
                if let result = try await service.fetchMenuExtraction(uploadId: uploadId) {
                    await MainActor.run {
                        extraction = result
                        isUploading = false
                    }
                }
                
            case "failed":
                stopPolling()
                await MainActor.run {
                    errorMessage = upload.errorMessage ?? "Failed to process menu"
                    showError = true
                    isUploading = false
                }
                
            default:
                // Still processing
                break
            }
        } catch {
            // Keep polling on network errors
            print("Polling error: \(error)")
        }
    }
}
```

#### `MenuExtractionReviewView.swift`

```swift
import SwiftUI

struct MenuExtractionReviewView: View {
    let restaurant: Restaurant
    @State var extraction: MenuExtraction
    let onSave: ([SupabaseDish]) -> Void
    let onCancel: () -> Void
    
    @State private var editingDish: ExtractedDish?
    @State private var selectedDishes: Set<UUID> = []
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let service = SupabaseService.shared
    
    init(restaurant: Restaurant, extraction: MenuExtraction, onSave: @escaping ([SupabaseDish]) -> Void, onCancel: @escaping () -> Void) {
        self.restaurant = restaurant
        self._extraction = State(initialValue: extraction)
        self.onSave = onSave
        self.onCancel = onCancel
        // Select all dishes by default
        self._selectedDishes = State(initialValue: Set(extraction.extractedDishes.map { $0.id }))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("\(extraction.extractedDishes.count) dishes found")
                        .font(.headline)
                }
                
                Text("Review and edit before adding to \(restaurant.name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Dish list
            List {
                ForEach($extraction.extractedDishes) { $dish in
                    ExtractedDishRow(
                        dish: $dish,
                        isSelected: selectedDishes.contains(dish.id),
                        onToggle: {
                            if selectedDishes.contains(dish.id) {
                                selectedDishes.remove(dish.id)
                            } else {
                                selectedDishes.insert(dish.id)
                            }
                        },
                        onEdit: {
                            editingDish = dish
                        }
                    )
                }
                .onDelete { indexSet in
                    extraction.extractedDishes.remove(atOffsets: indexSet)
                }
            }
            .listStyle(.plain)
            
            // Bottom bar
            VStack(spacing: 12) {
                HStack {
                    Button {
                        if selectedDishes.count == extraction.extractedDishes.count {
                            selectedDishes.removeAll()
                        } else {
                            selectedDishes = Set(extraction.extractedDishes.map { $0.id })
                        }
                    } label: {
                        Text(selectedDishes.count == extraction.extractedDishes.count ? "Deselect All" : "Select All")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Text("\(selectedDishes.count) selected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 12) {
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        saveDishes()
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "plus.circle.fill")
                            }
                            Text("Add \(selectedDishes.count) Dishes")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedDishes.isEmpty ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(selectedDishes.isEmpty || isSaving)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
        }
        .sheet(item: $editingDish) { dish in
            EditExtractedDishView(dish: dish) { updatedDish in
                if let index = extraction.extractedDishes.firstIndex(where: { $0.id == dish.id }) {
                    extraction.extractedDishes[index] = updatedDish
                }
                editingDish = nil
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveDishes() {
        let dishesToSave = extraction.extractedDishes.filter { selectedDishes.contains($0.id) }
        guard !dishesToSave.isEmpty else { return }
        
        isSaving = true
        
        Task {
            do {
                let savedDishes = try await service.saveExtractedDishes(
                    restaurantId: restaurant.id,
                    dishes: dishesToSave,
                    extractionId: extraction.id
                )
                
                await MainActor.run {
                    onSave(savedDishes)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isSaving = false
                }
            }
        }
    }
}

struct ExtractedDishRow: View {
    @Binding var dish: ExtractedDish
    let isSelected: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .orange : .secondary)
            }
            .buttonStyle(.plain)
            
            // Dish info
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.headline)
                
                if !dish.description.isEmpty {
                    Text(dish.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    Text(dish.price > 0 ? String(format: "$%.2f", dish.price) : "No price")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(dish.price > 0 ? .primary : .secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(dish.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if !dish.dietaryTags.isEmpty {
                        HStack(spacing: 2) {
                            ForEach(dish.dietaryTags, id: \.self) { tag in
                                Text(tagEmoji(for: tag))
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
    }
    
    private func tagEmoji(for tag: String) -> String {
        switch tag.lowercased() {
        case "vegetarian": return "🥬"
        case "vegan": return "🌱"
        case "gluten-free": return "🌾"
        case "spicy": return "🌶️"
        default: return ""
        }
    }
}

struct EditExtractedDishView: View {
    @Environment(\.dismiss) var dismiss
    @State var dish: ExtractedDish
    let onSave: (ExtractedDish) -> Void
    
    let categories = ["Appetizers", "Soups", "Salads", "Main Courses", "Pasta", "Sushi & Sashimi", "Tacos & Burritos", "Pizza", "Seafood", "Desserts", "Drinks", "Sides"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dish Details") {
                    TextField("Name", text: $dish.name)
                    TextField("Description", text: $dish.description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    HStack {
                        Text("$")
                        TextField("Price", value: $dish.price, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $dish.category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section("Dietary Info") {
                    Toggle("Vegetarian 🥬", isOn: Binding(
                        get: { dish.dietaryTags.contains("vegetarian") },
                        set: { if $0 { dish.dietaryTags.append("vegetarian") } else { dish.dietaryTags.removeAll { $0 == "vegetarian" } } }
                    ))
                    
                    Toggle("Vegan 🌱", isOn: Binding(
                        get: { dish.dietaryTags.contains("vegan") },
                        set: { if $0 { dish.dietaryTags.append("vegan") } else { dish.dietaryTags.removeAll { $0 == "vegan" } } }
                    ))
                    
                    Toggle("Gluten-Free 🌾", isOn: Binding(
                        get: { dish.dietaryTags.contains("gluten-free") },
                        set: { if $0 { dish.dietaryTags.append("gluten-free") } else { dish.dietaryTags.removeAll { $0 == "gluten-free" } } }
                    ))
                    
                    Toggle("Spicy 🌶️", isOn: Binding(
                        get: { dish.dietaryTags.contains("spicy") },
                        set: { if $0 { dish.dietaryTags.append("spicy") } else { dish.dietaryTags.removeAll { $0 == "spicy" } } }
                    ))
                }
            }
            .navigationTitle("Edit Dish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(dish)
                    }
                    .fontWeight(.semibold)
                    .disabled(dish.name.isEmpty)
                }
            }
        }
    }
}
```

### 2.4 Integration Points

#### Update `RestaurantDetailView.swift`

Add menu upload button alongside the existing "Add Dish" button:

```swift
// In the Menu section header
HStack {
    Text("Menu")
        .font(.title2.weight(.bold))
    
    Spacer()
    
    // NEW: Add from Menu button
    Button {
        showMenuUpload = true
    } label: {
        HStack(spacing: 4) {
            Image(systemName: "doc.text.viewfinder")
            Text("Scan Menu")
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.blue)
    }
    
    Button {
        showAddDish = true
    } label: {
        HStack(spacing: 4) {
            Image(systemName: "plus.circle.fill")
            Text("Add Dish")
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.orange)
    }
}

// Add state and sheet
@State private var showMenuUpload = false

.sheet(isPresented: $showMenuUpload) {
    MenuUploadView(restaurant: restaurant)
}
```

---

## Phase 3: Admin Dashboard Enhancement

### 3.1 New Admin Tab: Menu Uploads

Add to `admin/app.js`:

```javascript
// Add to navigation
<button class="nav-btn" data-tab="menus">📋 Menu Uploads</button>

// Add tab content
<div id="menus-tab" class="tab-content">
    <h2>Menu Uploads</h2>
    <div id="menus-list" class="menus-list">
        <div class="loading">Loading menu uploads...</div>
    </div>
</div>
```

```javascript
// Load Menu Uploads
async function loadMenuUploads() {
    const container = document.getElementById('menus-list');
    container.innerHTML = '<div class="loading">Loading menu uploads...</div>';

    try {
        const { data, error } = await supabaseClient
            .from('menu_uploads')
            .select(`
                *,
                restaurants(name),
                menu_extractions(id, extracted_dishes, status)
            `)
            .order('created_at', { ascending: false })
            .limit(50);

        if (error) throw error;

        if (!data || data.length === 0) {
            container.innerHTML = '<div class="loading">No menu uploads yet</div>';
            return;
        }

        container.innerHTML = data.map(upload => {
            const extraction = upload.menu_extractions?.[0];
            const dishCount = extraction?.extracted_dishes?.length || 0;
            const date = new Date(upload.created_at).toLocaleString();
            
            return `
                <div class="menu-card">
                    <div class="menu-header">
                        <h3>${upload.restaurants?.name || 'Unknown Restaurant'}</h3>
                        <span class="status-badge status-${upload.status}">${upload.status}</span>
                    </div>
                    <p>📅 Uploaded: ${date}</p>
                    <p>🍽️ Dishes extracted: ${dishCount}</p>
                    ${extraction ? `<p>📊 Extraction status: ${extraction.status}</p>` : ''}
                    <a href="${upload.file_url}" target="_blank" class="btn-view">View Menu Image</a>
                </div>
            `;
        }).join('');
    } catch (error) {
        console.error('Error loading menu uploads:', error);
        container.innerHTML = '<div class="loading">Error loading menu uploads</div>';
    }
}
```

---

## Cost Estimates

### Anthropic API Costs (Claude Sonnet)
- ~$3 per 1M input tokens, ~$15 per 1M output tokens
- Average menu image: ~1,000-2,000 tokens input
- Average extraction: ~500-1,000 tokens output
- **Estimated cost per menu: $0.01-0.03**

### Supabase
- Storage: $0.021/GB/month (menu images)
- Edge Functions: 500K free invocations/month
- Database: Included in existing plan

---

## Testing Plan

### Unit Tests
1. JSON parsing of extracted dishes
2. Model conversions
3. Service method error handling

### Integration Tests
1. Upload → Storage → Edge Function → Database flow
2. Polling mechanism for extraction status
3. Batch dish saving

### Manual Testing Scenarios
1. Single page menu photo
2. Multi-page menu (PDF)
3. Poor quality/blurry image
4. Menu with prices in different formats
5. Menu with non-English text
6. Empty menu / no dishes found
7. Network interruption during processing

---

## Rollout Plan

### Phase 1: Backend (Day 1-2)
- [ ] Create Supabase tables
- [ ] Create storage bucket
- [ ] Deploy Edge Function
- [ ] Test with sample menus

### Phase 2: iOS (Day 3-5)
- [ ] Add new models and services
- [ ] Implement MenuUploadView
- [ ] Implement MenuExtractionReviewView
- [ ] Integrate with RestaurantDetailView
- [ ] Test full flow

### Phase 3: Admin + Polish (Day 6-7)
- [ ] Add admin dashboard tab
- [ ] Error handling improvements
- [ ] Loading states and animations
- [ ] Build verification

---

## Questions to Resolve

1. **Owner verification:** Should we require restaurant claim verification before allowing menu uploads? Currently anyone can add dishes.

2. **Rate limiting:** How many menu uploads per restaurant per day?

3. **PDF support:** Should we support multi-page PDFs, or limit to single images initially?

4. **Duplicate detection:** Should we check for duplicate dish names before saving?

5. **Confidence threshold:** Should we show a warning for low-confidence extractions?

---

## Files to Create/Modify

### New Files
- `supabase/functions/extract-menu/index.ts`
- `supabase/migrations/20260202_menu_ai.sql`
- `Clnk/Views/MenuUploadView.swift`
- `Clnk/Views/MenuExtractionReviewView.swift`
- `admin/menus.js` (or add to app.js)

### Modified Files
- `Clnk/Services/SupabaseService.swift` (add menu methods)
- `Clnk/Views/RestaurantDetailView.swift` (add menu upload button)
- `admin/index.html` (add menus tab)
- `admin/app.js` (add menus functionality)
- `admin/styles.css` (add menus styles)
