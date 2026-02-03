import SwiftUI
import PhotosUI

struct RateDishView: View {
    let dish: Dish
    let restaurant: Restaurant
    
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var rating: Double = 0
    @State private var comment = ""
    @State private var selectedImages: [UIImage] = []
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var photosPickerItems: [PhotosPickerItem] = []
    @FocusState private var isCommentFocused: Bool
    
    private let maxPhotos = 4
    
    var isValid: Bool {
        rating > 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                if showSuccess {
                    SuccessOverlay()
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .background(AppTheme.backgroundSecondary)
            .navigationTitle("Rate Dish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .confirmationDialog("Add Photo", isPresented: $showPhotoOptions) {
                photoDialogButtons
            } message: {
                Text("Choose a photo source")
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView(image: Binding(
                    get: { nil },
                    set: { newImage in
                        if let image = newImage {
                            addImage(image)
                        }
                    }
                ))
                .ignoresSafeArea()
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $photosPickerItems,
                maxSelectionCount: maxPhotos - selectedImages.count,
                matching: .images
            )
            .onChange(of: photosPickerItems) { oldItems, newItems in
                Task {
                    await loadPhotos(from: newItems)
                }
            }
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                dishHeader
                starRatingSection
                photoSection
                commentSection
                submitSection
            }
            .padding()
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    // MARK: - Dish Header
    private var dishHeader: some View {
        VStack(spacing: 12) {
            // Only show image if dish has one
            if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            
            Text(dish.name)
                .font(.title2.weight(.bold))
            
            Text(restaurant.name)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Star Rating Section
    private var starRatingSection: some View {
        VStack(spacing: 16) {
            Text("How would you rate this dish?")
                .font(.headline)
            
            starButtons
            
            if rating > 0 {
                Text(ratingLabel)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(rating.ratingColor)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(24)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(AppTheme.springAnimation, value: rating)
    }
    
    private var starButtons: some View {
        HStack(spacing: 16) {
            ForEach(1...5, id: \.self) { index in
                Button {
                    withAnimation(AppTheme.springAnimation) {
                        rating = Double(index)
                    }
                } label: {
                    Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(index <= Int(rating) ? AppTheme.starFilled : AppTheme.starEmpty)
                        .scaleEffect(index <= Int(rating) ? 1.15 : 1.0)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Add Photos")
                    .font(.headline)
                Spacer()
                Text("\(selectedImages.count)/\(maxPhotos)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            if !selectedImages.isEmpty {
                selectedPhotosView
            }
            
            if selectedImages.count < maxPhotos {
                addPhotoButton
            }
        }
        .padding(20)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var selectedPhotosView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    photoThumbnail(image: image, index: index)
                }
            }
        }
    }
    
    private func photoThumbnail(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button {
                withAnimation {
                    if selectedImages.indices.contains(index) {
                        selectedImages.remove(at: index)
                    }
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white, .red)
            }
            .offset(x: 6, y: -6)
        }
    }
    
    private var addPhotoButton: some View {
        Button {
            showPhotoOptions = true
        } label: {
            HStack {
                Image(systemName: "camera.fill")
                Text(selectedImages.isEmpty ? "Add Photo" : "Add More")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Comment Section
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Review")
                    .font(.headline)
                Spacer()
                Text("Optional")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            commentEditor
            quickTags
        }
        .padding(20)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var commentEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $comment)
                .focused($isCommentFocused)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
            
            if comment.isEmpty {
                Text("Share your thoughts about this dish...")
                    .foregroundStyle(AppTheme.textTertiary)
                    .padding(.top, 8)
                    .padding(.leading, 4)
                    .allowsHitTesting(false)
            }
        }
        .padding(12)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var quickTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                QuickTagButton(text: "Delicious!", action: { appendTag("Delicious!") })
                QuickTagButton(text: "Worth the price", action: { appendTag("Worth the price.") })
                QuickTagButton(text: "Great presentation", action: { appendTag("Great presentation.") })
                QuickTagButton(text: "Will order again", action: { appendTag("Will definitely order again!") })
                QuickTagButton(text: "Perfect portion", action: { appendTag("Perfect portion size.") })
            }
        }
    }
    
