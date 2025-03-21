import SwiftUI

struct ContentView: View {
    @State private var newCityName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showingDetail = false
    @State private var selectedCity: StoredCity?
    @State private var storedCities: [StoredCity] = []
    @State private var suggestions: [CitySuggestion] = []
    @State private var isSearching = false
    
    let weatherService = WeatherService()
    let userDefaultsKey = "storedCities"

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.3), .white, .red.opacity(0.3)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Add new city section
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("Enter city", text: $newCityName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .accessibilityLabel("City input field")
                                    .onChange(of: newCityName) { newValue in
                                        if !newValue.isEmpty {
                                            searchCities(query: newValue)
                                        } else {
                                            suggestions = []
                                        }
                                    }
                                
                                Button(action: addNewCity) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Add")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .disabled(isLoading || newCityName.isEmpty)
                                .accessibilityLabel("Add city button")
                            }
                            
                            if !suggestions.isEmpty {
                                ScrollView {
                                    VStack(alignment: .leading) {
                                        ForEach(suggestions) { suggestion in
                                            Button(action: {
                                                newCityName = suggestion.name
                                                suggestions = []
                                            }) {
                                                Text(suggestion.displayName)
                                                    .foregroundColor(.primary)
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 12)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                .frame(maxHeight: 200)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 20)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }

                        // Stored cities list
                        ForEach(storedCities) { city in
                            WeatherCard(city: city) {
                                selectedCity = city
                                refreshWeather(for: city)
                                showingDetail = true
                            } onDelete: {
                                removeCity(city)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Weather")
            .sheet(isPresented: $showingDetail) {
                if let city = selectedCity, let weather = city.weather {
                    DetailedWeatherView(weather: weather)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            loadStoredCities()
        }
    }
    
    func loadStoredCities() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let cities = try? JSONDecoder().decode([StoredCity].self, from: data) {
            storedCities = cities
            // Refresh weather for all stored cities
            for city in cities {
                refreshWeather(for: city)
            }
        }
    }
    
    func saveStoredCities() {
        if let encoded = try? JSONEncoder().encode(storedCities) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func searchCities(query: String) {
        weatherService.searchCities(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cities):
                    suggestions = cities
                case .failure(let error):
                    errorMessage = "Failed to fetch suggestions: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    func refreshWeather(for city: StoredCity) {
        weatherService.fetchWeather(for: city.name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    if let index = storedCities.firstIndex(where: { $0.id == city.id }) {
                        storedCities[index].weather = weather
                        saveStoredCities() // Save after updating weather
                    }
                case .failure(let error):
                    errorMessage = "Failed to refresh weather: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    func addNewCity() {
        guard !newCityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a city name"
            return
        }
        
        // Check if city already exists
        if storedCities.contains(where: { $0.name.lowercased() == newCityName.lowercased() }) {
            errorMessage = "This city is already in your list"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let newCity = StoredCity(name: newCityName)
        storedCities.append(newCity)
        saveStoredCities() // Save after adding new city
        
        weatherService.fetchWeather(for: newCityName) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let weather):
                    if let index = storedCities.firstIndex(where: { $0.id == newCity.id }) {
                        storedCities[index].weather = weather
                        saveStoredCities() // Save after updating weather
                    }
                case .failure(let error):
                    errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
                    showError = true
                    // Remove the city if weather fetch failed
                    storedCities.removeAll { $0.id == newCity.id }
                    saveStoredCities() // Save after removing failed city
                }
            }
        }
        
        newCityName = ""
        suggestions = []
    }
    
    func removeCity(_ city: StoredCity) {
        storedCities.removeAll { $0.id == city.id }
        saveStoredCities() // Save after removing city
    }
}

struct WeatherCard: View {
    let city: StoredCity
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack {
                    Text("Weather in \(city.name)")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }

                if let weather = city.weather {
                    if !weather.current.condition.icon.isEmpty {
                        AsyncImage(url: URL(string: "https:\(weather.current.condition.icon)")) { phase in
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

                    WeatherInfoRow(title: "Temperature", value: "\(String(format: "%.1f", weather.current.temp_c))°C")
                    WeatherInfoRow(title: "Feels Like", value: "\(String(format: "%.1f", weather.current.feelslike_c))°C")
                    WeatherInfoRow(title: "Description", value: weather.current.condition.text)
                    WeatherInfoRow(title: "Humidity", value: "\(weather.current.humidity)%")
                    WeatherInfoRow(title: "Wind", value: "\(String(format: "%.1f", weather.current.wind_kph)) km/h (\(weather.current.wind_dir))")
                } else {
                    ProgressView()
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
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
