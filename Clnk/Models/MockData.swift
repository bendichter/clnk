import Foundation

// MARK: - Mock Users
struct MockData {
    
    static let users: [User] = [
        User(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            username: "foodie_sarah",
            email: "sarah@email.com",
            fullName: "Sarah Chen",
            avatarEmoji: "👩‍🦰",
            avatarImageName: "sarah_chen",
            bio: "Food enthusiast exploring SF's culinary scene 🍜 Always hunting for the perfect dumpling!",
            joinDate: Calendar.current.date(byAdding: .month, value: -8, to: Date())!,
            ratingsCount: 47,
            favoriteRestaurants: []
        ),
        User(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            username: "chef_mike",
            email: "mike@email.com",
            fullName: "Mike Johnson",
            avatarEmoji: "👨‍🍳",
            avatarImageName: "mike_johnson",
            bio: "Professional chef by day, food critic by night. Passionate about authentic flavors and creative cuisine.",
            joinDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
            ratingsCount: 124,
            favoriteRestaurants: []
        ),
        User(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            username: "tasty_adventures",
            email: "emma@email.com",
            fullName: "Emma Rodriguez",
            avatarEmoji: "👩‍🎤",
            avatarImageName: "emma_rodriguez",
            bio: "Vegetarian foodie sharing my plant-based discoveries 🌱",
            joinDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            ratingsCount: 23,
            favoriteRestaurants: []
        )
    ]
    
    static let guestUser = User(
        id: UUID(),
        username: "new_user",
        email: "",
        fullName: "Guest User",
        avatarEmoji: "🧑",
        avatarImageName: nil,
        bio: "",
        joinDate: Date(),
        ratingsCount: 0,
        favoriteRestaurants: []
    )
    
    // MARK: - Restaurants with Dishes
    // Coordinates are based around Alexandria, VA for demo purposes
    
