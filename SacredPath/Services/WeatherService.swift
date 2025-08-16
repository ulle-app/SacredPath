import Foundation
import CoreLocation
import Combine

class WeatherService {
    static let shared = WeatherService()
    
    private let networkService = NetworkService.shared
    private let configService = ConfigurationService.shared
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    private init() {}
    
    func getCurrentWeather(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<WeatherResponse, NetworkService.NetworkError> {
        guard let apiKey = configService.openWeatherAPIKey else {
            return Fail(error: NetworkService.NetworkError.requestFailed("OpenWeather API key not configured"))
                .eraseToAnyPublisher()
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/weather")!
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "lon", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkService.NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return networkService.request(url: url, responseType: WeatherResponse.self)
    }
    
    func getForecast(for coordinate: CLLocationCoordinate2D, days: Int = 5) -> AnyPublisher<ForecastResponse, NetworkService.NetworkError> {
        guard let apiKey = configService.openWeatherAPIKey else {
            return Fail(error: NetworkService.NetworkError.requestFailed("OpenWeather API key not configured"))
                .eraseToAnyPublisher()
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/forecast")!
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "lon", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "cnt", value: "\(days * 8)") // 8 forecasts per day (3-hour intervals)
        ]
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkService.NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return networkService.request(url: url, responseType: ForecastResponse.self)
    }
    
    func analyzeWeatherAdvisability(
        for locations: [CLLocationCoordinate2D],
        during dateRange: DateInterval
    ) -> AnyPublisher<WeatherAdvisability, NetworkService.NetworkError> {
        
        let weatherPublishers = locations.map { coordinate in
            getForecast(for: coordinate, days: 5)
        }
        
        return Publishers.MergeMany(weatherPublishers)
            .collect()
            .map { forecasts in
                self.calculateAdvisability(from: forecasts, dateRange: dateRange)
            }
            .eraseToAnyPublisher()
    }
    
    private func calculateAdvisability(from forecasts: [ForecastResponse], dateRange: DateInterval) -> WeatherAdvisability {
        var riskScore = 0
        var totalForecasts = 0
        
        for forecast in forecasts {
            for item in forecast.list {
                let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
                
                if dateRange.contains(date) {
                    totalForecasts += 1
                    
                    // Check for extreme weather conditions
                    let temp = item.main.temp
                    let humidity = item.main.humidity
                    let windSpeed = item.wind?.speed ?? 0
                    let weatherMain = item.weather.first?.main ?? ""
                    
                    // Temperature risks
                    if temp > 40 || temp < 5 {
                        riskScore += 3
                    } else if temp > 35 || temp < 10 {
                        riskScore += 1
                    }
                    
                    // Weather condition risks
                    switch weatherMain.lowercased() {
                    case "thunderstorm", "tornado":
                        riskScore += 5
                    case "rain", "drizzle":
                        if let rain = item.rain?.the1H, rain > 10 {
                            riskScore += 3
                        } else {
                            riskScore += 1
                        }
                    case "snow":
                        riskScore += 4
                    case "mist", "fog":
                        riskScore += 1
                    default:
                        break
                    }
                    
                    // Wind risks
                    if windSpeed > 15 {
                        riskScore += 2
                    } else if windSpeed > 10 {
                        riskScore += 1
                    }
                    
                    // Humidity risks (for comfort)
                    if humidity > 85 {
                        riskScore += 1
                    }
                }
            }
        }
        
        guard totalForecasts > 0 else { return .unknown }
        
        let averageRisk = Double(riskScore) / Double(totalForecasts)
        
        switch averageRisk {
        case 0...1:
            return .recommended
        case 1.1...3:
            return .caution
        default:
            return .notAdvisable
        }
    }
}

// MARK: - Weather Models

struct WeatherResponse: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind?
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct ForecastResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind?
    let visibility: Int
    let pop: Double // Probability of precipitation
    let rain: Rain?
    let snow: Snow?
    let sys: ForecastSys
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain, snow, sys
        case dtTxt = "dt_txt"
    }
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int?
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int
}

struct Rain: Codable {
    let the1H: Double?
    let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
        case the3H = "3h"
    }
}

struct Snow: Codable {
    let the1H: Double?
    let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
        case the3H = "3h"
    }
}

struct Sys: Codable {
    let type: Int?
    let id: Int?
    let country: String
    let sunrise: Int
    let sunset: Int
}

struct ForecastSys: Codable {
    let pod: String
}

struct City: Codable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population: Int?
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}