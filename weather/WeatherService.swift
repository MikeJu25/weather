//
//  WeatherService.swift
//  weather
//
//  Created by Mike Ju on 2025-01-11.
//

import Foundation

class WeatherService {
    private let apiKey = "8897954b8acf4f2d8cc195212251101"
    private let baseURL = "https://api.weatherapi.com/v1"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func searchCities(query: String, completion: @escaping (Result<[CitySuggestion], Error>) -> Void) {
        let urlString = "\(baseURL)/search.json?key=\(apiKey)&q=\(query)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(WeatherError.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(WeatherError.noData))
                return
            }
            
            do {
                let suggestions = try JSONDecoder().decode([CitySuggestion].self, from: data)
                completion(.success(suggestions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchWeather(for city: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(city)&days=3"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(WeatherError.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(WeatherError.noData))
                return
            }
            
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                completion(.success(weather))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct CitySuggestion: Codable, Identifiable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String
    
    var displayName: String {
        "\(name), \(country)"
    }
}

enum WeatherError: Error {
    case invalidURL
    case noData
}
