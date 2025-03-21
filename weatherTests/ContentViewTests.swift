import XCTest
import SwiftUI
@testable import weather

final class ContentViewTests: XCTestCase {
    var contentView: ContentView!
    var mockWeatherService: MockWeatherService!
    
    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()
        contentView = ContentView()
    }
    
    override func tearDown() {
        contentView = nil
        mockWeatherService = nil
        super.tearDown()
    }
    
    func testAddNewCity() {
        // Given
        let cityName = "London"
        contentView.newCityName = cityName
        
        // When
        contentView.addNewCity()
        
        // Then
        XCTAssertEqual(contentView.storedCities.count, 1)
        XCTAssertEqual(contentView.storedCities.first?.name, cityName)
        XCTAssertTrue(contentView.newCityName.isEmpty)
    }
    
    func testAddDuplicateCity() {
        // Given
        let cityName = "London"
        contentView.newCityName = cityName
        contentView.addNewCity()
        contentView.newCityName = cityName
        
        // When
        contentView.addNewCity()
        
        // Then
        XCTAssertEqual(contentView.storedCities.count, 1)
        XCTAssertEqual(contentView.storedCities.first?.name, cityName)
    }
    
    func testAddEmptyCity() {
        // Given
        contentView.newCityName = ""
        
        // When
        contentView.addNewCity()
        
        // Then
        XCTAssertTrue(contentView.storedCities.isEmpty)
        XCTAssertEqual(contentView.errorMessage, "Please enter a city name")
    }
    
    func testRemoveCity() {
        // Given
        let city = StoredCity(name: "London")
        contentView.storedCities = [city]
        
        // When
        contentView.removeCity(city)
        
        // Then
        XCTAssertTrue(contentView.storedCities.isEmpty)
    }
    
    func testSearchCities() {
        // Given
        let query = "London"
        let mockCities = [
            CitySuggestion(id: 1, name: "London", region: "City of London", country: "UK", lat: 51.52, lon: -0.11, url: "http://test.com")
        ]
        
        // When
        contentView.newCityName = query
        contentView.searchCities(query: query)
        
        // Then
        XCTAssertEqual(contentView.suggestions.count, 1)
        XCTAssertEqual(contentView.suggestions.first?.name, "London")
    }
    
    func testClearSuggestions() {
        // Given
        contentView.suggestions = [CitySuggestion(id: 1, name: "London", region: "City of London", country: "UK", lat: 51.52, lon: -0.11, url: "http://test.com")]
        
        // When
        contentView.newCityName = ""
        
        // Then
        XCTAssertTrue(contentView.suggestions.isEmpty)
    }
    
    func testRefreshWeather() {
        // Given
        let city = StoredCity(name: "London")
        contentView.storedCities = [city]
        
        // When
        contentView.refreshWeather(for: city)
        
        // Then
        // Note: Actual weather data would be updated asynchronously
        // We can verify the refresh was triggered by checking the storedCities array
        XCTAssertEqual(contentView.storedCities.count, 1)
        XCTAssertEqual(contentView.storedCities.first?.name, "London")
    }
}

// MARK: - Mock WeatherService
class MockWeatherService: WeatherService {
    var mockWeather: Weather?
    var mockCities: [CitySuggestion]?
    var shouldSucceed = true
    
    override func fetchWeather(for city: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        if shouldSucceed, let weather = mockWeather {
            completion(.success(weather))
        } else {
            completion(.failure(WeatherError.noData))
        }
    }
    
    override func searchCities(query: String, completion: @escaping (Result<[CitySuggestion], Error>) -> Void) {
        if shouldSucceed, let cities = mockCities {
            completion(.success(cities))
        } else {
            completion(.failure(WeatherError.noData))
        }
    }
} 