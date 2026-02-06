import Foundation

// MARK: - Mock Users
struct MockData {

    static let users: [User] = [
        User(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            username: "cocktail_sarah",
            email: "sarah@email.com",
            fullName: "Sarah Chen",
            avatarEmoji: "👩‍🦰",
            avatarImageName: "sarah_chen",
            bio: "Cocktail enthusiast exploring DC's bar scene 🍸 Always hunting for the perfect Old Fashioned!",
            joinDate: Calendar.current.date(byAdding: .month, value: -8, to: Date())!,
            ratingsCount: 47,
            favoriteRestaurants: []
        ),
        User(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            username: "bartender_mike",
            email: "mike@email.com",
            fullName: "Mike Johnson",
            avatarEmoji: "👨‍🍳",
            avatarImageName: "mike_johnson",
            bio: "Professional bartender by day, cocktail critic by night. Passionate about craft spirits and creative mixology.",
            joinDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
            ratingsCount: 124,
            favoriteRestaurants: []
        ),
        User(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            username: "zeroproof_emma",
            email: "emma@email.com",
            fullName: "Emma Rodriguez",
            avatarEmoji: "👩‍🎤",
            avatarImageName: "emma_rodriguez",
            bio: "Non-alcoholic cocktail fan sharing my zero-proof discoveries 🌿",
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

    // MARK: - Bars with Cocktails
    // Coordinates are based around Alexandria, VA for demo purposes

    static let restaurants: [Restaurant] = [
        // 1. The Velvet Room — Classic Cocktail Speakeasy
        Restaurant(
            id: UUID(uuidString: "aaaa1111-1111-1111-1111-111111111111")!,
            name: "The Velvet Room",
            cuisine: .classic,
            description: "Elegant speakeasy hidden behind a bookshelf door. Classic cocktails crafted with precision, live jazz on weekends, and an intimate atmosphere that transports you to the 1920s.",
            address: "123 Main St, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8048, longitude: -77.0469),
            priceRange: .upscale,
            imageEmoji: "🥃",
            headerColor: "classic",
            dishes: createVelvetRoomCocktails(),
            isFeatured: true
        ),

        // 2. Copper & Oak — Whiskey Bar
        Restaurant(
            id: UUID(uuidString: "bbbb2222-2222-2222-2222-222222222222")!,
            name: "Copper & Oak",
            cuisine: .whiskey,
            description: "A whiskey lover's paradise featuring over 200 bottles from around the world. Expert bartenders craft both classic and innovative whiskey cocktails in a warm, wood-paneled setting.",
            address: "456 King St, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8051, longitude: -77.0428),
            priceRange: .fine,
            imageEmoji: "🥃",
            headerColor: "whiskey",
            dishes: createCopperOakCocktails(),
            isFeatured: true
        ),

        // 3. The Gin Garden — Botanical Gin Bar
        Restaurant(
            id: UUID(uuidString: "cccc3333-3333-3333-3333-333333333333")!,
            name: "The Gin Garden",
            cuisine: .gin,
            description: "Botanical gin bar with a lush garden patio. Featuring 50+ gins from around the world, fresh herbs grown on-site, and creative tonics made in-house.",
            address: "789 Duke St, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8065, longitude: -77.0502),
            priceRange: .upscale,
            imageEmoji: "🍸",
            headerColor: "gin",
            dishes: createGinGardenCocktails(),
            isFeatured: false
        ),

        // 4. Trader Vic's Hideaway — Tiki Bar
        Restaurant(
            id: UUID(uuidString: "dddd4444-4444-4444-4444-444444444444")!,
            name: "Trader Vic's Hideaway",
            cuisine: .tiki,
            description: "A tropical paradise serving rum cocktails with Polynesian vibes. Flaming drinks, carved mugs, and a bamboo-laden interior that makes every night feel like a vacation.",
            address: "321 Harbor Dr, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.7989, longitude: -77.0412),
            priceRange: .moderate,
            imageEmoji: "🍹",
            headerColor: "tiki",
            dishes: createTraderVicsCocktails(),
            isFeatured: true
        ),

        // 5. Bamboo Lounge — Retro Tiki
        Restaurant(
            id: UUID(uuidString: "eeee5555-5555-5555-5555-555555555555")!,
            name: "Bamboo Lounge",
            cuisine: .tiki,
            description: "Retro tiki bar with vintage decor, flaming drinks, and island-inspired cocktails. A neighborhood favorite for tropical escapism with a mid-century modern twist.",
            address: "555 Pacific Ave, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8102, longitude: -77.0521),
            priceRange: .moderate,
            imageEmoji: "🌴",
            headerColor: "tiki",
            dishes: createBambooLoungeCocktails(),
            isFeatured: false
        ),

        // 6. Molecule — Modern Molecular Mixology
        Restaurant(
            id: UUID(uuidString: "ffff6666-6666-6666-6666-666666666666")!,
            name: "Molecule",
            cuisine: .modern,
            description: "Avant-garde cocktail lab pushing the boundaries of mixology. Molecular techniques, edible cocktails, and multi-sensory experiences in a sleek, futuristic space.",
            address: "777 Innovation Way, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8156, longitude: -77.0445),
            priceRange: .fine,
            imageEmoji: "🧪",
            headerColor: "modern",
            dishes: createMoleculeCocktails(),
            isFeatured: true
        ),

        // 7. The Alchemist — Farm-to-Glass
        Restaurant(
            id: UUID(uuidString: "aaaa7777-7777-7777-7777-777777777777")!,
            name: "The Alchemist",
            cuisine: .modern,
            description: "Farm-to-glass cocktail bar with seasonal ingredients sourced from local farms. House-made syrups, fresh herbs from the rooftop garden, and creative cocktails that change with the seasons.",
            address: "888 Garden Ln, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8089, longitude: -77.0389),
            priceRange: .upscale,
            imageEmoji: "⚗️",
            headerColor: "modern",
            dishes: createAlchemistCocktails(),
            isFeatured: false
        ),

        // 8. The Rusty Nail — Neighborhood Dive
        Restaurant(
            id: UUID(uuidString: "bbbb8888-8888-8888-8888-888888888888")!,
            name: "The Rusty Nail",
            cuisine: .dive,
            description: "No-frills neighborhood dive bar with cheap drinks, friendly regulars, and a jukebox that never quits. The kind of place where everybody knows your name.",
            address: "999 Worker St, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.7945, longitude: -77.0567),
            priceRange: .budget,
            imageEmoji: "🍺",
            headerColor: "dive",
            dishes: createRustyNailCocktails(),
            isFeatured: false
        ),

        // 9. Grape & Grain — Wine Bar
        Restaurant(
            id: UUID(uuidString: "cccc9999-9999-9999-9999-999999999999")!,
            name: "Grape & Grain",
            cuisine: .wine,
            description: "Curated wine bar featuring wines from small producers alongside craft cocktails. Intimate setting with knowledgeable sommeliers and thoughtfully paired small plates.",
            address: "111 Vine St, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8112, longitude: -77.0401),
            priceRange: .upscale,
            imageEmoji: "🍷",
            headerColor: "wine",
            dishes: createGrapeGrainCocktails(),
            isFeatured: false
        ),

        // 10. Agave Dreams — Tequila & Mezcal Bar
        Restaurant(
            id: UUID(uuidString: "dddd0000-0000-0000-0000-000000000010")!,
            name: "Agave Dreams",
            cuisine: .tequila,
            description: "Mezcal and tequila specialists with over 100 bottles. From smoky mezcal flights to creative margaritas, this vibrant cantina celebrates the spirit of Mexico.",
            address: "222 Aztec Ave, Alexandria, VA 22314",
            coordinate: Coordinate(latitude: 38.8034, longitude: -77.0512),
            priceRange: .moderate,
            imageEmoji: "🌵",
            headerColor: "tequila",
            dishes: createAgaveDreamsCocktails(),
            isFeatured: true
        )
    ]

    // MARK: - The Velvet Room Cocktails (Classic Speakeasy)
    private static func createVelvetRoomCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Old Fashioned",
                description: "Bourbon, sugar, Angostura bitters, orange peel — the timeless classic done right",
                price: 14.00, category: .classic, imageEmoji: "🥃", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 189, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Manhattan",
                description: "Rye whiskey, sweet vermouth, Angostura bitters — stirred to perfection",
                price: 15.00, category: .classic, imageEmoji: "🍸", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Martini",
                description: "Gin or vodka, dry vermouth, olive or lemon twist — shaken or stirred",
                price: 14.00, category: .classic, imageEmoji: "🍸", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Negroni",
                description: "Gin, Campari, sweet vermouth — perfectly bitter and balanced",
                price: 13.00, category: .classic, imageEmoji: "🍹", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 156, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Sazerac",
                description: "Rye, absinthe rinse, Peychaud's bitters, sugar — New Orleans in a glass",
                price: 16.00, category: .classic, imageEmoji: "🥃", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 112, avgRating: 4.8)
            )
        ]
    }

    // MARK: - Copper & Oak Cocktails (Whiskey Bar)
    private static func createCopperOakCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Whiskey Sour",
                description: "Bourbon, lemon juice, simple syrup, egg white foam — silky and citrus-forward",
                price: 15.00, category: .whiskey, imageEmoji: "🍋", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 178, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Boulevardier",
                description: "Bourbon, Campari, sweet vermouth — the whiskey lover's Negroni",
                price: 16.00, category: .whiskey, imageEmoji: "🥃", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Penicillin",
                description: "Scotch, lemon, honey-ginger syrup, Islay float — the modern classic",
                price: 18.00, category: .whiskey, imageEmoji: "💊", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 156, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Paper Plane",
                description: "Bourbon, Aperol, Amaro Nonino, lemon — equal parts perfection",
                price: 17.00, category: .modern, imageEmoji: "✈️", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 145, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Kentucky Mule",
                description: "Bourbon, ginger beer, lime, fresh mint — a Southern twist on the Moscow Mule",
                price: 14.00, category: .whiskey, imageEmoji: "🫏", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 98, avgRating: 4.5)
            )
        ]
    }

    // MARK: - The Gin Garden Cocktails (Botanical Gin Bar)
    private static func createGinGardenCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Gin & Tonic",
                description: "Premium gin, Fever-Tree tonic, fresh cucumber — elevated simplicity",
                price: 13.00, category: .classic, imageEmoji: "🥒", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 198, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Bee's Knees",
                description: "Gin, honey syrup, fresh lemon juice — Prohibition-era sweetness",
                price: 14.00, category: .classic, imageEmoji: "🐝", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 167, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Last Word",
                description: "Gin, green Chartreuse, maraschino, lime — herbaceous and complex",
                price: 16.00, category: .classic, imageEmoji: "💬", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Aviation",
                description: "Gin, maraschino, crème de violette, lemon — elegant and floral",
                price: 15.00, category: .classic, imageEmoji: "✈️", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 98, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Garden Collins",
                description: "Gin, elderflower, cucumber, basil, soda — fresh from the garden",
                price: 14.00, category: .seasonal, imageEmoji: "🌿", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.7)
            )
        ]
    }

    // MARK: - Trader Vic's Hideaway Cocktails (Tiki)
    private static func createTraderVicsCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Mai Tai",
                description: "Aged rum, lime, orgeat, orange curaçao — the king of tiki drinks",
                price: 14.00, category: .tiki, imageEmoji: "🍹", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 234, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Zombie",
                description: "Three rums, lime, falernum, absinthe, grenadine — dangerously delicious",
                price: 16.00, category: .tiki, imageEmoji: "🧟", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 189, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Painkiller",
                description: "Rum, pineapple, orange, coconut cream, nutmeg — tropical bliss",
                price: 13.00, category: .tiki, imageEmoji: "💊", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Navy Grog",
                description: "Three rums, lime, grapefruit, honey — a sailor's reward",
                price: 15.00, category: .tiki, imageEmoji: "⚓", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Scorpion Bowl",
                description: "Rum, brandy, orgeat, citrus — serves 2-4, perfect for sharing",
                price: 32.00, category: .tiki, imageEmoji: "🦂", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.9)
            )
        ]
    }

    // MARK: - Bamboo Lounge Cocktails (Retro Tiki)
    private static func createBambooLoungeCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Jungle Bird",
                description: "Rum, Campari, pineapple, lime, simple syrup — bitter-sweet tropical",
                price: 13.00, category: .tiki, imageEmoji: "🦜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 156, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Singapore Sling",
                description: "Gin, cherry heering, Bénédictine, citrus — a colonial classic",
                price: 15.00, category: .tiki, imageEmoji: "🌺", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 98, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Hurricane",
                description: "Light & dark rum, passion fruit, orange, lime — a New Orleans classic",
                price: 12.00, category: .tiki, imageEmoji: "🌀", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Blue Hawaiian",
                description: "Rum, blue curaçao, pineapple, coconut cream — electric blue paradise",
                price: 13.00, category: .tiki, imageEmoji: "🏝️", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.4)
            )
        ]
    }

    // MARK: - Molecule Cocktails (Modern Molecular Mixology)
    private static func createMoleculeCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Smoke Signal",
                description: "Mezcal, activated charcoal, lime, agave, smoked glass — mysterious and bold",
                price: 22.00, category: .signature, imageEmoji: "💨", imageName: nil,
                isPopular: true, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 178, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Lavender Dream",
                description: "Gin, lavender foam, butterfly pea flower, elderflower — changes color before your eyes",
                price: 20.00, category: .signature, imageEmoji: "💜", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.9)
            ),
            Dish(
                id: UUID(), name: "Golden Hour",
                description: "Whiskey, saffron, honey caviar, orange mist — liquid gold luxury",
                price: 24.00, category: .signature, imageEmoji: "🌅", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Forest Floor",
                description: "Vodka, pine, mushroom infusion, truffle oil droplets — earthy and ethereal",
                price: 26.00, category: .signature, imageEmoji: "🍄", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 89, avgRating: 4.7)
            )
        ]
    }

    // MARK: - The Alchemist Cocktails (Farm-to-Glass)
    private static func createAlchemistCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Farmer's Market",
                description: "Seasonal fruit shrub, vodka, herbs from our rooftop garden — changes weekly",
                price: 16.00, category: .seasonal, imageEmoji: "🥕", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 156, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Midnight Garden",
                description: "Gin, blackberry, rosemary, elderflower — dark, aromatic, unforgettable",
                price: 17.00, category: .signature, imageEmoji: "🌙", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Autumn Leaves",
                description: "Apple brandy, maple, cinnamon, walnut bitters — fall in a glass",
                price: 18.00, category: .seasonal, imageEmoji: "🍂", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 98, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Spring Awakening",
                description: "Gin, cucumber, mint, St-Germain, prosecco — light and effervescent",
                price: 16.00, category: .seasonal, imageEmoji: "🌸", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.7)
            )
        ]
    }

    // MARK: - The Rusty Nail Cocktails (Dive Bar)
    private static func createRustyNailCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Rusty Nail",
                description: "Scotch, Drambuie — the house namesake, simple and strong",
                price: 8.00, category: .classic, imageEmoji: "🔩", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 189, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Whiskey Ginger",
                description: "Well whiskey, ginger ale — a reliable classic",
                price: 6.00, category: .classic, imageEmoji: "🥃", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.4)
            ),
            Dish(
                id: UUID(), name: "Rum & Coke",
                description: "Well rum, Coca-Cola — sometimes simple is best",
                price: 6.00, category: .classic, imageEmoji: "🥤", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.3)
            ),
            Dish(
                id: UUID(), name: "PBR & Shot",
                description: "Pabst Blue Ribbon tall boy, well whiskey shot — the dive bar special",
                price: 7.00, category: .classic, imageEmoji: "🍺", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 198, avgRating: 4.5)
            )
        ]
    }

    // MARK: - Grape & Grain Cocktails (Wine Bar)
    private static func createGrapeGrainCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Aperol Spritz",
                description: "Aperol, prosecco, soda, orange slice — the Italian aperitivo",
                price: 12.00, category: .classic, imageEmoji: "🍊", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 178, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Kir Royale",
                description: "Champagne, crème de cassis — elegant French simplicity",
                price: 14.00, category: .classic, imageEmoji: "🍇", imageName: nil,
                isPopular: false, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 98, avgRating: 4.6)
            ),
            Dish(
                id: UUID(), name: "Bellini",
                description: "Prosecco, white peach purée — born at Harry's Bar in Venice",
                price: 13.00, category: .classic, imageEmoji: "🍑", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 145, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Mimosa",
                description: "Champagne, fresh orange juice — brunch's best friend",
                price: 11.00, category: .classic, imageEmoji: "🥂", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 167, avgRating: 4.5)
            )
        ]
    }

    // MARK: - Agave Dreams Cocktails (Tequila & Mezcal)
    private static func createAgaveDreamsCocktails() -> [Dish] {
        return [
            Dish(
                id: UUID(), name: "Margarita",
                description: "Blanco tequila, Cointreau, fresh lime, salt rim — the undisputed champion",
                price: 14.00, category: .classic, imageEmoji: "🍋", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                isGlutenFree: true,
                ratings: generateRatings(count: 234, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Paloma",
                description: "Tequila, grapefruit soda, lime, salt — Mexico's favorite cocktail",
                price: 12.00, category: .classic, imageEmoji: "🍊", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 178, avgRating: 4.7)
            ),
            Dish(
                id: UUID(), name: "Mezcal Mule",
                description: "Mezcal, ginger beer, lime, cucumber — smoky meets spicy",
                price: 14.00, category: .modern, imageEmoji: "🫏", imageName: nil,
                isPopular: false, isSpicy: true, isVegetarian: false,
                ratings: generateRatings(count: 112, avgRating: 4.5)
            ),
            Dish(
                id: UUID(), name: "Oaxacan Old Fashioned",
                description: "Mezcal, reposado tequila, agave nectar, mole bitters — smoky sophistication",
                price: 16.00, category: .modern, imageEmoji: "🌵", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: true,
                ratings: generateRatings(count: 156, avgRating: 4.8)
            ),
            Dish(
                id: UUID(), name: "Tommy's Margarita",
                description: "Tequila, lime, agave nectar — the purist's margarita",
                price: 13.00, category: .classic, imageEmoji: "🍸", imageName: nil,
                isPopular: true, isSpicy: false, isVegetarian: false,
                ratings: generateRatings(count: 134, avgRating: 4.6)
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
            "Perfectly balanced, love this drink!",
            "Great flavor profile, expertly mixed.",
            "Good but could use a stronger pour.",
            "The presentation was stunning.",
            "Excellent cocktail for the price.",
            "One of the best I've ever had!",
            "Solid choice, very smooth.",
            "Quality ingredients, you can taste the craft.",
            "A bit pricey but absolutely worth it.",
            "Perfect spirit-to-mixer ratio.",
            "The garnish really makes it.",
            "Nice balance of sweet and bitter.",
            "Would recommend to friends!",
            "My new go-to drink at this bar.",
            "Authentic recipe, reminds me of a real speakeasy."
        ]

        let photoOptions = [
            ["📸"], ["📷", "🍸"], ["📸", "🥃", "🍹"], []
        ]

        var ratings: [DishRating] = []
        for i in 0..<count {
            let reviewer = reviewers[i % reviewers.count]
            let variance = Double.random(in: -0.8...0.5)
            let baseRating = min(5.0, max(1.0, avgRating + variance))

            // Some reviews have photos (about 30%)
            let hasPhotos = i < 4 || Int.random(in: 0...10) < 3
            let photos = hasPhotos ? photoOptions[i % photoOptions.count] : []

            // Add flavor data to ~60% of ratings
            let hasFlavor = Int.random(in: 0...9) < 6
            let sweet: Double? = hasFlavor ? Double.random(in: 0.1...0.9) : nil
            let salty: Double? = hasFlavor ? Double.random(in: 0.05...0.6) : nil
            let bitter: Double? = hasFlavor ? Double.random(in: 0.1...0.8) : nil
            let sour: Double? = hasFlavor ? Double.random(in: 0.05...0.7) : nil

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
                photos: photos,
                sweet: sweet,
                salty: salty,
                bitter: bitter,
                sour: sour
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
