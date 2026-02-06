import SwiftUI
import MapKit

struct RestaurantMapView: View {
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var selectedRestaurant: Restaurant?
    @State private var showRadiusPicker = false
    @State private var showLocationSearch = false
    @State private var searchText = ""
    @State private var isSearching = false
    
    private let radiusOptions: [Double] = [1, 2, 5, 10, 25, 50]
    
    var body: some View {
        mainContent
            .navigationTitle(L10n.Map.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showRadiusPicker) { radiusPickerSheet }
            .sheet(isPresented: $showLocationSearch) { locationSearchSheet }
            .animation(.spring(response: 0.3), value: selectedRestaurant)
    }
    
    private var mainContent: some View {
        ZStack {
            mapView
            overlayControls
            if locationManager.isLocationDenied {
                LocationPermissionOverlay()
            }
        }
    }
    
    private var radiusPickerSheet: some View {
        RadiusPickerSheet(
            selectedRadius: $locationManager.searchRadius,
            radiusOptions: radiusOptions
        )
        .presentationDetents([.height(300)])
    }
    
    private var locationSearchSheet: some View {
        LocationSearchSheet(isPresented: $showLocationSearch)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showLocationSearch = true
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
    }
    
    private var mapView: some View {
        ClusteredMapView(
            restaurants: restaurantViewModel.nearbyRestaurants,
            userLocation: locationManager.userLocation,
            searchLocation: locationManager.searchLocation,
            searchRadius: locationManager.searchRadius,
            selectedRestaurant: $selectedRestaurant
        )
        .ignoresSafeArea(edges: .top)
        .onAppear { updateMapPosition() }
        .onChange(of: locationManager.effectiveSearchLocation) { _, _ in
            updateMapPosition()
        }
    }
    
    private var overlayControls: some View {
        VStack {
            topControls
            Spacer()
            selectedRestaurantCard
        }
    }
    
