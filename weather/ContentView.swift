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
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    let weatherService = WeatherService()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.3), .white, .red.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        TextField("Enter city", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .accessibilityLabel("City input field")
                        
                        Button(action: fetchWeather) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Get Weather")
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(isLoading)
                        .accessibilityLabel("Get weather button")
                    }
                    .padding(.horizontal, 20)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }

                    if !weatherDescription.isEmpty {
                        VStack(spacing: 16) {
                            Text("Weather in \(city)")
                                .font(.title)
                                .bold()

                            if !weatherIconURL.isEmpty {
                                AsyncImage(url: URL(string: "https:\(weatherIconURL)")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 64, height: 64)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 64, height: 64)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }

                            WeatherInfoRow(title: "Temperature", value: "\(temperature)°C")
                            WeatherInfoRow(title: "Feels Like", value: "\(feelsLike)°C")
                            WeatherInfoRow(title: "Description", value: weatherDescription)
                            WeatherInfoRow(title: "Humidity", value: "\(humidity)%")
                            WeatherInfoRow(title: "Wind", value: "\(windSpeed) km/h (\(windDirection))")
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }

    func fetchWeather() {
        guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a city name"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        weatherService.fetchWeather(for: city) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let weather):
                    self.temperature = String(format: "%.1f", weather.current.temp_c)
                    self.feelsLike = String(format: "%.1f", weather.current.feelslike_c)
                    self.weatherDescription = weather.current.condition.text
                    self.humidity = "\(weather.current.humidity)"
                    self.windSpeed = String(format: "%.1f", weather.current.wind_kph)
                    self.windDirection = weather.current.wind_dir
                    self.weatherIconURL = weather.current.condition.icon
                case .failure(let error):
                    self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
}

struct WeatherInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

#Preview {
    ContentView()
}