    static let restaurants: [Restaurant] = [
        // 1. Pupatella - Real Alexandria Neapolitan Pizza
        Restaurant(
            id: UUID(uuidString: "aaaa1111-1111-1111-1111-111111111111")!,
            name: "Pupatella",
            cuisine: .pizza,
            description: "Named one of the top 50 artisan pizza chains in the world. Authentic VPN-certified Neapolitan pizza with house-made dough, fresh ingredients imported from Italy, and wood-fired to perfection.",
            address: "700 Slaters Lane, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8062, longitude: -77.0445),
            priceRange: .moderate,
            imageEmoji: "🍕",
            headerColor: "pizza",
            dishes: createPupatellaDishes(),
            isFeatured: true
        ),
        
        // 2. Momo Sushi & Cafe - Real Old Town Alexandria Sushi
        Restaurant(
            id: UUID(uuidString: "bbbb2222-2222-2222-2222-222222222222")!,
            name: "Momo Sushi & Cafe",
            cuisine: .sushi,
            description: "A beloved Old Town Alexandria gem serving fresh sushi and Japanese cuisine. Known for quality fish, creative rolls, and a welcoming atmosphere. A local favorite for over a decade.",
            address: "212 Queen St, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8060, longitude: -77.0433),
            priceRange: .moderate,
            imageEmoji: "🍣",
            headerColor: "sushi",
            dishes: createMomoSushiDishes(),
            isFeatured: true
        ),
        
        // 3. Los Tios Grill - Real Alexandria Mexican Restaurant
        Restaurant(
            id: UUID(uuidString: "cccc3333-3333-3333-3333-333333333333")!,
            name: "Los Tios Grill",
            cuisine: .tacos,
            description: "Authentic Mexican and Salvadoran cuisine serving the Alexandria community for over 25 years. Famous for their sizzling fajitas, fresh guacamole, and generous portions at family-friendly prices.",
            address: "2615 Mt Vernon Ave, Alexandria, VA 22301",
            coordinate: Coordinate(latitude: 38.8302, longitude: -77.0584),
            priceRange: .moderate,
            imageEmoji: "🌮",
            headerColor: "tacos",
            dishes: createLosTiosDishes(),
            isFeatured: false
        ),
        
        // 4. Thai Peppers - Real Del Ray Alexandria Thai Restaurant
        Restaurant(
            id: UUID(uuidString: "dddd4444-4444-4444-4444-444444444444")!,
            name: "Thai Peppers",
            cuisine: .thai,
            description: "A Del Ray neighborhood favorite serving authentic Thai cuisine in a relaxed, family-friendly atmosphere. Known for fresh ingredients, perfectly balanced flavors, and dishes that range from mild to authentically spicy.",
            address: "2018 Mount Vernon Ave, Alexandria, VA 22301",
            coordinate: Coordinate(latitude: 38.8295, longitude: -77.0586),
            priceRange: .moderate,
            imageEmoji: "🍛",
            headerColor: "thai",
            dishes: createThaiPeppersDishes(),
            isFeatured: true
        ),
        
        // 5. Holy Cow - Real Del Ray Alexandria Burger Joint
        Restaurant(
            id: UUID(uuidString: "eeee5555-5555-5555-5555-555555555555")!,
            name: "Holy Cow",
            cuisine: .burgers,
            description: "Del Ray's beloved burger joint serving custom gourmet burgers, hand-cut fries, and crafted milkshakes. Build your own burger or try their creative signature creations in a casual, fun atmosphere.",
            address: "2312 Mt Vernon Ave, Alexandria, VA 22301",
            coordinate: Coordinate(latitude: 38.8297, longitude: -77.0583),
            priceRange: .moderate,
            imageEmoji: "🍔",
            headerColor: "burgers",
            dishes: createHolyCowDishes(),
            isFeatured: false
        ),
        
        // 6. Bombay Curry Company - Real Del Ray Alexandria Indian Restaurant
        Restaurant(
            id: UUID(uuidString: "ffff6666-6666-6666-6666-666666666666")!,
            name: "Bombay Curry Company",
            cuisine: .indian,
            description: "A Del Ray neighborhood institution since 1995. This cozy 40-seat restaurant serves authentic Indian cuisine made with traditional recipes and fresh spices. Listed in Washingtonian Magazine's best cheap eats.",
            address: "2607 Mt Vernon Ave, Alexandria, VA 22301",
            coordinate: Coordinate(latitude: 38.8308, longitude: -77.0582),
            priceRange: .moderate,
            imageEmoji: "🫓",
            headerColor: "indian",
            dishes: createBombayCurryDishes(),
            isFeatured: true
        ),
        
        // 7. Bittersweet Cafe - Real Old Town Alexandria Cafe
        Restaurant(
            id: UUID(uuidString: "aaaa7777-7777-7777-7777-777777777777")!,
            name: "Bittersweet Cafe",
            cuisine: .cafe,
            description: "Celebrating 25 years in Old Town Alexandria! A local favorite featuring full breakfast, fresh salads, specialty sandwiches, hot soups, and famous homemade desserts. Home of the legendary GIANT cupcake and rated among DC's top caterers.",
            address: "823 King St, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8053, longitude: -77.0455),
            priceRange: .moderate,
            imageEmoji: "☕",
            headerColor: "cafe",
            dishes: createBittersweetDishes(),
            isFeatured: false
        ),
        
        // 8. Pork Barrel BBQ - Real Del Ray Alexandria BBQ Restaurant
        Restaurant(
            id: UUID(uuidString: "bbbb8888-8888-8888-8888-888888888888")!,
            name: "Pork Barrel BBQ",
            cuisine: .bbq,
            description: "Del Ray's premier BBQ destination featuring oak and hickory smoked meats, housemade sides, and the largest bar in the neighborhood. Award-winning pulled pork and brisket smoked low and slow in-house daily.",
            address: "2312 Mt Vernon Ave, Alexandria, VA 22301",
            coordinate: Coordinate(latitude: 38.8297, longitude: -77.0583),
            priceRange: .moderate,
            imageEmoji: "🍖",
            headerColor: "bbq",
            dishes: createPorkBarrelDishes(),
            isFeatured: true
        ),
        
        // 9. Daikaya - Real DC Chinatown Ramen Shop
        Restaurant(
            id: UUID(uuidString: "cccc9999-9999-9999-9999-999999999999")!,
            name: "Daikaya",
            cuisine: .ramen,
            description: "Acclaimed Sapporo-style ramen shop in DC's Chinatown. Noodles imported from Nishiyama Seimen in Sapporo, Japan. Known for rich chintan broth and a second-floor izakaya serving Japanese small plates.",
            address: "705 6th St NW, Washington, DC 20001",
            coordinate: Coordinate(latitude: 38.8977, longitude: -77.0201),
            priceRange: .moderate,
            imageEmoji: "🍜",
            headerColor: "ramen",
            dishes: createDaikayaDishes(),
            isFeatured: true
        ),
        
        // 10. Aldo's Italian Kitchen
        Restaurant(
            id: UUID(uuidString: "dddd0000-0000-0000-0000-000000000010")!,
            name: "Aldo's Italian Kitchen",
            cuisine: .pasta,
            description: "Authentic Italian cuisine with homemade pasta, fresh seafood, and classic meat dishes. Family recipes passed down through generations.",
            address: "2850 Eisenhower Ave, Alexandria",
            coordinate: Coordinate(latitude: 38.8005, longitude: -77.0690),
            priceRange: .upscale,
            imageEmoji: "🍝",
            headerColor: "pasta",
            dishes: createAldosDishes(),
            isFeatured: true
        ),
        
        // 11. Bantam King - Real DC Restaurant (Ramen)
        Restaurant(
            id: UUID(uuidString: "eeee0000-0000-0000-0000-000000000011")!,
            name: "Bantam King",
            cuisine: .ramen,
            description: "Japanese chicken ramen and fried chicken in Chinatown. Known for rich chicken paitan broth simmered for hours and crispy Nashville-style fried chicken.",
            address: "501 G St NW, Washington, DC",
            coordinate: Coordinate(latitude: 38.8977, longitude: -77.0201),
            priceRange: .moderate,
            imageEmoji: "🍜",
            headerColor: "ramen",
            dishes: createBantamKingDishes(),
            isFeatured: true
        ),
        
        // 12. Maydan - Real DC Restaurant (Mediterranean)
        Restaurant(
            id: UUID(uuidString: "ffff0000-0000-0000-0000-000000000012")!,
            name: "Maydan",
            cuisine: .mediterranean,
            description: "Michelin-starred Middle Eastern and North African cuisine cooked over live fire. Tawle family-style dining experience featuring hearth-roasted meats and fresh spreads.",
            address: "1346 Florida Ave NW, Washington, DC",
            coordinate: Coordinate(latitude: 38.9180, longitude: -77.0312),
            priceRange: .upscale,
            imageEmoji: "🔥",
            headerColor: "mediterranean",
            dishes: createMaydanDishes(),
            isFeatured: true
        ),
        
        // 13. Ben's Chili Bowl - Real DC Restaurant (Burgers)
        Restaurant(
            id: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000013")!,
            name: "Ben's Chili Bowl",
            cuisine: .burgers,
            description: "A Washington DC landmark since 1958. Famous for the Original Half-Smoke, homemade chili, and classic American comfort food on the historic U Street corridor.",
            address: "1213 U St NW, Washington, DC",
            coordinate: Coordinate(latitude: 38.9169, longitude: -77.0287),
            priceRange: .budget,
            imageEmoji: "🌭",
            headerColor: "burgers",
            dishes: createBensChiliBowlDishes(),
            isFeatured: true
        ),
        
        // 14. Taqueria Habanero - Real DC Restaurant (Tacos)
        Restaurant(
            id: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000014")!,
            name: "Taqueria Habanero",
            cuisine: .tacos,
            description: "Michelin Bib Gourmand award-winning authentic Mexican taqueria. Family-owned and operated, serving real Mexican street food with homemade tortillas.",
            address: "3710 14th St NW, Washington, DC",
            coordinate: Coordinate(latitude: 38.9328, longitude: -77.0325),
            priceRange: .moderate,
            imageEmoji: "🌮",
            headerColor: "tacos",
            dishes: createTaqueriaHabaneroDishes(),
            isFeatured: true
        ),
        
        // 15. Sushi Ogawa - Real DC Restaurant (Sushi)
        Restaurant(
            id: UUID(uuidString: "cccc0000-0000-0000-0000-000000000015")!,
            name: "Sushi Ogawa",
            cuisine: .sushi,
            description: "Traditional Edomae-style sushi near Dupont Circle. Chef Minoru Ogawa imports fish directly from Tokyo's Tsukiji Market for an authentic omakase experience.",
            address: "2100 Connecticut Ave NW, Washington, DC",
            coordinate: Coordinate(latitude: 38.9148, longitude: -77.0476),
            priceRange: .upscale,
            imageEmoji: "🍣",
            headerColor: "sushi",
            dishes: createSushiOgawaDishes(),
            isFeatured: true
        )
    ]
    
