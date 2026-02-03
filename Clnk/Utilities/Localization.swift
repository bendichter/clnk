import Foundation

// MARK: - Localization Helpers

/// A typealias for NSLocalizedString for cleaner usage
extension String {
    /// Returns a localized string using the key
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized string with format arguments
    func localized(_ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Localized String Keys

/// Centralized localization keys for type-safe access
enum L10n {
    // MARK: - Common
    enum Common {
        static let appName = "app.name".localized
        static let tagline = "app.tagline".localized
        static let cancel = "common.cancel".localized
        static let save = "common.save".localized
        static let done = "common.done".localized
        static let delete = "common.delete".localized
        static let edit = "common.edit".localized
        static let search = "common.search".localized
        static let loading = "common.loading".localized
        static let error = "common.error".localized
        static let ok = "common.ok".localized
        static let all = "common.all".localized
        static let seeMap = "common.seeMap".localized
    }
    
    // MARK: - Tab Bar
    enum Tab {
        static let explore = "tab.explore".localized
        static let search = "tab.search".localized
        static let map = "tab.map".localized
        static let activity = "tab.activity".localized
        static let profile = "tab.profile".localized
    }
    
    // MARK: - Login & Auth
    enum Auth {
        static let signIn = "login.signIn".localized
        static let email = "login.email".localized
        static let emailPlaceholder = "login.emailPlaceholder".localized
        static let password = "login.password".localized
        static let passwordPlaceholder = "login.passwordPlaceholder".localized
        static let forgotPassword = "login.forgotPassword".localized
        static let or = "login.or".localized
        static let createAccount = "login.createAccount".localized
        static let demoCredentials = "login.demoCredentials".localized
        static let signUp = "signup.signUp".localized
        static let fullName = "signup.fullName".localized
        static let username = "signup.username".localized
        static let confirmPassword = "signup.confirmPassword".localized
        static let signOut = "auth.signOut".localized
        static let signOutConfirm = "auth.signOutConfirm".localized
    }
    
    // MARK: - Restaurants
    enum Restaurants {
        static func greeting(_ name: String) -> String {
            "restaurants.greeting".localized(name)
        }
        static let whatToEat = "restaurants.whatToEat".localized
        static let searchPlaceholder = "restaurants.searchPlaceholder".localized
        static let featured = "restaurants.featured".localized
        static let allRestaurants = "restaurants.allRestaurants".localized
        static let noResults = "restaurants.noResults".localized
        static let noResultsMessage = "restaurants.noResultsMessage".localized
        static func dishCount(_ count: Int) -> String {
            count == 1 ? "restaurants.dishCountSingular".localized : "restaurants.dishCount".localized(count)
        }
        static func ratingsCount(_ count: Int) -> String {
            "restaurants.ratingsCount".localized(count)
        }
        static func topDish(_ name: String) -> String {
            "restaurants.topDish".localized(name)
        }
    }
    
    // MARK: - Restaurant Detail
    enum Restaurant {
        static let about = "restaurant.about".localized
        static let topRated = "restaurant.topRated".localized
        static let menu = "restaurant.menu".localized
    }
    
    // MARK: - Dish
    enum Dish {
        static let aboutThisDish = "dish.aboutThisDish".localized
        static let rateThisDish = "dish.rateThisDish".localized
        static let youRatedThis = "dish.youRatedThis".localized
        static let updateRating = "dish.updateRating".localized
        static let reviews = "dish.reviews".localized
        static let noReviews = "dish.noReviews".localized
        static let noReviewsMessage = "dish.noReviewsMessage".localized
        static func seeAllReviews(_ count: Int) -> String {
            "dish.seeAllReviews".localized(count)
        }
        static let helpful = "dish.helpful".localized
        static let showMore = "dish.showMore".localized
        static let showLess = "dish.showLess".localized
    }
    
    // MARK: - Rating
    enum Rating {
        static let rateYourExperience = "rating.rateYourExperience".localized
        static let tapToRate = "rating.tapToRate".localized
        static let excellent = "rating.excellent".localized
        static let veryGood = "rating.veryGood".localized
        static let good = "rating.good".localized
        static let fair = "rating.fair".localized
        static let poor = "rating.poor".localized
        static let addComment = "rating.addComment".localized
        static let submitRating = "rating.submitRating".localized
        static let thankYou = "rating.thankYou".localized
    }
    
    // MARK: - Reviews
    enum Reviews {
        static let sortRecent = "reviews.sortRecent".localized
        static let sortHelpful = "reviews.sortHelpful".localized
        static let sortHighest = "reviews.sortHighest".localized
        static let sortLowest = "reviews.sortLowest".localized
    }
    
    // MARK: - Tags
    enum Tags {
        static let popular = "tag.popular".localized
        static let spicy = "tag.spicy".localized
        static let vegan = "tag.vegan".localized
        static let vegetarian = "tag.vegetarian".localized
        static let glutenFree = "tag.glutenFree".localized
    }
    
    // MARK: - Search
    enum Search {
        static let title = "search.title".localized
        static let placeholder = "search.placeholder".localized
        static let trending = "search.trending".localized
        static let browseByCuisine = "search.browseByCuisine".localized
        static let restaurants = "search.restaurants".localized
        static let dishes = "search.dishes".localized
        static func at(_ name: String) -> String {
            "search.at".localized(name)
        }
    }
    
    // MARK: - Activity
    enum Activity {
        static let title = "activity.title".localized
        static let ratedADish = "activity.ratedADish".localized
    }
    
    // MARK: - Profile
    enum Profile {
        static let title = "profile.title".localized
        static func memberSince(_ date: String) -> String {
            "profile.memberSince".localized(date)
        }
        static let ratings = "profile.ratings".localized
        static let favorites = "profile.favorites".localized
        static let explored = "profile.explored".localized
        static let yourRatings = "profile.yourRatings".localized
        static let noRatingsYet = "profile.noRatingsYet".localized
        static let noRatingsMessage = "profile.noRatingsMessage".localized
        static let favoriteRestaurants = "profile.favoriteRestaurants".localized
        static let editProfile = "profile.editProfile".localized
        static let notifications = "profile.notifications".localized
        static let helpSupport = "profile.helpSupport".localized
        static let about = "profile.about".localized
        static func version(_ v: String) -> String {
            "profile.version".localized(v)
        }
        static let personalInfo = "profile.personalInfo".localized
        static let chooseAvatar = "profile.chooseAvatar".localized
    }
    
    // MARK: - Map
    enum Map {
        static let title = "map.title".localized
        static let searchThisArea = "map.searchThisArea".localized
        static let useMyLocation = "map.useMyLocation".localized
        static let changeLocation = "map.changeLocation".localized
        static let searchRadius = "map.searchRadius".localized
        static func distance(_ miles: Double) -> String {
            "map.distance".localized(miles)
        }
        static func distanceKm(_ km: Double) -> String {
            "map.distanceKm".localized(km)
        }
        static func restaurantsNearby(_ count: Int) -> String {
            count == 1 ? "map.restaurantSingular".localized : "map.restaurants".localized(count)
        }
        static let noRestaurantsNearby = "map.noRestaurantsNearby".localized
        static let noRestaurantsMessage = "map.noRestaurantsMessage".localized
        static let locationRequired = "map.locationRequired".localized
        static let locationRequiredMessage = "map.locationRequiredMessage".localized
        static let openSettings = "map.openSettings".localized
        static let enterLocation = "map.enterLocation".localized
        static let currentLocation = "map.currentLocation".localized
        static let searchLocation = "map.searchLocation".localized
        static let setSearchCenter = "map.setSearchCenter".localized
        static func radiusMiles(_ miles: Int) -> String {
            "map.radiusMiles".localized(miles)
        }
        static func radiusKm(_ km: Int) -> String {
            "map.radiusKm".localized(km)
        }
    }
    
    // MARK: - Location
    enum Location {
        static let permissionTitle = "location.permissionTitle".localized
        static let permissionMessage = "location.permissionMessage".localized
        static let enableLocation = "location.enableLocation".localized
        static let notNow = "location.notNow".localized
        static let denied = "location.denied".localized
        static let deniedMessage = "location.deniedMessage".localized
    }
    
    // MARK: - Empty States
    enum Empty {
        static let noRestaurants = "empty.noRestaurants".localized
        static let noResults = "empty.noResults".localized
        static let tryAdjusting = "empty.tryAdjusting".localized
    }
}
