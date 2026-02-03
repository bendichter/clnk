import SwiftUI
import PhotosUI

struct AddDishView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    @State private var dishName = ""
    @State private var description = ""
    @State private var price = ""
    @State private var selectedCategory: DishCategory = .main
    @State private var isSpicy = false
    @State private var isVegetarian = false
    @State private var isVegan = false
    @State private var isGlutenFree = false
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Photo picker state
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                // Photo Section
                Section("Photo") {
                    VStack(spacing: 12) {
                        if let imageData = selectedImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation {
                                            selectedItem = nil
                                            selectedImageData = nil
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(.white)
                                            .shadow(radius: 2)
                                    }
                                    .padding(8)
                                }
                        } else {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(AppTheme.textTertiary)
                                    Text("Add a photo")
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                                .background(AppTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        if selectedImageData != nil {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Text("Change Photo")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }
                
                Section("Dish Details") {
                    TextField("Dish Name", text: $dishName)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    HStack {
                        Text("$")
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(DishCategory.allCases, id: \.self) { category in
                            Text("\(category.emoji) \(category.rawValue)")
                                .tag(category)
                        }
                    }
                }
                
                Section("Dietary Info") {
                    Toggle(isOn: $isSpicy) {
                        HStack {
                            Text("🌶️")
                            Text("Spicy")
                        }
                    }
                    
                    Toggle(isOn: $isVegetarian) {
                        HStack {
                            Text("🥬")
                            Text("Vegetarian")
                        }
                    }
                    
                    Toggle(isOn: $isVegan) {
                        HStack {
                            Text("🌱")
                            Text("Vegan")
                        }
                    }
                    
                    Toggle(isOn: $isGlutenFree) {
                        HStack {
                            Text("🌾")
                            Text("Gluten-Free")
                        }
                    }
                }
            }
            .navigationTitle("Add Dish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        submitDish()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Add")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isValid || isSubmitting)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        // Compress image to reasonable size
                        if let uiImage = UIImage(data: data),
                           let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                            selectedImageData = compressed
                        } else {
                            selectedImageData = data
                        }
                    }
                }
            }
        }
    }
    
    private var isValid: Bool {
        !dishName.isEmpty && !price.isEmpty && Double(price) != nil
    }
    
    private func submitDish() {
        guard let priceValue = Double(price) else {
            errorMessage = "Please enter a valid price"
            showError = true
            return
        }
        
        isSubmitting = true
        
        // Create new dish locally for demo mode
        let newDish = Dish(
            id: UUID(),
            name: dishName,
            description: description,
            price: priceValue,
            category: selectedCategory,
            imageEmoji: selectedCategory.emoji,
            imageName: nil,
            imageData: selectedImageData,
            isPopular: false,
            isSpicy: isSpicy,
            isVegetarian: isVegetarian,
            isVegan: isVegan,
            isGlutenFree: isGlutenFree,
            ratings: []
        )
        
        // Add to restaurant via view model
        restaurantViewModel.addDishLocally(newDish, to: restaurant.id)
        
        isSubmitting = false
        dismiss()
    }
}

#Preview {
    AddDishView(restaurant: MockData.restaurants[0])
        .environmentObject(RestaurantViewModel())
}
