import SwiftUI

struct ContentView: View {
    @State private var city = "London"
    @State private var temperature = "--"
    @State private var feelsLike = "--"
    @State private var weatherDescription = ""
    @State private var humidity = "--"
    @State private var windSpeed = "--"
    @State private var windDirection = ""
    @State private var weatherIconURL = ""
    let weatherService = WeatherService()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter city", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: fetchWeather) {
                Text("Get Weather")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Text("Weather in \(city)")
                .font(.title)

            if !weatherIconURL.isEmpty {
                AsyncImage(url: URL(string: "https:\(weatherIconURL)")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                } placeholder: {
                    ProgressView()
                }
            }

            Text("Temperature: \(temperature)°C (Feels Like: \(feelsLike)°C)")
                .font(.headline)

            Text("Description: \(weatherDescription)")
                .font(.subheadline)

            Text("Humidity: \(humidity)%")
                .font(.subheadline)

            Text("Wind: \(windSpeed) km/h (\(windDirection))")
                .font(.subheadline)
        }
        .padding()
    }

    func fetchWeather() {
        weatherService.fetchWeather(for: city) { result in
            switch result {
            case .success(let weather):
                DispatchQueue.main.async {
                    self.temperature = String(format: "%.1f", weather.current.temp_c)
                    self.feelsLike = String(format: "%.1f", weather.current.feelslike_c)
                    self.weatherDescription = weather.current.condition.text
                    self.humidity = "\(weather.current.humidity)"
                    self.windSpeed = String(format: "%.1f", weather.current.wind_kph)
                    self.windDirection = weather.current.wind_dir
                    self.weatherIconURL = weather.current.condition.icon
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.weatherDescription = "Failed to fetch weather: \(error.localizedDescription)"
                }
            }
        }
    }
}
