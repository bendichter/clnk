import Foundation
import CoreLocation
import Combine

/// Manages location services for the app
@MainActor
class LocationManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var userLocation: CLLocation?
    @Published var searchLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var searchRadius: Double = 5.0 // miles
    @Published var isUpdatingLocation = false
    @Published var locationError: LocationError?
    @Published var searchLocationName: String?
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // MARK: - Computed Properties
    var isLocationAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var isLocationDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
    
    /// The effective search center (user location if no custom search location set)
    var effectiveSearchLocation: CLLocation? {
        searchLocation ?? userLocation
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
        
        // If already authorized, start updating location
        if isLocationAuthorized {
            startUpdatingLocation()
        }
    }
    
    // MARK: - Public Methods
    
    /// Request location permissions
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Start updating location
    func startUpdatingLocation() {
        guard isLocationAuthorized else {
            requestPermission()
            return
        }
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    /// Stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isUpdatingLocation = false
    }
    
    /// Request a single location update
    func requestSingleLocation() {
        guard isLocationAuthorized else {
            requestPermission()
            return
        }
        locationManager.requestLocation()
    }
    
    /// Set a custom search location
    func setSearchLocation(_ location: CLLocation, name: String? = nil) {
        searchLocation = location
        searchLocationName = name
    }
    
    /// Clear custom search location (revert to user location)
    func clearSearchLocation() {
        searchLocation = nil
        searchLocationName = nil
    }
    
    /// Use current user location as search center
    func useCurrentLocationAsSearchCenter() {
        if let userLocation = userLocation {
            searchLocation = userLocation
            searchLocationName = L10n.Map.currentLocation
        }
    }
    
    /// Geocode an address to get coordinates
    func geocodeAddress(_ address: String) async throws -> CLLocation {
        let placemarks = try await geocoder.geocodeAddressString(address)
        guard let location = placemarks.first?.location else {
            throw LocationError.geocodingFailed
        }
        return location
    }
    
    /// Reverse geocode a location to get address
    func reverseGeocode(_ location: CLLocation) async throws -> String {
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw LocationError.geocodingFailed
        }
        return formatPlacemark(placemark)
    }
    
    /// Calculate distance between search center and a coordinate
    func distanceFromSearchCenter(to coordinate: CLLocationCoordinate2D) -> Double? {
        guard let searchCenter = effectiveSearchLocation else { return nil }
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        // Return distance in miles
        return searchCenter.distance(from: targetLocation) / 1609.34
    }
    
    /// Check if a coordinate is within search radius
    func isWithinSearchRadius(_ coordinate: CLLocationCoordinate2D) -> Bool {
        guard let distance = distanceFromSearchCenter(to: coordinate) else { return false }
        return distance <= searchRadius
    }
    
    // MARK: - Private Methods
    
    private func formatPlacemark(_ placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let name = placemark.name {
            components.append(name)
        }
        if let locality = placemark.locality {
            if components.isEmpty || components.first != locality {
                components.append(locality)
            }
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        return components.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            userLocation = location
            isUpdatingLocation = false
            locationError = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isUpdatingLocation = false
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    locationError = .permissionDenied
                case .locationUnknown:
                    locationError = .locationUnknown
                default:
                    locationError = .unknown(error.localizedDescription)
                }
            } else {
                locationError = .unknown(error.localizedDescription)
            }
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            
            if isLocationAuthorized {
                startUpdatingLocation()
            }
        }
    }
}

// MARK: - Location Error
enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnknown
    case geocodingFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .locationUnknown:
            return "Unable to determine location"
        case .geocodingFailed:
            return "Could not find location"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Coordinate Comparison Helper
extension CLLocationCoordinate2D {
    func isEqual(to other: CLLocationCoordinate2D) -> Bool {
        self.latitude == other.latitude && self.longitude == other.longitude
    }
}
