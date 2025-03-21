import Foundation

struct Weather: Codable {
    let current: Current
    let forecast: Forecast?
    
    static func mock() -> Weather {
        Weather(
            current: Current(
                temp_c: 20.0,
                feelslike_c: 19.0,
                condition: Condition(text: "Sunny", icon: "/weather/64x64/day/113.png"),
                humidity: 65,
                wind_kph: 12.0,
                wind_dir: "NE",
                pressure_mb: 1015,
                uv: 5.0
            ),
            forecast: Forecast(
                forecastday: [
                    ForecastDay(
                        date: "2024-03-21",
                        day: Day(avgtemp_c: 22.0)
                    ),
                    ForecastDay(
                        date: "2024-03-22",
                        day: Day(avgtemp_c: 21.0)
                    ),
                    ForecastDay(
                        date: "2024-03-23",
                        day: Day(avgtemp_c: 20.0)
                    )
                ]
            )
        )
    }
}

struct Current: Codable {
    let temp_c: Double
    let feelslike_c: Double
    let condition: Condition
    let humidity: Int
    let wind_kph: Double
    let wind_dir: String
    let pressure_mb: Double
    let uv: Double
}

struct Condition: Codable {
    let text: String
    let icon: String
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    let date: String
    let day: Day
    
    var id: String { date }
}

struct Day: Codable {
    let avgtemp_c: Double
} 