    // MARK: - Submit Section
    private var submitSection: some View {
        VStack(spacing: 12) {
            Button {
                submitRating()
            } label: {
                HStack(spacing: 8) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                        Text("Submit Rating")
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!isValid || isSubmitting)
            
            if !isValid {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                    Text("Please select a star rating to submit")
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .keyboard) {
            Button("Done") {
                isCommentFocused = false
            }
        }
    }
    
    // MARK: - Photo Dialog
    @ViewBuilder
    private var photoDialogButtons: some View {
        Button {
            showCamera = true
        } label: {
            Label("Take Photo", systemImage: "camera")
        }
        
        Button {
            showPhotoPicker = true
        } label: {
            Label("Choose from Library", systemImage: "photo.on.rectangle")
        }
        
        Button("Cancel", role: .cancel) { }
    }
    
    // MARK: - Photo Loading
    private func loadPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    addImage(uiImage)
                }
            }
        }
        // Clear picker selection
        await MainActor.run {
            photosPickerItems = []
        }
    }
    
    private func addImage(_ image: UIImage) {
        guard selectedImages.count < maxPhotos else { return }
        withAnimation {
            selectedImages.append(image)
        }
    }
    
    // MARK: - Helpers
    private var ratingLabel: String {
        switch Int(rating) {
        case 5: return "Excellent! 🌟"
        case 4: return "Very Good! 👍"
        case 3: return "Good 👌"
        case 2: return "Fair 😐"
        case 1: return "Poor 👎"
        default: return ""
        }
    }
    
    private func appendTag(_ tag: String) {
        if !comment.isEmpty && !comment.hasSuffix(" ") {
            comment += " "
        }
        comment += tag
    }
    
    private func submitRating() {
        guard let user = authViewModel.currentUser else { return }
        
        isSubmitting = true
        isCommentFocused = false
        
        // Save photos and get their IDs
        let photoIds = selectedImages.compactMap { image in
            PhotoManager.shared.savePhoto(image)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            restaurantViewModel.submitRating(
                for: dish,
                in: restaurant,
                userId: user.id,
                userName: user.fullName,
                userEmoji: user.avatarEmoji,
                rating: rating,
                comment: comment,
                photos: photoIds
            )
            
            withAnimation(AppTheme.springAnimation) {
                isSubmitting = false
                showSuccess = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
}

// MARK: - Camera Picker (UIImagePickerController wrapper)
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Quick Tag Button
struct QuickTagButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.backgroundSecondary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Success Overlay
struct SuccessOverlay: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            successContent
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
    
    private var successContent: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.green)
                    .frame(width: 80, height: 80)
                    .scaleEffect(animate ? 1 : 0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1 : 0)
            }
            
            Text("Rating Submitted!")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .opacity(animate ? 1 : 0)
            
            Text("Thank you for your review")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .opacity(animate ? 1 : 0)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    RateDishView(
        dish: MockData.restaurants[0].dishes[0],
        restaurant: MockData.restaurants[0]
    )
    .environmentObject(RestaurantViewModel())
    .environmentObject(AuthViewModel())
}

// MARK: - Edit Rating View
struct EditRatingView: View {
    let rating: DishRating
    let dish: Dish
    let restaurant: Restaurant
    
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var editedRating: Double
    @State private var editedComment: String
    @State private var selectedImages: [UIImage] = []
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var photosPickerItems: [PhotosPickerItem] = []
    @FocusState private var isCommentFocused: Bool
    
    private let maxPhotos = 4
    
    init(rating: DishRating, dish: Dish, restaurant: Restaurant) {
        self.rating = rating
        self.dish = dish
        self.restaurant = restaurant
        _editedRating = State(initialValue: rating.rating)
        _editedComment = State(initialValue: rating.comment)
    }
    
    var isValid: Bool {
        editedRating > 0
    }
    
