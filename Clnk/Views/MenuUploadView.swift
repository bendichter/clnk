import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct MenuUploadView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedFileType: String = "image/jpeg"
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
                await loadSelectedItem(newItem)
            }
        }
    }
    
    private func loadSelectedItem(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        // Try to load as image first
        if let data = try? await item.loadTransferable(type: Data.self) {
            // Check file type
            if let contentType = item.supportedContentTypes.first {
                if contentType == .jpeg || contentType == .png {
                    // It's an image - compress it
                    if let uiImage = UIImage(data: data),
                       let compressed = uiImage.jpegData(compressionQuality: 0.8) {
                        selectedImageData = compressed
                        selectedFileType = contentType == .png ? "image/png" : "image/jpeg"
                    } else {
                        selectedImageData = data
                        selectedFileType = "image/jpeg"
                    }
                } else if contentType == .pdf {
                    // It's a PDF
                    selectedImageData = data
                    selectedFileType = "application/pdf"
                } else {
                    // Try to handle as image anyway
                    if let uiImage = UIImage(data: data),
                       let compressed = uiImage.jpegData(compressionQuality: 0.8) {
                        selectedImageData = compressed
                        selectedFileType = "image/jpeg"
                    }
                }
            } else {
                // Fallback: try to detect from data
                selectedImageData = data
                selectedFileType = "image/jpeg"
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
                    imageData: imageData,
                    fileType: selectedFileType
                )
                menuUpload = upload
                
                await MainActor.run {
                    uploadProgress = "Analyzing menu with AI..."
                }
                
                // 2. Start polling for results
                startPolling(uploadId: upload.id)
                
            } catch let error as SupabaseServiceError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isUploading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isUploading = false
                }
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
                } else {
                    await MainActor.run {
                        errorMessage = "No extraction results found"
                        showError = true
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
            // Keep polling on network errors, but log them
            print("Polling error: \(error)")
        }
    }
}

#Preview {
    MenuUploadView(restaurant: MockData.restaurants[0])
        .environmentObject(RestaurantViewModel())
}