    private var topControls: some View {
        HStack {
            Button {
                showRadiusPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "location.circle.fill")
                    Text(L10n.Map.radiusMiles(Int(locationManager.searchRadius)))
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            
            Spacer()
            
            Text(L10n.Map.restaurantsNearby(restaurantViewModel.nearbyRestaurants.count))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var selectedRestaurantCard: some View {
        if let restaurant = selectedRestaurant {
            NavigationLink {
                RestaurantDetailView(restaurant: restaurant)
            } label: {
                RestaurantMapCard(
                    restaurant: restaurant,
                    distance: restaurantViewModel.distance(to: restaurant)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private func updateMapPosition() {
        if let location = locationManager.effectiveSearchLocation {
            let span = spanForRadius(locationManager.searchRadius)
            mapPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: span
            ))
        }
    }
    
    private func spanForRadius(_ radiusMiles: Double) -> MKCoordinateSpan {
        // Convert miles to degrees (approximate)
        let latDelta = radiusMiles / 69.0 * 2.5
        let lonDelta = radiusMiles / 54.6 * 2.5
        return MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    }
    
    private func locationsAreEqual(_ loc1: CLLocation?, _ loc2: CLLocation?) -> Bool {
        guard let l1 = loc1, let l2 = loc2 else { return loc1 == nil && loc2 == nil }
        return l1.coordinate.latitude == l2.coordinate.latitude && 
               l1.coordinate.longitude == l2.coordinate.longitude
    }
}

// MARK: - Restaurant Map Marker
struct RestaurantMapMarker: View {
    let restaurant: Restaurant
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Background bubble
                Circle()
                    .fill(isSelected ? AppTheme.primary : .white)
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Restaurant emoji
                Text(restaurant.imageEmoji)
                    .font(.system(size: isSelected ? 26 : 20))
            }
            
            // Pin tail
            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundColor(isSelected ? AppTheme.primary : .white)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

// MARK: - Restaurant Map Card
struct RestaurantMapCard: View {
    let restaurant: Restaurant
    let distance: Double?
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
    
    var body: some View {
        HStack(spacing: 14) {
            // Restaurant emoji
            ZStack {
                Circle()
                    .fill(restaurant.cuisine.accentColor.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Text(restaurant.imageEmoji)
                    .font(.system(size: 28))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                
                HStack(spacing: 8) {
                    Text(restaurant.cuisine.emoji)
                    Text(restaurant.cuisine.rawValue)
                    Text("•")
                    Text(restaurant.priceRange.display)
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                
                HStack(spacing: 12) {
                    // Rating
                    HStack(spacing: 4) {
                        if restaurant.averageRating > 0 {
                            Image(systemName: "star.fill")
                                .foregroundStyle(AppTheme.starFilled)
                            Text(String(format: "%.1f", restaurant.averageRating))
                                .fontWeight(.bold)
                        } else {
                            Text("No reviews")
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    .font(.subheadline)
                    
                    // Distance
                    if let distance = distance {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .foregroundStyle(AppTheme.primary)
                            Text(L10n.Map.distance(distance))
                        }
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Favorite & Arrow
            VStack(spacing: 12) {
                Button {
                    withAnimation {
                        restaurantViewModel.toggleFavorite(restaurant.id)
                    }
                } label: {
                    Image(systemName: restaurantViewModel.isFavorite(restaurant.id) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(restaurantViewModel.isFavorite(restaurant.id) ? .red : AppTheme.textTertiary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .padding(16)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Location Permission Overlay
struct LocationPermissionOverlay: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.primary)
            
            Text(L10n.Map.locationRequired)
                .font(.title2.weight(.bold))
            
            Text(L10n.Map.locationRequiredMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text(L10n.Map.openSettings)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 60)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(20)
    }
}

// MARK: - Radius Picker Sheet
struct RadiusPickerSheet: View {
    @Binding var selectedRadius: Double
    let radiusOptions: [Double]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Current setting
                VStack(spacing: 8) {
                    Text(L10n.Map.searchRadius)
                        .font(.headline)
                    
                    Text(L10n.Map.radiusMiles(Int(selectedRadius)))
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(AppTheme.primary)
                }
                .padding(.top, 20)
                
                // Radius options
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                    ForEach(radiusOptions, id: \.self) { radius in
                        Button {
                            selectedRadius = radius
                        } label: {
                            Text(L10n.Map.radiusMiles(Int(radius)))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedRadius == radius ? .white : AppTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(selectedRadius == radius ? AppTheme.primary : AppTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Use current location button
                Button {
                    locationManager.useCurrentLocationAsSearchCenter()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                        Text(L10n.Map.useMyLocation)
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(L10n.Map.changeLocation)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.Common.done) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Location Search Sheet
struct LocationSearchSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var locationManager: LocationManager
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField(L10n.Map.enterLocation, text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                
                // Current location option
                Button {
                    locationManager.clearSearchLocation()
                    isPresented = false
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.Map.useMyLocation)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            if locationManager.userLocation != nil {
                                Text(L10n.Map.currentLocation)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        if locationManager.searchLocation == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Search results
                if isSearching {
                    ProgressView()
                        .padding(.top, 40)
                } else if let error = errorMessage {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    List(searchResults, id: \.self) { item in
                        Button {
                            selectLocation(item)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(AppTheme.primary)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "Unknown")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    
                                    if let address = formatAddress(item) {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                Spacer()
            }
            .navigationTitle(L10n.Map.searchLocation)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.Common.cancel) {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        if let location = locationManager.effectiveSearchLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 50000,
                longitudinalMeters: 50000
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            searchResults = response?.mapItems ?? []
            
            if searchResults.isEmpty {
                errorMessage = "No results found"
            }
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        guard let location = item.placemark.location else { return }
        let name = item.name ?? formatAddress(item) ?? "Selected Location"
        locationManager.setSearchLocation(location, name: name)
        isPresented = false
    }
    
    private func formatAddress(_ item: MKMapItem) -> String? {
        let placemark = item.placemark
        var components: [String] = []
        
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

#Preview {
    NavigationStack {
        RestaurantMapView()
            .environmentObject(RestaurantViewModel())
            .environmentObject(LocationManager())
    }
}
