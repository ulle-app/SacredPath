import Foundation
import CoreLocation
import Combine

class GoogleMapsService {
    static let shared = GoogleMapsService()
    
    private let networkService = NetworkService.shared
    private let configService = ConfigurationService.shared
    private let baseURL = "https://maps.googleapis.com/maps/api"
    
    private init() {}
    
    // MARK: - Directions API
    
    func getDirections(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D] = [],
        travelMode: Trip.TravelMode = .car,
        optimizeWaypoints: Bool = true
    ) -> AnyPublisher<DirectionsResponse, NetworkService.NetworkError> {
        
        guard let apiKey = configService.googleMapsAPIKey else {
            return Fail(error: NetworkService.NetworkError.requestFailed("Google Maps API key not configured"))
                .eraseToAnyPublisher()
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/directions/json")!
        
        var queryItems = [
            URLQueryItem(name: "origin", value: "\(origin.latitude),\(origin.longitude)"),
            URLQueryItem(name: "destination", value: "\(destination.latitude),\(destination.longitude)"),
            URLQueryItem(name: "mode", value: googleTravelMode(from: travelMode)),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        if !waypoints.isEmpty {
            let waypointString = waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
            let waypointParam = optimizeWaypoints ? "optimize:true|\(waypointString)" : waypointString
            queryItems.append(URLQueryItem(name: "waypoints", value: waypointParam))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkService.NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return networkService.request(url: url, responseType: DirectionsResponse.self)
    }
    
    // MARK: - Places API
    
    func searchPlaces(
        query: String,
        location: CLLocationCoordinate2D? = nil,
        radius: Int = 50000
    ) -> AnyPublisher<PlacesSearchResponse, NetworkService.NetworkError> {
        
        guard let apiKey = configService.googleMapsAPIKey else {
            return Fail(error: NetworkService.NetworkError.requestFailed("Google Maps API key not configured"))
                .eraseToAnyPublisher()
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/place/textsearch/json")!
        
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        if let location = location {
            queryItems.append(URLQueryItem(name: "location", value: "\(location.latitude),\(location.longitude)"))
            queryItems.append(URLQueryItem(name: "radius", value: "\(radius)"))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkService.NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return networkService.request(url: url, responseType: PlacesSearchResponse.self)
    }
    
    func getPlaceDetails(placeId: String) -> AnyPublisher<PlaceDetailsResponse, NetworkService.NetworkError> {
        guard let apiKey = configService.googleMapsAPIKey else {
            return Fail(error: NetworkService.NetworkError.requestFailed("Google Maps API key not configured"))
                .eraseToAnyPublisher()
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/place/details/json")!
        urlComponents.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "fields", value: "name,formatted_address,geometry,photos,rating,reviews,opening_hours,formatted_phone_number,website"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkService.NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return networkService.request(url: url, responseType: PlaceDetailsResponse.self)
    }
    
    // MARK: - Helper Methods
    
    private func googleTravelMode(from travelMode: Trip.TravelMode) -> String {
        switch travelMode {
        case .car: return "driving"
        case .train, .bus: return "transit"
        case .flight: return "driving" // Use driving for flight planning between airports
        case .mixed: return "driving"
        }
    }
}

// MARK: - Response Models

struct DirectionsResponse: Codable {
    let routes: [Route]
    let status: String
}

struct Route: Codable {
    let legs: [Leg]
    let overviewPolyline: OverviewPolyline
    let summary: String
    let bounds: Bounds
    
    enum CodingKeys: String, CodingKey {
        case legs, summary, bounds
        case overviewPolyline = "overview_polyline"
    }
}

struct Leg: Codable {
    let distance: Distance
    let duration: Duration
    let startAddress: String
    let endAddress: String
    let startLocation: GoogleLatLng
    let endLocation: GoogleLatLng
    let steps: [Step]
    
    enum CodingKeys: String, CodingKey {
        case distance, duration, steps
        case startAddress = "start_address"
        case endAddress = "end_address"
        case startLocation = "start_location"
        case endLocation = "end_location"
    }
}

struct Step: Codable {
    let distance: Distance
    let duration: Duration
    let htmlInstructions: String
    let travelMode: String
    let startLocation: GoogleLatLng
    let endLocation: GoogleLatLng
    
    enum CodingKeys: String, CodingKey {
        case distance, duration
        case htmlInstructions = "html_instructions"
        case travelMode = "travel_mode"
        case startLocation = "start_location"
        case endLocation = "end_location"
    }
}

struct Distance: Codable {
    let text: String
    let value: Int // in meters
}

struct Duration: Codable {
    let text: String
    let value: Int // in seconds
}

struct GoogleLatLng: Codable {
    let lat: Double
    let lng: Double
}

struct OverviewPolyline: Codable {
    let points: String
}

struct Bounds: Codable {
    let northeast: GoogleLatLng
    let southwest: GoogleLatLng
}

// MARK: - Places API Models

struct PlacesSearchResponse: Codable {
    let results: [PlaceResult]
    let status: String
}

struct PlaceResult: Codable {
    let placeId: String
    let name: String
    let formattedAddress: String?
    let geometry: PlaceGeometry
    let rating: Double?
    let photos: [PlacePhoto]?
    let types: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, geometry, rating, photos, types
        case placeId = "place_id"
        case formattedAddress = "formatted_address"
    }
}

struct PlaceGeometry: Codable {
    let location: GoogleLatLng
}

struct PlacePhoto: Codable {
    let photoReference: String
    let width: Int
    let height: Int
    
    enum CodingKeys: String, CodingKey {
        case width, height
        case photoReference = "photo_reference"
    }
}

struct PlaceDetailsResponse: Codable {
    let result: PlaceDetails
    let status: String
}

struct PlaceDetails: Codable {
    let name: String
    let formattedAddress: String?
    let geometry: PlaceGeometry
    let photos: [PlacePhoto]?
    let rating: Double?
    let reviews: [PlaceReview]?
    let openingHours: OpeningHours?
    let formattedPhoneNumber: String?
    let website: String?
    
    enum CodingKeys: String, CodingKey {
        case name, geometry, photos, rating, reviews, website
        case formattedAddress = "formatted_address"
        case openingHours = "opening_hours"
        case formattedPhoneNumber = "formatted_phone_number"
    }
}

struct PlaceReview: Codable {
    let rating: Int
    let text: String
    let time: Int
    let authorName: String
    
    enum CodingKeys: String, CodingKey {
        case rating, text, time
        case authorName = "author_name"
    }
}

struct OpeningHours: Codable {
    let openNow: Bool
    let weekdayText: [String]
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
    }
}