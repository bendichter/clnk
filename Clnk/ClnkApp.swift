import SwiftUI

@main
struct ClnkApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var restaurantViewModel = RestaurantViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var deepLinkManager = DeepLinkManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(restaurantViewModel)
                .environmentObject(locationManager)
                .environmentObject(deepLinkManager)
                .onAppear {
                    // Bind location manager to restaurant view model
                    restaurantViewModel.bindLocationManager(locationManager)
                    
                    // Request location permission on first launch
                    if locationManager.authorizationStatus == .notDetermined {
                        locationManager.requestPermission()
                    }
                }
                .onOpenURL { url in
                    deepLinkManager.handle(url: url)
                }
        }
    }
}