    var hasChanges: Bool {
        editedRating != rating.rating || editedComment != rating.comment || !selectedImages.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                if showSuccess {
                    UpdateSuccessOverlay()
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .background(AppTheme.backgroundSecondary)
            .navigationTitle("Edit Rating")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .confirmationDialog("Add Photo", isPresented: $showPhotoOptions) {
                photoDialogButtons
            } message: {
                Text("Choose a photo source")
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView(image: Binding(
                    get: { nil },
                    set: { newImage in
                        if let image = newImage {
                            addImage(image)
                        }
                    }
                ))
                .ignoresSafeArea()
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $photosPickerItems,
                maxSelectionCount: maxPhotos - selectedImages.count,
                matching: .images
            )
            .onChange(of: photosPickerItems) { oldItems, newItems in
                Task {
                    await loadPhotos(from: newItems)
                }
            }
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                dishHeader
                starRatingSection
                photoSection
                commentSection
                submitSection
            }
            .padding()
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    // MARK: - Dish Header
    private var dishHeader: some View {
        VStack(spacing: 12) {
            // Only show image if dish has one
            if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else if let imageName = dish.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            
            Text(dish.name)
                .font(.title2.weight(.bold))
            
            Text(restaurant.name)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
            
            // Show original rating date
            Text("Originally rated on \(rating.date.formatted(.dateTime.month(.abbreviated).day().year()))")
                .font(.caption)
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Star Rating Section
    private var starRatingSection: some View {
        VStack(spacing: 16) {
            Text("Update your rating")
                .font(.headline)
            
            starButtons
            
            if editedRating > 0 {
                Text(ratingLabel)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(editedRating.ratingColor)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(24)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(AppTheme.springAnimation, value: editedRating)
    }
    
    private var starButtons: some View {
        HStack(spacing: 16) {
            ForEach(1...5, id: \.self) { index in
                Button {
                    withAnimation(AppTheme.springAnimation) {
                        editedRating = Double(index)
                    }
                } label: {
                    Image(systemName: index <= Int(editedRating) ? "star.fill" : "star")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(index <= Int(editedRating) ? AppTheme.starFilled : AppTheme.starEmpty)
                        .scaleEffect(index <= Int(editedRating) ? 1.15 : 1.0)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos")
                    .font(.headline)
                Spacer()
                Text("\(selectedImages.count)/\(maxPhotos)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            if !selectedImages.isEmpty {
                selectedPhotosView
            }
            
            if selectedImages.count < maxPhotos {
                addPhotoButton
            }
        }
        .padding(20)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var selectedPhotosView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    photoThumbnail(image: image, index: index)
                }
            }
        }
    }
    
    private func photoThumbnail(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button {
                withAnimation {
                    if selectedImages.indices.contains(index) {
                        selectedImages.remove(at: index)
                    }
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white, .red)
            }
            .offset(x: 6, y: -6)
        }
    }
    
    private var addPhotoButton: some View {
        Button {
            showPhotoOptions = true
        } label: {
            HStack {
                Image(systemName: "camera.fill")
                Text(selectedImages.isEmpty ? "Add Photo" : "Add More")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Comment Section
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Review")
                    .font(.headline)
                Spacer()
                Text("Optional")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            
            commentEditor
            quickTags
        }
        .padding(20)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var commentEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $editedComment)
                .focused($isCommentFocused)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
            
            if editedComment.isEmpty {
                Text("Share your thoughts about this dish...")
                    .foregroundStyle(AppTheme.textTertiary)
                    .padding(.top, 8)
                    .padding(.leading, 4)
                    .allowsHitTesting(false)
            }
        }
        .padding(12)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var quickTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                QuickTagButton(text: "Delicious!", action: { appendTag("Delicious!") })
                QuickTagButton(text: "Worth the price", action: { appendTag("Worth the price.") })
                QuickTagButton(text: "Great presentation", action: { appendTag("Great presentation.") })
                QuickTagButton(text: "Will order again", action: { appendTag("Will definitely order again!") })
                QuickTagButton(text: "Perfect portion", action: { appendTag("Perfect portion size.") })
            }
        }
    }
    
    // MARK: - Submit Section
    private var submitSection: some View {
        VStack(spacing: 12) {
            Button {
                updateRating()
            } label: {
                HStack(spacing: 8) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Update Rating")
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!isValid || isSubmitting || !hasChanges)
            
            if !hasChanges {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                    Text("Make changes to update your rating")
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .keyboard) {
            Button("Done") {
                isCommentFocused = false
            }
        }
    }
    
    // MARK: - Photo Dialog
    @ViewBuilder
    private var photoDialogButtons: some View {
        Button {
            showCamera = true
        } label: {
            Label("Take Photo", systemImage: "camera")
        }
        
        Button {
            showPhotoPicker = true
        } label: {
            Label("Choose from Library", systemImage: "photo.on.rectangle")
        }
        
        Button("Cancel", role: .cancel) { }
    }
    
    // MARK: - Photo Loading
    private func loadPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    addImage(uiImage)
                }
            }
        }
        // Clear picker selection
        await MainActor.run {
            photosPickerItems = []
        }
    }
    
    private func addImage(_ image: UIImage) {
        guard selectedImages.count < maxPhotos else { return }
        withAnimation {
            selectedImages.append(image)
        }
    }
    
    // MARK: - Helpers
    private var ratingLabel: String {
        switch Int(editedRating) {
        case 5: return "Excellent! 🌟"
        case 4: return "Very Good! 👍"
        case 3: return "Good 👌"
        case 2: return "Fair 😐"
        case 1: return "Poor 👎"
        default: return ""
        }
    }
    
    private func appendTag(_ tag: String) {
        if !editedComment.isEmpty && !editedComment.hasSuffix(" ") {
            editedComment += " "
        }
        editedComment += tag
    }
    
    private func updateRating() {
        isSubmitting = true
        isCommentFocused = false
        
        // Save photos and get their IDs
        let photoIds = selectedImages.compactMap { image in
            PhotoManager.shared.savePhoto(image)
        }
        
        // Combine with existing photos
        let allPhotoIds = rating.photos + photoIds
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            restaurantViewModel.updateRating(
                ratingId: rating.id,
                dishId: dish.id,
                restaurantId: restaurant.id,
                rating: editedRating,
                comment: editedComment,
                photos: allPhotoIds
            )
            
            withAnimation(AppTheme.springAnimation) {
                isSubmitting = false
                showSuccess = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
}

// MARK: - Update Success Overlay
struct UpdateSuccessOverlay: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            successContent
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
    
    private var successContent: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.green)
                    .frame(width: 80, height: 80)
                    .scaleEffect(animate ? 1 : 0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1 : 0)
            }
            
            Text("Rating Updated!")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .opacity(animate ? 1 : 0)
            
            Text("Your changes have been saved")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .opacity(animate ? 1 : 0)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
