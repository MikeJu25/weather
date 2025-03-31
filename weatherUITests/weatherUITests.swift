import XCTest

final class WeatherUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testInitialUIState() throws {
        // Test initial UI elements are present
        XCTAssertTrue(app.textFields["City input field"].exists)
        XCTAssertTrue(app.buttons["Get weather button"].exists)
        XCTAssertEqual(app.textFields["City input field"].value as? String, "London")
    }
    
    func testEmptyCityInput() throws {
        // Clear the city input
        let cityTextField = app.textFields["City input field"]
        cityTextField.tap()
        cityTextField.typeText("")
        
        // Tap the get weather button
        app.buttons["Get weather button"].tap()
        
        // Verify error message appears
        XCTAssertTrue(app.staticTexts["Please enter a city name"].exists)
    }
    
    func testValidCityInput() throws {
        // Enter a valid city
        let cityTextField = app.textFields["City input field"]
        cityTextField.tap()
        cityTextField.typeText("Paris")
        
        // Tap the get weather button
        app.buttons["Get weather button"].tap()
        
        // Wait for loading indicator to disappear
        let loadingIndicator = app.progressIndicators.element
        XCTAssertTrue(loadingIndicator.exists)
        
        // Wait for weather data to appear
        let weatherTitle = app.staticTexts["Weather in Paris"]
        let exists = weatherTitle.waitForExistence(timeout: 5.0)
        XCTAssertTrue(exists)
        
        // Verify weather information is displayed
        XCTAssertTrue(app.staticTexts["Temperature"].exists)
        XCTAssertTrue(app.staticTexts["Feels Like"].exists)
        XCTAssertTrue(app.staticTexts["Description"].exists)
        XCTAssertTrue(app.staticTexts["Humidity"].exists)
        XCTAssertTrue(app.staticTexts["Wind"].exists)
    }
    
    func testLoadingState() throws {
        // Enter a city
        let cityTextField = app.textFields["City input field"]
        cityTextField.tap()
        cityTextField.typeText("Tokyo")
        
        // Tap the get weather button
        app.buttons["Get weather button"].tap()
        
        // Verify loading indicator appears
        let loadingIndicator = app.progressIndicators.element
        XCTAssertTrue(loadingIndicator.exists)
        
        // Wait for loading to complete
        let weatherTitle = app.staticTexts["Weather in Tokyo"]
        let exists = weatherTitle.waitForExistence(timeout: 5.0)
        XCTAssertTrue(exists)
        
        // Verify loading indicator is gone
        XCTAssertFalse(loadingIndicator.exists)
    }
    
    func testErrorHandling() throws {
        // Enter an invalid city name with special characters
        let cityTextField = app.textFields["City input field"]
        cityTextField.tap()
        cityTextField.typeText("@@@")
        
        // Tap the get weather button
        app.buttons["Get weather button"].tap()
        
        // Wait for error alert to appear
        let errorAlert = app.alerts["Error"]
        let alertExists = errorAlert.waitForExistence(timeout: 5.0)
        XCTAssertTrue(alertExists)
        
        // Tap OK on the alert
        errorAlert.buttons["OK"].tap()
        
        // Verify alert is dismissed
        XCTAssertFalse(errorAlert.exists)
    }
    
    func testKeyboardHandling() throws {
        // Tap the text field
        let cityTextField = app.textFields["City input field"]
        cityTextField.tap()
        
        // Verify keyboard appears
        XCTAssertTrue(app.keyboards.element.exists)
        
        // Type a city name
        cityTextField.typeText("New York")
        
        // Tap outside to dismiss keyboard
        app.staticTexts["Weather in London"].tap()
        
        // Verify keyboard is dismissed
        XCTAssertFalse(app.keyboards.element.exists)
    }
} 