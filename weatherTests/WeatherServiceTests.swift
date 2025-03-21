import XCTest

@testable import weather

final class WeatherServiceTests: XCTestCase {
    var weatherService: WeatherService!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        weatherService = WeatherService(session: mockURLSession)
    }
    
    override func tearDown() {
        weatherService = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    func testFetchWeatherSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch weather success")
        let mockWeather = Weather.mock()
        let mockData = try! JSONEncoder().encode(mockWeather)
        let mockResponse = HTTPURLResponse(url: URL(string: "http://test.com")!,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: nil)!
        
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = mockResponse
        mockURLSession.mockError = nil
        
        // When
        weatherService.fetchWeather(for: "London") { result in
            // Then
            switch result {
            case .success(let weather):
                XCTAssertEqual(weather.current.temp_c, mockWeather.current.temp_c)
                XCTAssertEqual(weather.current.condition.text, mockWeather.current.condition.text)
                XCTAssertEqual(weather.current.humidity, mockWeather.current.humidity)
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchWeatherInvalidURL() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch weather invalid URL")
        
        // When
        weatherService.fetchWeather(for: "") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error as? WeatherError, .invalidURL)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchWeatherNoData() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch weather no data")
        let mockResponse = HTTPURLResponse(url: URL(string: "http://test.com")!,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: nil)!
        
        mockURLSession.mockData = nil
        mockURLSession.mockResponse = mockResponse
        mockURLSession.mockError = nil
        
        // When
        weatherService.fetchWeather(for: "London") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error as? WeatherError, .noData)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchWeatherNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch weather network error")
        let mockError = NSError(domain: "test", code: -1, userInfo: nil)
        
        mockURLSession.mockData = nil
        mockURLSession.mockResponse = nil
        mockURLSession.mockError = mockError
        
        // When
        weatherService.fetchWeather(for: "London") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchWeatherInvalidJSON() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch weather invalid JSON")
        let invalidData = "Invalid JSON".data(using: .utf8)!
        let mockResponse = HTTPURLResponse(url: URL(string: "http://test.com")!,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: nil)!
        
        mockURLSession.mockData = invalidData
        mockURLSession.mockResponse = mockResponse
        mockURLSession.mockError = nil
        
        // When
        weatherService.fetchWeather(for: "London") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure:
                // Decoding error is expected
                break
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Mock URLSession
class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    override func resume() {
        completion()
    }
} 
