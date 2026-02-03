import SwiftUI

@main
struct ClnkApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var restaurantViewModel = RestaurantViewModel()
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(restaurantViewModel)
                .environmentObject(locationManager)
                .onAppear {
                    // Bind location manager to restaurant view model
                    restaurantViewModel.bindLocationManager(locationManager)
                    
                    // Request location permission on first launch
                    if locationManager.authorizationStatus == .notDetermined {
                        locationManager.requestPermission()
                    }
                }
        }
    }
}
