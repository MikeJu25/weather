import SwiftUI

struct DetailedWeatherView: View {
    let weather: Weather
    @State private var isAnimating = false
    @State private var rainOffset: CGFloat = -1000
    @State private var snowOffset: CGFloat = -1000
    @State private var sunRotation: Double = 0
    
    private var isRainy: Bool {
        weather.current.condition.text.lowercased().contains("rain")
    }
    
    private var isSnowy: Bool {
        weather.current.condition.text.lowercased().contains("snow")
    }
    
    private var isSunny: Bool {
        weather.current.condition.text.lowercased().contains("sun") || 
        weather.current.condition.text.lowercased().contains("clear")
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.3), .white, .red.opacity(0.3)]),
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                // Weather animations
                if isRainy {
                    RainAnimation(offset: $rainOffset)
                }
                
                if isSnowy {
                    SnowAnimation(offset: $snowOffset)
                }
                
                if isSunny {
                    SunAnimation(rotation: $sunRotation)
                }
                
                VStack(spacing: 25) {
                    // Weather Icon with Animation
                    if let iconURL = URL(string: "https:\(weather.current.condition.icon)") {
                        AsyncImage(url: iconURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 2.0)
                                            .repeatForever(autoreverses: true),
                                        value: isAnimating
                                    )
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    // Temperature and Condition
                    VStack(spacing: 8) {
                        Text("\(Int(weather.current.temp_c))°C")
                            .font(.system(size: 70, weight: .bold))
                        Text(weather.current.condition.text)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Weather Details Card
                    VStack(spacing: 15) {
                        WeatherDetailRow(title: "Feels Like", value: "\(Int(weather.current.feelslike_c))°C")
                        WeatherDetailRow(title: "Humidity", value: "\(weather.current.humidity)%")
                        WeatherDetailRow(title: "Wind Speed", value: "\(Int(weather.current.wind_kph)) km/h")
                        WeatherDetailRow(title: "Wind Direction", value: weather.current.wind_dir)
                        WeatherDetailRow(title: "Pressure", value: "\(weather.current.pressure_mb) mb")
                        WeatherDetailRow(title: "UV Index", value: "\(weather.current.uv)")
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                    // Additional Weather Info
                    if let forecast = weather.forecast {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Forecast")
                                .font(.title2)
                                .bold()
                            
                            ForEach(forecast.forecastday.prefix(3)) { day in
                                HStack {
                                    Text(day.date)
                                        .font(.headline)
                                    Spacer()
                                    Text("\(Int(day.day.avgtemp_c))°C")
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            isAnimating = true
            startWeatherAnimations()
        }
    }
    
    private func startWeatherAnimations() {
        if isRainy {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rainOffset = 1000
            }
        }
        
        if isSnowy {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                snowOffset = 1000
            }
        }
        
        if isSunny {
            withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
                sunRotation = 360
            }
        }
    }
}

struct RainAnimation: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50) { index in
                RainDrop(offset: offset, delay: Double(index) * 0.1)
                    .offset(x: CGFloat(index * 20), y: offset)
            }
        }
    }
}

struct RainDrop: View {
    let offset: CGFloat
    let delay: Double
    
    var body: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.3))
            .frame(width: 2, height: 20)
            .offset(y: offset)
            .animation(.linear(duration: 2.0).delay(delay).repeatForever(autoreverses: false), value: offset)
    }
}

struct SnowAnimation: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<30) { index in
                Snowflake(offset: offset, delay: Double(index) * 0.2)
                    .offset(x: CGFloat(index * 30), y: offset)
            }
        }
    }
}

struct Snowflake: View {
    let offset: CGFloat
    let delay: Double
    
    var body: some View {
        Image(systemName: "snowflake")
            .foregroundColor(.white.opacity(0.8))
            .font(.system(size: 20))
            .offset(y: offset)
            .animation(.linear(duration: 3.0).delay(delay).repeatForever(autoreverses: false), value: offset)
    }
}

struct SunAnimation: View {
    @Binding var rotation: Double
    
    var body: some View {
        Image(systemName: "sun.max.fill")
            .font(.system(size: 100))
            .foregroundColor(.yellow.opacity(0.3))
            .rotationEffect(.degrees(rotation))
            .animation(.linear(duration: 20.0).repeatForever(autoreverses: false), value: rotation)
    }
}

struct WeatherDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.title3)
                .bold()
        }
    }
}

#Preview {
    DetailedWeatherView(weather: Weather.mock())
} 
