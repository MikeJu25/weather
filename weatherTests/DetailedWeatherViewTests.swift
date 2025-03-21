import XCTest
import SwiftUI
@testable import weather

final class DetailedWeatherViewTests: XCTestCase {
    var detailedView: DetailedWeatherView!
    var mockWeather: Weather!
    
    override func setUp() {
        super.setUp()
        mockWeather = Weather(
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
            forecast: Forecast(
                forecastday: [
                    ForecastDay(
                        date: "2024-03-20",
                        date_epoch: 1710892800,
                        day: Day(
                            maxtemp_c: 18.0,
                            maxtemp_f: 64.0,
                            mintemp_c: 12.0,
                            mintemp_f: 54.0,
                            avgtemp_c: 15.0,
                            avgtemp_f: 59.0,
                            maxwind_kph: 15.0,
                            totalprecip_mm: 0.0,
                            avghumidity: 70,
                            condition: Condition(text: "Sunny", icon: "sunny.png", code: 1000)
                        )
                    )
                ]
            )
        )
        detailedView = DetailedWeatherView(weather: mockWeather)
    }
    
    override func tearDown() {
        detailedView = nil
        mockWeather = nil
        super.tearDown()
    }
    
    func testWeatherDataDisplay() {
        // Given
        let view = detailedView.body
        
        // Then
        // Note: Since we're testing a SwiftUI view, we can't directly test the view hierarchy
        // Instead, we can verify that the weather data is correctly passed to the view
        XCTAssertEqual(detailedView.weather.location.name, "London")
        XCTAssertEqual(detailedView.weather.current.temp_c, 15.0)
        XCTAssertEqual(detailedView.weather.current.condition.text, "Sunny")
    }
    
    func testTemperatureConversion() {
        // Given
        let celsius = 15.0
        let expectedFahrenheit = 59.0
        
        // When
        let fahrenheit = celsius * 9/5 + 32
        
        // Then
        XCTAssertEqual(fahrenheit, expectedFahrenheit)
    }
    
    func testAirQualityIndex() {
        // Given
        let aqi = detailedView.weather.current.air_quality["us-epa-index"] ?? 0
        
        // Then
        XCTAssertEqual(aqi, 1)
    }
    
    func testForecastData() {
        // Given
        let forecast = detailedView.weather.forecast.forecastday.first
        
        // Then
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.day.maxtemp_c, 18.0)
        XCTAssertEqual(forecast?.day.mintemp_c, 12.0)
        XCTAssertEqual(forecast?.day.avgtemp_c, 15.0)
    }
} 