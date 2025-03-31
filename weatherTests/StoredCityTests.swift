import XCTest
@testable import weather

final class StoredCityTests: XCTestCase {
    func testStoredCityInitialization() {
        // Given
        let name = "London"
        
        // When
        let city = StoredCity(name: name)
        
        // Then
        XCTAssertEqual(city.name, name)
        XCTAssertNil(city.weather)
    }
    
    func testStoredCityEquality() {
        // Given
        let city1 = StoredCity(name: "London")
        let city2 = StoredCity(name: "London")
        let city3 = StoredCity(name: "Paris")
        
        // Then
        XCTAssertEqual(city1, city2)
        XCTAssertNotEqual(city1, city3)
    }
    
    func testStoredCityWithWeather() {
        // Given
        let weather = Weather(
            location: Location(name: "London", region: "City of London", country: "UK", lat: 51.52, lon: -0.11, localtime: "2024-03-20 12:00"),
            current: Current(
                temp_c: 15.0,
                temp_f: 59.0,
                condition: Condition(text: "Sunny", icon: "sunny.png", code: 1000),
                humidity: 65,
                wind_kph: 10.0,
                wind_dir: "NW",
                pressure_mb: 1015,
                feelslike_c: 14.0,
                feelslike_f: 57.0,
                uv: 5.0,
                air_quality: AirQuality(co: 0.5, no2: 10.0, o3: 30.0, pm2_5: 5.0, pm10: 10.0, "us-epa-index": 1)
            ),
            forecast: Forecast(forecastday: [])
        )
        
        // When
        var city = StoredCity(name: "London")
        city.weather = weather
        
        // Then
        XCTAssertNotNil(city.weather)
        XCTAssertEqual(city.weather?.location.name, "London")
        XCTAssertEqual(city.weather?.current.temp_c, 15.0)
    }
    
    func testStoredCityCoding() {
        // Given
        let city = StoredCity(name: "London")
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(city)
            let decodedCity = try decoder.decode(StoredCity.self, from: data)
            
            // Then
            XCTAssertEqual(decodedCity.name, city.name)
            XCTAssertNil(decodedCity.weather)
        } catch {
            XCTFail("Coding failed with error: \(error)")
        }
    }
    
    func testStoredCityWithWeatherCoding() {
        // Given
        let weather = Weather(
            location: Location(name: "London", region: "City of London", country: "UK", lat: 51.52, lon: -0.11, localtime: "2024-03-20 12:00"),
            current: Current(
                temp_c: 15.0,
                temp_f: 59.0,
                condition: Condition(text: "Sunny", icon: "sunny.png", code: 1000),
                humidity: 65,
                wind_kph: 10.0,
                wind_dir: "NW",
                pressure_mb: 1015,
                feelslike_c: 14.0,
                feelslike_f: 57.0,
                uv: 5.0,
                air_quality: AirQuality(co: 0.5, no2: 10.0, o3: 30.0, pm2_5: 5.0, pm10: 10.0, "us-epa-index": 1)
            ),
            forecast: Forecast(forecastday: [])
        )
        var city = StoredCity(name: "London")
        city.weather = weather
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(city)
            let decodedCity = try decoder.decode(StoredCity.self, from: data)
            
            // Then
            XCTAssertEqual(decodedCity.name, city.name)
            XCTAssertNotNil(decodedCity.weather)
            XCTAssertEqual(decodedCity.weather?.location.name, weather.location.name)
            XCTAssertEqual(decodedCity.weather?.current.temp_c, weather.current.temp_c)
        } catch {
            XCTFail("Coding failed with error: \(error)")
        }
    }
} 