    // MARK: - Pupatella Dishes (Real Alexandria Neapolitan Pizza)
    private static func createPupatellaDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Margherita DOC",
                description: "San Marzano tomato, fresh mozzarella di bufala, basil, and extra virgin olive oil on VPN-certified Neapolitan dough",
                price: 20.59, category: .pizza, imageEmoji: "🍕", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 189, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Diavola",
                description: "San Marzano tomato, fior di latte mozzarella, spicy salame, and Calabrian chili oil",
                price: 21.75, category: .pizza, imageEmoji: "🌶️", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Pepperoni Pizza",
                description: "San Marzano tomato, fior di latte mozzarella, and house-cured pepperoni",
                price: 19.38, category: .pizza, imageEmoji: "🍕", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Prosciutto Arugula",
                description: "San Marzano tomato, fior di latte, prosciutto di Parma, fresh arugula, and shaved Parmigiano",
                price: 21.88, category: .pizza, imageEmoji: "🥬", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Burrata Pizza",
                description: "San Marzano tomato, fresh burrata, basil, and extra virgin olive oil",
                price: 23.75, category: .pizza, imageEmoji: "🧀", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 112, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Mushroom Pizza",
                description: "Fior di latte mozzarella, mixed mushrooms, truffle oil, and fresh herbs",
                price: 20.95, category: .pizza, imageEmoji: "🍄", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Meatball Pizza",
                description: "San Marzano tomato, fior di latte mozzarella, house-made meatballs, and fresh basil",
                price: 22.19, category: .pizza, imageEmoji: "🍖", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Chorizo Pizza",
                description: "San Marzano tomato, fior di latte, Spanish chorizo, and roasted peppers",
                price: 21.89, category: .pizza, imageEmoji: "🌶️", imageName: nil,
                isPopular: false, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Classica DOC",
                description: "San Marzano tomato, fresh mozzarella, basil - the original Neapolitan pizza",
                price: 18.27, category: .pizza, imageEmoji: "🍕", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 156, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Bimbi Pizza",
                description: "Kid-sized Margherita pizza with tomato and mozzarella - perfect for little ones",
                price: 14.69, category: .pizza, imageEmoji: "👶", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 67, avgRating: 4.4)
            )
        ]
    }
    
    // MARK: - Momo Sushi Dishes (Real Old Town Alexandria Sushi)
    private static func createMomoSushiDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Sushi Deluxe",
                description: "Chef's selection of 9 pieces of premium nigiri sushi and one specialty roll",
                price: 32.95, category: .sushi, imageEmoji: "🍣", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Dragon Roll",
                description: "Shrimp tempura and cucumber inside, topped with avocado and eel sauce",
                price: 16.95, category: .sushi, imageEmoji: "🐉", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Spicy Tuna Roll",
                description: "Fresh tuna mixed with spicy mayo and scallions, wrapped in seaweed and rice",
                price: 9.95, category: .sushi, imageEmoji: "🌶️", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Rainbow Roll",
                description: "California roll topped with assorted sashimi including tuna, salmon, and yellowtail",
                price: 17.95, category: .sushi, imageEmoji: "🌈", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 123, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Salmon Sashimi",
                description: "6 pieces of premium fresh salmon, sliced to perfection",
                price: 14.95, category: .sushi, imageEmoji: "🐟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Chicken Teriyaki",
                description: "Grilled chicken glazed with house teriyaki sauce, served with rice and vegetables",
                price: 16.95, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Miso Soup",
                description: "Traditional Japanese soup with tofu, wakame seaweed, and scallions",
                price: 3.50, category: .soup, imageEmoji: "🥣", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.3)
            ),
            Dish(
                id: UUID(), name: "Edamame",
                description: "Steamed young soybeans lightly salted",
                price: 5.95, category: .appetizer, imageEmoji: "🫛", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 78, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Gyoza",
                description: "Pan-fried pork and vegetable dumplings with ponzu dipping sauce",
                price: 7.95, category: .appetizer, imageEmoji: "🥟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Unagi Don",
                description: "Grilled freshwater eel over sushi rice with sweet soy glaze",
                price: 22.95, category: .main, imageEmoji: "🍱", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 67, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "California Roll",
                description: "Crab meat, avocado, and cucumber - the classic American maki",
                price: 7.95, category: .sushi, imageEmoji: "🥑", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 156, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Green Tea Ice Cream",
                description: "Creamy matcha-flavored ice cream",
                price: 4.95, category: .dessert, imageEmoji: "🍵", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.6)
            )
        ]
    }
    
    // MARK: - Los Tios Grill Dishes (Real Alexandria Mexican Restaurant)
    private static func createLosTiosDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Tacos Los Tios",
                description: "Three tacos with your choice of beef or chicken, crispy or soft tortillas, served with Mexican rice and refried beans",
                price: 15.99, category: .tacos, imageEmoji: "🌮", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Carne Asada Salvadoreña",
                description: "Grilled skirt steak served with rice, beans, salad, and fresh tortillas - a house specialty",
                price: 18.95, category: .main, imageEmoji: "🥩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Fajitas Mixtas",
                description: "Sizzling combination of beef, chicken, and shrimp with peppers and onions. Served with rice, beans, and tortillas",
                price: 22.95, category: .main, imageEmoji: "🔥", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Chicken Enchiladas",
                description: "Three corn tortillas filled with shredded chicken, topped with green tomatillo sauce and melted cheese",
                price: 14.95, category: .main, imageEmoji: "🫔", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Pupusas",
                description: "Traditional Salvadoran stuffed corn tortillas with cheese and beans, served with curtido and salsa",
                price: 10.95, category: .appetizer, imageEmoji: "🫓", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 123, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Guacamole Los Tios",
                description: "Fresh-made guacamole with tomatoes, onions, cilantro, and lime, served with warm chips",
                price: 9.95, category: .appetizer, imageEmoji: "🥑", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 98, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Chiles Rellenos",
                description: "Two poblano peppers stuffed with cheese, battered and fried, topped with ranchero sauce",
                price: 15.95, category: .main, imageEmoji: "🌶️", imageName: nil,
                isPopular: false, isSpicy: true, isVegetarian: true,
                ratings: generateRatings(count: 78, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Burrito Grande",
                description: "Large flour tortilla stuffed with your choice of meat, rice, beans, cheese, lettuce, and sour cream",
                price: 13.95, category: .tacos, imageEmoji: "🌯", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Camarones al Ajillo",
                description: "Shrimp sautéed in garlic butter sauce, served with rice and vegetables",
                price: 19.95, category: .main, imageEmoji: "🦐", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 67, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Tres Leches Cake",
                description: "Traditional three-milk cake topped with whipped cream - a perfect sweet ending",
                price: 6.95, category: .dessert, imageEmoji: "🍰", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 112, avgRating: 4.8)
            )
        ]
    }
    
    // MARK: - Thai Peppers Dishes (Real Del Ray Alexandria Thai)
    private static func createThaiPeppersDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Pad Thai",
                description: "Stir-fried rice noodles with egg, bean sprouts, scallions, and crushed peanuts in tangy tamarind sauce",
                price: 17.95, category: .main, imageEmoji: "🍜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 189, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Green Curry",
                description: "Green beans, bell peppers, bamboo shoots, and Thai basil simmered in green curry and coconut milk",
                price: 17.95, category: .main, imageEmoji: "🥘", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 156, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Red Curry",
                description: "Bamboo shoots, bell peppers, and Thai basil simmered in red curry and coconut milk",
                price: 17.95, category: .main, imageEmoji: "🍛", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Pad See-Ew",
                description: "Wide rice noodles stir-fried with egg, broccoli, and sweet soy sauce",
                price: 17.95, category: .main, imageEmoji: "🍜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 123, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Basil Fried Rice",
                description: "Chili, basil, and garlic fried rice with onions, bell peppers, and egg",
                price: 17.95, category: .main, imageEmoji: "🍚", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Spring Rolls",
                description: "Crispy vegetable spring rolls served with sweet chili sauce",
                price: 7.95, category: .appetizer, imageEmoji: "🥟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 98, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Pad Prew-Wan",
                description: "Thai sweet and sour with pineapple, tomatoes, onions, snow peas, bell peppers, and cucumbers",
                price: 17.95, category: .main, imageEmoji: "🍍", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Tom Yum Soup",
                description: "Hot and sour soup with mushrooms, lemongrass, galangal, and lime leaves",
                price: 8.95, category: .soup, imageEmoji: "🍲", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 89, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Chicken Satay",
                description: "Grilled chicken skewers marinated in Thai spices, served with peanut sauce and cucumber salad",
                price: 10.95, category: .appetizer, imageEmoji: "🍢", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 101, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Thai Iced Tea",
                description: "Sweet Thai tea with cream - refreshing and perfectly spiced",
                price: 4.50, category: .drinks, imageEmoji: "🧋", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isGlutenFree: true,
                ratings: generateRatings(count: 134, avgRating: 4.7)
            )
        ]
    }
    
    // MARK: - Holy Cow Dishes (Real Del Ray Alexandria Burger Joint)
    private static func createHolyCowDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "The Signature Classic",
                description: "Angus beef with American cheese, Holy Cow secret sauce, lettuce, tomato, pickle, and onion on a brioche bun",
                price: 12.49, category: .main, imageEmoji: "🍔", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 234, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "The Barnyard",
                description: "Angus beef topped with double gouda, smoked brisket, fried pickle spears, fried egg, and bourbon glaze on brioche",
                price: 16.99, category: .main, imageEmoji: "🥚", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 189, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Build Your Own Burger",
                description: "Start with Angus beef patty on brioche and customize with your choice of toppings and sauces",
                price: 10.99, category: .main, imageEmoji: "🍔", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Hand-Cut Fries",
                description: "Fresh-cut fries, crispy on the outside, fluffy inside",
                price: 4.99, category: .sides, imageEmoji: "🍟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 198, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Loaded Cheese Fries",
                description: "Hand-cut fries topped with melted cheese, bacon bits, and sour cream",
                price: 8.99, category: .sides, imageEmoji: "🧀", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Classic Vanilla Shake",
                description: "Thick and creamy vanilla milkshake made with real ice cream",
                price: 6.99, category: .drinks, imageEmoji: "🥤", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 156, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Chocolate Shake",
                description: "Rich chocolate milkshake, thick and creamy",
                price: 6.99, category: .drinks, imageEmoji: "🍫", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Onion Rings",
                description: "Beer-battered crispy onion rings served with dipping sauce",
                price: 5.99, category: .sides, imageEmoji: "🧅", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Veggie Burger",
                description: "House-made black bean and veggie patty with all the classic toppings on brioche",
                price: 11.99, category: .main, imageEmoji: "🌱", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 67, avgRating: 4.3)
            ),
            Dish(
                id: UUID(), name: "Kids Burger",
                description: "Smaller Angus beef patty with cheese on a soft bun, perfect for little ones",
                price: 7.99, category: .main, imageEmoji: "👶", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.5)
            )
        ]
    }
    
    // MARK: - Bombay Curry Company Dishes (Real Del Ray Alexandria Indian)
    private static func createBombayCurryDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Chicken Tikka Masala",
                description: "Boneless tandoori chicken in a creamy tomato sauce with aromatic spices - a house favorite",
                price: 17.95, category: .main, imageEmoji: "🍛", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 189, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Lamb Vindaloo",
                description: "Tender lamb cooked in a spicy Goan-style curry with potatoes and tangy vinegar notes",
                price: 18.95, category: .main, imageEmoji: "🌶️", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 134, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Saag Paneer",
                description: "Fresh spinach cooked with house-made cheese cubes and aromatic spices",
                price: 15.95, category: .main, imageEmoji: "🥬", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isGlutenFree: true,
                ratings: generateRatings(count: 156, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Vegetable Samosas",
                description: "Two crispy pastries stuffed with spiced potatoes and peas, served with tamarind chutney",
                price: 6.95, category: .appetizer, imageEmoji: "🥟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 145, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Garlic Naan",
                description: "Soft leavened bread topped with fresh garlic and cilantro, baked in tandoor",
                price: 3.95, category: .sides, imageEmoji: "🫓", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 198, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Chicken Biryani",
                description: "Fragrant basmati rice layered with spiced chicken, saffron, and caramelized onions",
                price: 16.95, category: .main, imageEmoji: "🍚", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 123, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Mango Lassi",
                description: "Creamy yogurt smoothie blended with sweet mango - cool and refreshing",
                price: 4.50, category: .drinks, imageEmoji: "🥭", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isGlutenFree: true,
                ratings: generateRatings(count: 134, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Tandoori Chicken",
                description: "Half chicken marinated in yogurt and spices, roasted in clay oven until juicy and charred",
                price: 15.95, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 112, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Dal Tadka",
                description: "Yellow lentils tempered with cumin, garlic, and spices",
                price: 13.95, category: .main, imageEmoji: "🫘", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true, isGlutenFree: true,
                ratings: generateRatings(count: 89, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Kheer",
                description: "Traditional Indian rice pudding with cardamom, raisins, and pistachios",
                price: 4.95, category: .dessert, imageEmoji: "🍮", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isGlutenFree: true,
                ratings: generateRatings(count: 78, avgRating: 4.7)
            )
        ]
    }
    
    // MARK: - Bittersweet Cafe Dishes (Real Old Town Alexandria Cafe)
    private static func createBittersweetDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "GIANT Cupcake",
                description: "Bittersweet's legendary oversized cupcake - a local institution. Choose from daily rotating flavors",
                price: 6.95, category: .dessert, imageEmoji: "🧁", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 234, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Chicken Salad Sandwich",
                description: "House-made chicken salad with celery, herbs, and mayo on fresh-baked bread with mixed greens",
                price: 12.95, category: .main, imageEmoji: "🥪", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Soup of the Day",
                description: "Chef's daily soup selection - ask your server for today's special",
                price: 6.95, category: .soup, imageEmoji: "🍲", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 145, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Quiche Lorraine",
                description: "Classic French quiche with bacon, Swiss cheese, and caramelized onions. Served with mixed greens",
                price: 11.95, category: .main, imageEmoji: "🥧", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Garden Salad",
                description: "Fresh mixed greens with cherry tomatoes, cucumbers, and house vinaigrette",
                price: 9.95, category: .salad, imageEmoji: "🥗", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 89, avgRating: 4.3)
            ),
            Dish(
                id: UUID(), name: "BLT Sandwich",
                description: "Crispy bacon, lettuce, and tomato on toasted bread with mayo",
                price: 11.95, category: .main, imageEmoji: "🥓", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Fresh Fruit Cup",
                description: "Seasonal fresh fruit - a healthy and refreshing option",
                price: 5.95, category: .sides, imageEmoji: "🍓", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true, isGlutenFree: true,
                ratings: generateRatings(count: 78, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Chocolate Brownie",
                description: "Rich, fudgy chocolate brownie - a perfect sweet treat",
                price: 4.95, category: .dessert, imageEmoji: "🍫", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 156, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Coffee",
                description: "Fresh-brewed premium coffee - regular or decaf",
                price: 3.50, category: .drinks, imageEmoji: "☕", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true, isGlutenFree: true,
                ratings: generateRatings(count: 198, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Breakfast Burrito",
                description: "Scrambled eggs, cheese, peppers, and your choice of bacon or sausage wrapped in a flour tortilla",
                price: 10.95, category: .main, imageEmoji: "🌯", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 123, avgRating: 4.6)
            )
        ]
    }
    
    // MARK: - Pork Barrel BBQ Dishes (Real Del Ray Alexandria BBQ)
    private static func createPorkBarrelDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Sliced Brisket Sandwich",
                description: "House-smoked sliced brisket topped with cheddar cheese, horsey mayo, and crispy onions on a potato roll",
                price: 15.95, category: .main, imageEmoji: "🥩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 189, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Classic Pulled Pork",
                description: "House-smoked moist pulled pork on a potato roll with your choice of sauce",
                price: 12.95, category: .main, imageEmoji: "🍖", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 234, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Baby Back Ribs",
                description: "Fall-off-the-bone tender ribs smoked with oak and hickory. Half rack served with two sides",
                price: 19.95, category: .main, imageEmoji: "🍖", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Pulled Chicken Sandwich",
                description: "House-smoked moist pulled chicken on a potato roll with your choice of sauce",
                price: 12.95, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Jalapeño Cheddar Sausage",
                description: "Sliced jalapeño and cheddar house-smoked sausage on a potato roll - made locally by Logan Sausage",
                price: 13.95, category: .main, imageEmoji: "🌶️", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Mac & Cheese",
                description: "Creamy, cheesy macaroni - the perfect BBQ side",
                price: 5.95, category: .sides, imageEmoji: "🧀", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 145, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Coleslaw",
                description: "Creamy house-made coleslaw with a tangy vinegar kick",
                price: 4.50, category: .sides, imageEmoji: "🥗", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.3)
            ),
            Dish(
                id: UUID(), name: "Baked Beans",
                description: "Slow-cooked beans with smoked meat and molasses",
                price: 4.95, category: .sides, imageEmoji: "🫘", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Collard Greens",
                description: "Southern-style collards slow-cooked with smoked pork",
                price: 4.95, category: .sides, imageEmoji: "🥬", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 67, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Banana Pudding",
                description: "Classic Southern banana pudding with vanilla wafers - homemade recipe",
                price: 5.95, category: .dessert, imageEmoji: "🍌", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 123, avgRating: 4.7)
            )
        ]
    }
    
    // MARK: - Daikaya Dishes (Real DC Chinatown Ramen Shop)
    private static func createDaikayaDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Shio Ramen",
                description: "Classic salt-based chintan broth with wok-charred garlic, onions, bean sprouts, ground pork, chashu, scallions, and nori. Most delicate and aromatic.",
                price: 17.50, category: .soup, imageEmoji: "🍜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 189, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Shoyu Ramen",
                description: "Traditional Sapporo ramen with rich soy sauce blended with chintan stock. Toasted garlic and light caramel tones. Includes half egg (nitamago).",
                price: 18.00, category: .soup, imageEmoji: "🍜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 234, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Spicy Miso Ramen",
                description: "Shiro miso base blended with chilies and peanuts for balance, depth, and complexity. Contains peanuts.",
                price: 18.50, category: .soup, imageEmoji: "🌶️", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Mugi-Miso Ramen",
                description: "Barley miso with bright, savory aromatics - lighter than traditional miso. Miso ramen was invented in Sapporo, Japan.",
                price: 18.50, category: .soup, imageEmoji: "🍜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Veggie Ramen",
                description: "Topped with wok-charred vegetables, braised shiitake, woodear mushrooms, scallions, and nori. Egg-free noodles, vegan friendly.",
                price: 18.50, category: .soup, imageEmoji: "🥬", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 89, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Fried Gyoza",
                description: "Deep fried dumplings with pork and chicken filling (4 pieces)",
                price: 6.50, category: .appetizer, imageEmoji: "🥟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Veggie Spring Rolls",
                description: "Fried vegetable spring rolls served with jalapeño jam (3 pieces). Vegan friendly!",
                price: 6.50, category: .appetizer, imageEmoji: "🥟", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 78, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Nitamago",
                description: "Soy and ramen stock marinated soft-boiled egg - the perfect topping",
                price: 2.25, category: .sides, imageEmoji: "🥚", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 112, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Pork Belly",
                description: "Extra thick-cut braised pork belly to add to your ramen",
                price: 4.00, category: .sides, imageEmoji: "🥓", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 67, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Sapporo Draft",
                description: "Classic Japanese lager, 16oz - the perfect ramen companion",
                price: 8.00, category: .drinks, imageEmoji: "🍺", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true, isGlutenFree: false,
                ratings: generateRatings(count: 98, avgRating: 4.4)
            )
        ]
    }
    
    // MARK: - Aldo's Italian Kitchen Dishes
    private static func createAldosDishes() -> [Dish] {
        return [
            // ANTIPASTI
            Dish(
                id: UUID(), name: "Mozzarella Frita",
                description: "Fresh Italian mozzarella fried in panko and thyme, served with tomato sauce",
                price: 9.00, category: .appetizer, imageEmoji: "🧀", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 67, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Funghi Ripieni",
                description: "Mushroom caps stuffed with peppers, mozzarella, and fresh herbs",
                price: 11.00, category: .appetizer, imageEmoji: "🍄", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 45, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Calamari Fritti",
                description: "Tender squid served in a blend of Italian tomatoes, virgin olive oil and spices",
                price: 15.00, category: .appetizer, imageEmoji: "🦑", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Cozze al Vino Bianco",
                description: "Fresh mussels served with white wine and garlic olive oil with herbs",
                price: 14.00, category: .appetizer, imageEmoji: "🦪", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 56, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Garlic Bread",
                description: "Homemade bread with garlic olive oil and seasoning",
                price: 6.00, category: .appetizer, imageEmoji: "🥖", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 112, avgRating: 4.3)
            ),
            Dish(
                id: UUID(), name: "Bruschetta al Pomodoro",
                description: "Slices of garlic bread topped with freshly chopped tomatoes, garlic, parsley and mozzarella",
                price: 8.00, category: .appetizer, imageEmoji: "🍅", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 78, avgRating: 4.6)
            ),
            
            // SOUP & SALADS
            Dish(
                id: UUID(), name: "Insalata Cesare",
                description: "Classic Caesar salad with house-made dressing",
                price: 11.00, category: .salad, imageEmoji: "🥗", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 67, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Zuppa del Giorno",
                description: "Chef's daily soup selection",
                price: 9.00, category: .soup, imageEmoji: "🍲", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 34, avgRating: 4.5)
            ),
            
            // PASTA ENTREES
            Dish(
                id: UUID(), name: "Ravioli Ripieni",
                description: "Choice of cheese, spinach or meat ravioli with any choice of sauce",
                price: 22.00, category: .pasta, imageEmoji: "🥟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 98, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Rigatoni al Ragù Bolognese",
                description: "Italian rich meat sauce over rigatoni",
                price: 24.00, category: .pasta, imageEmoji: "🍝", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Lasagna della Casa",
                description: "Homemade meat lasagna",
                price: 22.00, category: .pasta, imageEmoji: "🍝", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 156, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Spaghetti con Polpette",
                description: "Homemade meatballs over pasta in a rich tomato sauce",
                price: 20.00, category: .pasta, imageEmoji: "🍝", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Manicotti di Casa",
                description: "Stuffed with ricotta cheese and chopped spinach",
                price: 20.00, category: .pasta, imageEmoji: "🍝", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 56, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Gnocchi all'Aurora",
                description: "Homemade potato dumplings with fresh tomato, garlic, onion, and cream",
                price: 20.00, category: .pasta, imageEmoji: "🥔", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Penne with Pesto and Grilled Chicken",
                description: "Penne pasta tossed in fresh basil pesto with grilled chicken",
                price: 22.00, category: .pasta, imageEmoji: "🌿", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Rigatoni alla Contadina",
                description: "Ham, pancetta and peas in a cream sauce over rigatoni",
                price: 22.00, category: .pasta, imageEmoji: "🍝", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 45, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Eggplant Parmigiana",
                description: "Sliced eggplant breaded and baked with mozzarella and a fresh tomato sauce",
                price: 22.00, category: .main, imageEmoji: "🍆", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 67, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Linguine alle Vongole",
                description: "Linguine served over little neck clams with a choice of white sauce or red sauce",
                price: 25.00, category: .pasta, imageEmoji: "🦪", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Fettuccine ai Funghi Porcini",
                description: "Sautéed mushrooms served with fettuccine, artichokes, herbs, and garlic oil",
                price: 22.00, category: .pasta, imageEmoji: "🍄", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 56, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Linguine Alfredo con Pollo",
                description: "Grilled chicken with a cream sauce over linguine",
                price: 20.00, category: .pasta, imageEmoji: "🍝", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Linguine Alfredo con Gamberi",
                description: "Fresh shrimp with a cream sauce over linguine",
                price: 22.00, category: .pasta, imageEmoji: "🦐", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.6)
            ),
            
            // MEAT & FISH ENTREES
            Dish(
                id: UUID(), name: "Pollo alla Parmigiana",
                description: "Chicken Milanese with melted mozzarella in our homemade marinara sauce",
                price: 26.00, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Frutti di Mare al Bianco Vino",
                description: "Seafood with white wine, garlic and olive oil",
                price: 30.00, category: .seafood, imageEmoji: "🦐", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 67, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Pollo alla Marsala",
                description: "Chicken served with a red wine and mushroom sauce",
                price: 27.00, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Chicken Piccata",
                description: "Served with a lemon caper sauce",
                price: 27.00, category: .main, imageEmoji: "🍋", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Pollo alla Aldo's",
                description: "Chicken baked with prosciutto and Fontina in a white wine sauce",
                price: 27.00, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Bistecca alla Aldo's",
                description: "Marinated and grilled NY strip served with chopped tomato, garlic, basil, and olive oil",
                price: 30.00, category: .main, imageEmoji: "🥩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Filetto di Manzo",
                description: "Filet of beef served with a choice of vegetables or pasta",
                price: 32.00, category: .main, imageEmoji: "🥩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Salmone alla Griglia",
                description: "Seasoned salmon with a choice of vegetables or pasta",
                price: 31.00, category: .seafood, imageEmoji: "🐟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 67, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Gamberi alla Scampi",
                description: "Fresh shrimp in a spicy red sauce",
                price: 30.00, category: .seafood, imageEmoji: "🦐", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Chef's Special",
                description: "Ask your server about tonight's special entrees",
                price: 32.00, category: .main, imageEmoji: "👨‍🍳", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 45, avgRating: 4.5)
            ),
            
            // VEGETABLES (SIDES)
            Dish(
                id: UUID(), name: "Sautéed Spinach",
                description: "Sautéed with olive oil and garlic",
                price: 9.00, category: .sides, imageEmoji: "🥬", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 34, avgRating: 4.3)
            ),
            Dish(
                id: UUID(), name: "Broccoli Rabe",
                description: "Sautéed with olive oil and garlic",
                price: 9.00, category: .sides, imageEmoji: "🥦", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 28, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "French Beans",
                description: "Sautéed with olive oil and garlic",
                price: 9.00, category: .sides, imageEmoji: "🫛", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 23, avgRating: 4.2)
            ),
            
            // KIDS MENU
            Dish(
                id: UUID(), name: "Mini Cheese Ravioli",
                description: "Small portion of cheese-filled ravioli with marinara sauce. For guests 12 & under.",
                price: 12.00, category: .pasta, imageEmoji: "🥟", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 34, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Spaghetti & Meatball",
                description: "Classic spaghetti with a homemade meatball in marinara sauce. For guests 12 & under.",
                price: 12.00, category: .pasta, imageEmoji: "🍝", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 56, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Chicken Milanese & Pasta",
                description: "Comes with a side of buttery penne pasta or sauce of choice. For guests 12 & under.",
                price: 12.00, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 45, avgRating: 4.4)
            )
        ]
    }
    
    // MARK: - Bantam King Dishes (Real DC Restaurant)
    private static func createBantamKingDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Shio Ramen",
                description: "Classic salt-based chicken broth with ginger and scallions. Topped with pulled chicken, greens, onion, chili threads, corn, naruto, and nori.",
                price: 17.00, category: .soup, imageEmoji: "🍜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Shoyu Ramen",
                description: "Deep and rich soy sauce ramen with aromatic caramel tones. Topped with pulled chicken, greens, onion, chili threads, corn, naruto, and nori.",
                price: 18.00, category: .soup, imageEmoji: "🍜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Miso Ramen",
                description: "Miso and sesame seeds complement the chicken paitan stock. Topped with pulled chicken, greens, onion, chili threads, corn, naruto, and nori.",
                price: 18.00, category: .soup, imageEmoji: "🍜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Spicy Miso Ramen",
                description: "Shiro miso blended with chilies and peanuts for balance, depth, and complexity. Warning: Contains peanuts.",
                price: 19.00, category: .soup, imageEmoji: "🌶️", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Veggie Tantanmen",
                description: "Vegetarian ramen with soy, sesame, and spice. Topped with bok choy, onion, impossible burger, tempeh, and chili oil.",
                price: 19.00, category: .soup, imageEmoji: "🥬", imageName: nil,
                isPopular: false, isSpicy: true, isVegetarian: true,
                ratings: generateRatings(count: 78, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Nashville Fried Chicken Plate",
                description: "Chicken dunked in Nashville Hot spicy oil, dusted with spice mix. Includes rice with chicken drippings, dinner roll, pickles, and salsa verde.",
                price: 17.00, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 189, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Curry Snow Fried Chicken Plate",
                description: "Topped with tangy-sweet onion sauce, Japanese curry powder, and fresh shaved Vidalia onions. Includes rice and dinner roll.",
                price: 17.00, category: .main, imageEmoji: "🍛", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 156, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Gyoza",
                description: "Steamed chicken dumplings with chili oil, sesame seeds, and cilantro. 4 pieces.",
                price: 6.75, category: .appetizer, imageEmoji: "🥟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Nitamago Egg",
                description: "Marinated soft-boiled egg - the perfect ramen topping.",
                price: 2.25, category: .sides, imageEmoji: "🥚", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Rice with Chicken Drippings",
                description: "Hot white rice topped with chicken drippings, butter, and soy sauce.",
                price: 4.50, category: .sides, imageEmoji: "🍚", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 67, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Big Fat Chocolate Chip Cookie",
                description: "Valrhona chocolate and rendered chicken fat come together to create this decadent cookie.",
                price: 5.50, category: .dessert, imageEmoji: "🍪", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 123, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Mochi Ice Cream",
                description: "Mix and match with assorted daily varieties.",
                price: 2.25, category: .dessert, imageEmoji: "🍡", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 56, avgRating: 4.5)
            )
        ]
    }
    
    // MARK: - Maydan Dishes (Real DC Restaurant)
    private static func createMaydanDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Hummus",
                description: "Creamy chickpea spread with tahini and lemon. Served with freshly baked tone bread.",
                price: 10.00, category: .appetizer, imageEmoji: "🥙", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 178, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Muhammara",
                description: "Walnuts, roasted red pepper, and pomegranate molasses spread.",
                price: 10.00, category: .appetizer, imageEmoji: "🌶️", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Halloumi",
                description: "Grilled halloumi cheese with Egyptian peanut dukkah and wildflower honey.",
                price: 18.00, category: .appetizer, imageEmoji: "🧀", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 145, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Chicken Shish Taouk Kebab",
                description: "Grilled chicken skewers marinated with garlic, blue fenugreek, and pomegranate molasses.",
                price: 16.00, category: .main, imageEmoji: "🍢", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Lamb Shish Kebab",
                description: "Tender lamb with kefir labne, cumin, peppers, and onions.",
                price: 23.00, category: .main, imageEmoji: "🥩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 123, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Omani Shrimp",
                description: "Grilled shrimp with dried lime, tamarind, and chiles.",
                price: 25.00, category: .seafood, imageEmoji: "🦐", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Turmeric Roasted Chicken",
                description: "Whole roasted chicken with turmeric, coriander, garlic, and toum. Perfect for sharing.",
                price: 55.00, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 156, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Ribeye",
                description: "Hearth-grilled ribeye with adjika and blue fenugreek.",
                price: 75.00, category: .main, imageEmoji: "🥩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Whole Cauliflower",
                description: "Hearth roasted whole cauliflower with turmeric, tahini, zhough, and za'atar.",
                price: 40.00, category: .main, imageEmoji: "🥬", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 134, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Chopped Salad",
                description: "Persian cucumber, radicchio, avocado, radish, mint, labneh ranch, and crispy chickpeas.",
                price: 18.00, category: .salad, imageEmoji: "🥗", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 78, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Mahalabia",
                description: "Coconut milk pudding with apricot puree and fresh mint.",
                price: 12.00, category: .dessert, imageEmoji: "🍮", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Chocolate Mousse",
                description: "Rich chocolate mousse with sesame tahini whipped cream, spiced chocolate, and Egyptian peanut dukkah.",
                price: 12.00, category: .dessert, imageEmoji: "🍫", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 98, avgRating: 4.7)
            )
        ]
    }
    
    // MARK: - Ben's Chili Bowl Dishes (Real DC Restaurant)
    private static func createBensChiliBowlDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Original Half-Smoke",
                description: "Ben's famous Original Half-Smoke (mixed pork and beef) served on a warm steamed bun. Best with mustard, onions and homemade spicy chili sauce.",
                price: 9.79, category: .main, imageEmoji: "🌭", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 234, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Spicy Half-Smoke",
                description: "The spicy version of the Original Half-Smoke for those who like extra heat.",
                price: 9.79, category: .main, imageEmoji: "🌶️", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 178, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Ben's Famous Burger",
                description: "100% Angus beef burger cooked to order with your choice of toppings. Best with mayo, lettuce and spicy homemade chili sauce.",
                price: 10.99, category: .main, imageEmoji: "🍔", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 189, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Big Ben Burger",
                description: "Jumbo gourmet burger on a premium bun with lettuce, tomato, pickles, red onions, American cheese and special Big Ben sauce.",
                price: 13.79, category: .main, imageEmoji: "🍔", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Jumbo Beef Dog",
                description: "Jumbo 1/4 lb all-beef dog served on a warm steamed bun with your choice of condiments.",
                price: 9.79, category: .main, imageEmoji: "🌭", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Large Chili Con Carne",
                description: "12oz bowl of homemade spicy chili con carne, made with the freshest natural ingredients and a touch of love.",
                price: 11.49, category: .soup, imageEmoji: "🍲", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Chili Cheese Fries",
                description: "Generous portion of classic french fries smothered with homemade chili and melted nacho cheese.",
                price: 8.89, category: .sides, imageEmoji: "🍟", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 198, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Mambo Chicken Tenders",
                description: "Juicy chicken fried to crispy perfection over fresh hot fries, topped with Capital City Mambo Sauce.",
                price: 16.09, category: .main, imageEmoji: "🍗", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Veggie Beyond Burger",
                description: "A Beyond burger with your choice of toppings. Best with mayo, lettuce and Ben's vegan veggie chili.",
                price: 17.29, category: .main, imageEmoji: "🌱", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 67, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Virginia's Banana Pudding",
                description: "The best banana pudding you ever tasted. Homemade with fresh bananas, Nilla wafers, Biscoff cookies, heavy cream and pudding.",
                price: 12.69, category: .dessert, imageEmoji: "🍌", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 156, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Chocolate Milkshake",
                description: "Cold, thick, delicious chocolate milkshake - a fan favorite.",
                price: 7.99, category: .drinks, imageEmoji: "🥤", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            )
        ]
    }
    
    // MARK: - Taqueria Habanero Dishes (Real DC Restaurant)
    private static func createTaqueriaHabaneroDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "4 Tacos Platter",
                description: "Four authentic street tacos with your choice of protein on homemade corn tortillas.",
                price: 21.90, category: .tacos, imageEmoji: "🌮", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 189, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Birria Flautas",
                description: "Crispy corn tortilla beef brisket rolls served with crema fresca, pico de gallo and rich consomé.",
                price: 15.50, category: .appetizer, imageEmoji: "🥟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Nachos",
                description: "Corn tortilla chips, black beans, chihuahua cheese, queso fresco, crema fresca, pico de gallo, pickled jalapeños, choice of protein.",
                price: 15.90, category: .appetizer, imageEmoji: "🧀", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Quesadillas",
                description: "Homemade corn tortilla filled with chihuahua cheese and your choice of protein. Topped with crema fresca, queso fresco, and pico de gallo.",
                price: 16.55, category: .main, imageEmoji: "🧀", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Burritos",
                description: "Large flour tortilla with yellow rice, black beans, pico de gallo, salsa verde, crema fresca, queso fresco and your protein.",
                price: 18.55, category: .tacos, imageEmoji: "🌯", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 156, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Fajita Mixta",
                description: "Sizzling veggie mix with seasoned chicken, beef, and shrimp medley. Served with rice, beans, and fresh tortillas.",
                price: 29.15, category: .main, imageEmoji: "🍳", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Enchiladas de Pollo",
                description: "Shredded chicken, pork chorizo bits, onions, crema fresca, and queso fresco. Choice of Salsa Verde or Mole Poblano.",
                price: 18.56, category: .main, imageEmoji: "🫔", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Chilaquiles",
                description: "Tossed tortilla chips with green or red salsa, organic egg, queso fresco, crema, and onions.",
                price: 15.90, category: .main, imageEmoji: "🍳", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Huaraches",
                description: "Masa tortilla filled with refried black beans, topped with sautéed jalapeños, cactus, grated cheese, cilantro and protein.",
                price: 15.90, category: .main, imageEmoji: "🌮", imageName: nil,
                isPopular: false, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Guacamole & Chips",
                description: "Fresh-made guacamole with crispy corn tortilla chips.",
                price: 9.95, category: .appetizer, imageEmoji: "🥑", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Shrimp Ceviche",
                description: "Lime marinated shrimp, tomatoes, serrano pepper, purple onions, and secret recipe sauce.",
                price: 15.90, category: .appetizer, imageEmoji: "🦐", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Café de Olla",
                description: "Traditional Mexican black coffee with cinnamon and pure cane sugar.",
                price: 5.40, category: .drinks, imageEmoji: "☕", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 56, avgRating: 4.4)
            )
        ]
    }
    
    // MARK: - Sushi Ogawa Dishes (Real DC Restaurant)
    private static func createSushiOgawaDishes() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Omakase at Sushi Bar",
                description: "Chef's selection of the finest seasonal fish, prepared in front of you. The ultimate Edomae sushi experience.",
                price: 240.00, category: .sushi, imageEmoji: "🍣", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Dining Room Omakase (6 Course)",
                description: "Appetizer, sashimi, 15 pieces of sushi, special appetizer, soup, and dessert.",
                price: 200.00, category: .sushi, imageEmoji: "🍱", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Matsu Sushi Assortment",
                description: "11 pieces of premium sushi plus one roll. Includes sea urchin (uni) and salmon roe (ikura).",
                price: 60.00, category: .sushi, imageEmoji: "🍣", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Ootoro (Very Fatty Tuna)",
                description: "Premium bluefin tuna belly - the most prized cut. Single piece of nigiri.",
                price: 15.00, category: .sushi, imageEmoji: "🐟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Uni (Sea Urchin from Hokkaido)",
                description: "Premium sea urchin imported directly from Hokkaido, Japan. Sweet and briny.",
                price: 18.00, category: .sushi, imageEmoji: "🟠", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Wagyu Beef Nigiri",
                description: "Lightly seared A5 wagyu beef over seasoned sushi rice.",
                price: 15.00, category: .sushi, imageEmoji: "🥩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 67, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Wagyu with Sea Urchin",
                description: "A5 wagyu beef topped with creamy Hokkaido sea urchin.",
                price: 20.00, category: .sushi, imageEmoji: "🥩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 56, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Crystal Roll",
                description: "Premium roll with red shrimp, scallop, and salmon roe.",
                price: 30.00, category: .sushi, imageEmoji: "🍣", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Soft Shell Crab Tempura",
                description: "Lightly battered and fried soft shell crab, crispy perfection.",
                price: 18.00, category: .appetizer, imageEmoji: "🦀", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 78, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Chawan Mushi",
                description: "Traditional Japanese steamed egg custard with delicate savory flavor.",
                price: 15.00, category: .appetizer, imageEmoji: "🥚", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 45, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Edamame",
                description: "Steamed soybeans with sea salt.",
                price: 6.00, category: .appetizer, imageEmoji: "🫛", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                isVegan: true,
                ratings: generateRatings(count: 67, avgRating: 4.3)
            ),
            Dish(
                id: UUID(), name: "Miso Soup",
                description: "Traditional miso soup with tofu, wakame seaweed, and scallions.",
                price: 5.00, category: .soup, imageEmoji: "🥣", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 89, avgRating: 4.4)
            )
        ]
    }
    
    // MARK: - Rating Generator
    private static func generateRatings(count: Int, avgRating: Double) -> [DishRating] {
        // Tuple: (name, emoji, UUID, avatarImageName)
        let reviewers: [(String, String, UUID, String)] = [
            ("Sarah C.", "👩‍🦰", UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, "sarah_chen"),
            ("Mike J.", "👨‍🍳", UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, "mike_johnson"),
            ("Emma R.", "👩‍🎤", UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, "emma_rodriguez"),
            ("David L.", "🧔", UUID(uuidString: "44444444-4444-4444-4444-444444444444")!, "david_lee"),
            ("Lisa K.", "👩", UUID(uuidString: "55555555-5555-5555-5555-555555555555")!, "lisa_kim"),
            ("Tom W.", "👨‍💼", UUID(uuidString: "66666666-6666-6666-6666-666666666666")!, "tom_wilson"),
            ("Anna M.", "👩‍🦱", UUID(uuidString: "77777777-7777-7777-7777-777777777777")!, "anna_martinez"),
            ("Chris P.", "🧑", UUID(uuidString: "88888888-8888-8888-8888-888888888888")!, "chris_park"),
            ("Maria G.", "👩‍🔬", UUID(uuidString: "99999999-9999-9999-9999-999999999999")!, "maria_garcia"),
            ("James H.", "👨‍🎨", UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")!, "james_huang"),
            ("Sophie T.", "👱‍♀️", UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")!, "sophie_taylor"),
            ("Alex N.", "🧑‍💻", UUID(uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc")!, "alex_nguyen")
        ]
        
        let comments = [
            "Absolutely delicious! Will definitely order again.",
            "Great flavors, perfectly seasoned.",
            "Good but could use a bit more spice.",
            "The presentation was beautiful.",
            "Excellent value for the quality.",
            "One of the best I've ever had!",
            "Solid choice, very satisfying.",
            "Fresh ingredients, you can taste the quality.",
            "A bit pricey but worth it.",
            "Perfect portion size.",
            "The sauce was incredible.",
            "Nice balance of flavors.",
            "Would recommend to friends!",
            "Comfort food at its finest.",
            "Authentic taste, reminds me of home cooking."
        ]
        
        let photoOptions = [
            ["📸"], ["📷", "🍽️"], ["📸", "🥘", "🍴"], []
        ]
        
        var ratings: [DishRating] = []
        for i in 0..<count {
            let reviewer = reviewers[i % reviewers.count]
            let variance = Double.random(in: -0.8...0.5)
            let baseRating = min(5.0, max(1.0, avgRating + variance))
            
            // Some reviews have photos (about 30%)
            let hasPhotos = i < 4 || Int.random(in: 0...10) < 3
            let photos = hasPhotos ? photoOptions[i % photoOptions.count] : []
            
            let rating = DishRating(
                id: UUID(),
                dishId: UUID(),
                userId: reviewer.2,
                userName: reviewer.0,
                userEmoji: reviewer.1,
                userAvatarImageName: reviewer.3,
                rating: min(5, max(1, baseRating.rounded())),
                comment: i < 5 ? comments[i % comments.count] : "",
                date: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...90), to: Date())!,
                helpful: Int.random(in: 0...25),
                photos: photos
            )
            ratings.append(rating)
        }
        return ratings
    }
    
    // MARK: - Demo Following Data
    
    /// Users to auto-follow in demo mode (so Following tab has content)
    static let demoFollowingUserIds: Set<UUID> = [
        UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, // Sarah Chen
        UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, // Mike Johnson
    ]
    
    /// Get FollowUserInfo for demo following
    static var demoFollowingUsers: [FollowUserInfo] {
        users.filter { demoFollowingUserIds.contains($0.id) }.map { user in
            FollowUserInfo(
                id: user.id,
                username: user.username,
                fullName: user.fullName,
                avatarEmoji: user.avatarEmoji,
                avatarImageName: user.avatarImageName,
                bio: user.bio,
                followedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            )
        }
    }
}
