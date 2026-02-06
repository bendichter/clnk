import XCTest

/// UI Tests that capture screenshots of every view for App Store submission
/// Run with: xcodebuild test -project Clnk.xcodeproj -scheme ClnkUITests -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'
/// Screenshots saved to: ~/Library/Developer/Xcode/DerivedData/.../Attachments/
final class ScreenshotTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["--uitesting", "--demo-mode"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Screenshots are automatically saved
    }
    
    // MARK: - Screenshot Helper
    
    func takeScreenshot(name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Also save to disk
        let filename = "\(name).png"
        if let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let screenshotsDir = docsDir.appendingPathComponent("Clnk_Screenshots")
            try? FileManager.default.createDirectory(at: screenshotsDir, withIntermediateDirectories: true)
            let fileURL = screenshotsDir.appendingPathComponent(filename)
            try? screenshot.pngRepresentation.write(to: fileURL)
            print("📸 Saved: \(fileURL.path)")
        }
    }
    
    // MARK: - Auth Flow Screenshots
    
    func test01_LoginScreen() throws {
        // Should start on login screen if not logged in
        takeScreenshot(name: "01_Login")
    }
    
    func test02_SignUpScreen() throws {
        // Tap sign up if available
        if app.buttons["Sign Up"].waitForExistence(timeout: 2) {
            app.buttons["Sign Up"].tap()
            sleep(1)
            takeScreenshot(name: "02_SignUp")
        }
    }
    
    // MARK: - Main App Screenshots (Demo Mode)
    
    func test03_ExploreTab() throws {
        // Login with demo mode or skip to main content
        loginIfNeeded()
        
        // Explore tab (should be default or first tab)
        if app.tabBars.buttons["Explore"].exists {
            app.tabBars.buttons["Explore"].tap()
        }
        sleep(2)
        takeScreenshot(name: "03_Explore_RestaurantList")
    }
    
    func test04_ExploreWithCuisineFilter() throws {
        loginIfNeeded()
        
        if app.tabBars.buttons["Explore"].exists {
            app.tabBars.buttons["Explore"].tap()
        }
        sleep(1)
        
        // Tap a cuisine filter if visible
        if app.buttons["Pizza"].waitForExistence(timeout: 2) {
            app.buttons["Pizza"].tap()
            sleep(1)
            takeScreenshot(name: "04_Explore_PizzaFilter")
        }
    }
    
    func test05_RestaurantDetail() throws {
        loginIfNeeded()
        
        if app.tabBars.buttons["Explore"].exists {
            app.tabBars.buttons["Explore"].tap()
        }
        sleep(2)
        
        // Tap first restaurant
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 3) {
            firstCell.tap()
            sleep(2)
            takeScreenshot(name: "05_RestaurantDetail")
            
            // Scroll down to see menu
            app.swipeUp()
            sleep(1)
            takeScreenshot(name: "06_RestaurantDetail_Menu")
        }
    }
    
    func test07_DishDetail() throws {
        loginIfNeeded()
        navigateToFirstRestaurant()
        
        // Scroll to dishes and tap one
        app.swipeUp()
        sleep(1)
        
        // Find a dish cell and tap it
        let dishCells = app.cells.allElementsBoundByIndex
        if dishCells.count > 2 {
            dishCells[2].tap()
            sleep(2)
            takeScreenshot(name: "07_DishDetail")
            
            // Scroll to see reviews
            app.swipeUp()
            sleep(1)
            takeScreenshot(name: "08_DishDetail_Reviews")
        }
    }
    
    func test09_SearchTab() throws {
        loginIfNeeded()
        
        if app.tabBars.buttons["Search"].exists {
            app.tabBars.buttons["Search"].tap()
        }
        sleep(2)
        takeScreenshot(name: "09_Search_Empty")
        
        // Type a search query
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 2) {
            searchField.tap()
            searchField.typeText("Pizza")
            sleep(2)
            takeScreenshot(name: "10_Search_Results")
        }
    }
    
    func test11_MapTab() throws {
        loginIfNeeded()
        
        if app.tabBars.buttons["Map"].exists {
            app.tabBars.buttons["Map"].tap()
        }
        sleep(3) // Allow map to load
        takeScreenshot(name: "11_Map")
    }
    
    func test12_ActivityTab() throws {
        loginIfNeeded()
        
        if app.tabBars.buttons["Activity"].exists {
            app.tabBars.buttons["Activity"].tap()
        }
        sleep(2)
        takeScreenshot(name: "12_Activity")
    }
    
    func test13_ProfileTab() throws {
        loginIfNeeded()
        
        // Navigate to profile (usually through avatar or tab)
        if app.tabBars.buttons["Profile"].exists {
            app.tabBars.buttons["Profile"].tap()
        } else {
            // Try tapping avatar in navigation
            let avatar = app.buttons.matching(identifier: "profileAvatar").firstMatch
            if avatar.waitForExistence(timeout: 2) {
                avatar.tap()
            }
        }
        sleep(2)
        takeScreenshot(name: "13_Profile")
        
        // Scroll to see more profile content
        app.swipeUp()
        sleep(1)
        takeScreenshot(name: "14_Profile_Stats")
    }
    
    func test15_RateDish() throws {
        loginIfNeeded()
        navigateToFirstDish()
        
        // Tap rate button
        if app.buttons["Rate This Dish"].waitForExistence(timeout: 3) {
            app.buttons["Rate This Dish"].tap()
            sleep(2)
            takeScreenshot(name: "15_RateDish")
        }
    }
    
    func test16_Recommendations() throws {
        loginIfNeeded()
        
        if app.tabBars.buttons["Explore"].exists {
            app.tabBars.buttons["Explore"].tap()
        }
        sleep(2)
        
        // Check if recommendations section exists
        if app.staticTexts["For You"].waitForExistence(timeout: 2) {
            takeScreenshot(name: "16_Recommendations")
        }
    }
    
    // MARK: - Helpers
    
    func loginIfNeeded() {
        // Check if we're on login screen
        if app.buttons["Demo Mode"].waitForExistence(timeout: 3) {
            app.buttons["Demo Mode"].tap()
            sleep(2)
        } else if app.buttons["Continue as Guest"].waitForExistence(timeout: 2) {
            app.buttons["Continue as Guest"].tap()
            sleep(2)
        }
        // Already logged in or in demo mode
    }
    
    func navigateToFirstRestaurant() {
        if app.tabBars.buttons["Explore"].exists {
            app.tabBars.buttons["Explore"].tap()
        }
        sleep(2)
        
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 3) {
            firstCell.tap()
            sleep(2)
        }
    }
    
    func navigateToFirstDish() {
        navigateToFirstRestaurant()
        app.swipeUp()
        sleep(1)
        
        let dishCells = app.cells.allElementsBoundByIndex
        if dishCells.count > 2 {
            dishCells[2].tap()
            sleep(2)
        }
    }
}
