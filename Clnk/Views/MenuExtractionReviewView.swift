import SwiftUI

struct MenuExtractionReviewView: View {
    let restaurant: Restaurant
    @State var extraction: MenuExtraction
    let onSave: ([SupabaseDish]) -> Void
    let onCancel: () -> Void
    
    @State private var editingDish: ExtractedDish?
    @State private var selectedDishes: Set<UUID> = []
    @State private var duplicateWarnings: [String: Bool] = [:]
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isCheckingDuplicates = false
    
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
                    Text("\(extraction.extractedDishes.count) cocktails found")
                        .font(.headline)
                }
                
                Text("Review and edit before adding to \(restaurant.name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if isCheckingDuplicates {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Checking for duplicates...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Dish list
            List {
                ForEach($extraction.extractedDishes) { $dish in
                    ExtractedDishRow(
                        dish: $dish,
                        isSelected: selectedDishes.contains(dish.id),
                        isDuplicate: duplicateWarnings[dish.name] ?? false,
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
                    // Update selectedDishes to remove deleted items
                    let deletedIds = indexSet.map { extraction.extractedDishes[$0].id }
                    selectedDishes = selectedDishes.filter { !deletedIds.contains($0) }
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
                            Text("Add \(selectedDishes.count) Cocktails")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedDishes.isEmpty ? Color.gray : AppTheme.primary)
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
                    // Check for duplicates again if name changed
                    if updatedDish.name != dish.name {
                        checkDuplicates()
                    }
                }
                editingDish = nil
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await checkDuplicates()
        }
    }
    
    private func checkDuplicates() {
        isCheckingDuplicates = true
        
        Task {
            do {
                let dishNames = extraction.extractedDishes.map { $0.name }
                let duplicates = try await service.checkDuplicateDishes(
                    restaurantId: restaurant.id,
                    dishNames: dishNames
                )
                
                await MainActor.run {
                    duplicateWarnings = duplicates
                    isCheckingDuplicates = false
                }
            } catch {
                print("Error checking duplicates: \(error)")
                await MainActor.run {
                    isCheckingDuplicates = false
                }
            }
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
    let isDuplicate: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? AppTheme.primary : .secondary)
            }
            .buttonStyle(.plain)
            
            // Dish info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(dish.name)
                        .font(.headline)
                    
                    if isDuplicate {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(AppTheme.primary)
                    }
                }
                
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
                
                if isDuplicate {
                    Text("⚠️ A cocktail with this name already exists")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.primary)
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
                Section("Cocktail Details") {
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
                        set: { isOn in
                            if isOn {
                                if !dish.dietaryTags.contains("vegetarian") {
                                    dish.dietaryTags.append("vegetarian")
                                }
                            } else {
                                dish.dietaryTags.removeAll { $0 == "vegetarian" }
                            }
                        }
                    ))
                    
                    Toggle("Vegan 🌱", isOn: Binding(
                        get: { dish.dietaryTags.contains("vegan") },
                        set: { isOn in
                            if isOn {
                                if !dish.dietaryTags.contains("vegan") {
                                    dish.dietaryTags.append("vegan")
                                }
                            } else {
                                dish.dietaryTags.removeAll { $0 == "vegan" }
                            }
                        }
                    ))
                    
                    Toggle("Gluten-Free 🌾", isOn: Binding(
                        get: { dish.dietaryTags.contains("gluten-free") },
                        set: { isOn in
                            if isOn {
                                if !dish.dietaryTags.contains("gluten-free") {
                                    dish.dietaryTags.append("gluten-free")
                                }
                            } else {
                                dish.dietaryTags.removeAll { $0 == "gluten-free" }
                            }
                        }
                    ))
                    
                    Toggle("Spicy 🌶️", isOn: Binding(
                        get: { dish.dietaryTags.contains("spicy") },
                        set: { isOn in
                            if isOn {
                                if !dish.dietaryTags.contains("spicy") {
                                    dish.dietaryTags.append("spicy")
                                }
                            } else {
                                dish.dietaryTags.removeAll { $0 == "spicy" }
                            }
                        }
                    ))
                }
            }
            .navigationTitle("Edit Cocktail")
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

#Preview {
    let mockExtraction = MenuExtraction(
        id: UUID(),
        menuUploadId: UUID(),
        extractedDishes: [
            ExtractedDish(
                name: "Margherita Pizza",
                description: "Fresh tomato, mozzarella, and basil",
                price: 18.95,
                category: "Pizza",
                dietaryTags: ["vegetarian"]
            ),
            ExtractedDish(
                name: "Caesar Salad",
                description: "Romaine lettuce with parmesan and croutons",
                price: 12.50,
                category: "Salads",
                dietaryTags: []
            )
        ],
        confidenceScore: 0.85,
        processingTimeMs: 5000,
        status: "draft",
        createdAt: Date()
    )
    
    MenuExtractionReviewView(
        restaurant: MockData.restaurants[0],
        extraction: mockExtraction,
        onSave: { _ in },
        onCancel: {}
    )
}
