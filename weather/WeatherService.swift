//
//  WeatherService.swift
//  weather
//
//  Created by Mike Ju on 2025-01-11.
//

import Foundation

struct WeatherService {
    let apiKey = "8897954b8acf4f2d8cc195212251101"
    let baseURL = "https://api.weatherapi.com/v1/current.json"
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)?key=\(apiKey)&q=\(city)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                return
            }
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Current
}

struct Location: Decodable {
    let name: String
    let region: String
    let country: String
    let localtime: String
}

struct Current: Decodable {
    let temp_c: Double
    let feelslike_c: Double
    let condition: Condition
    let humidity: Double
    let wind_kph: Double
    let wind_dir: String
    let pressure_mb: Double
}

struct Condition: Decodable {
    let text: String
    let icon: String
}
