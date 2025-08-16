import Foundation
import CoreLocation

struct Trip: Identifiable, Codable {
    let id = UUID()
    var name: String
    var budget: Double
    var numberOfTravelers: Int
    var startDate: Date
    var endDate: Date
    var startLocation: Location
    var destinations: [Destination]
    var travelMode: TravelMode
    var accommodationType: AccommodationType
    var itinerary: Itinerary?
    var totalCost: Double = 0.0
    var weatherAdvisability: WeatherAdvisability = .unknown
    
    enum TravelMode: String, CaseIterable, Codable {
        case train = "train"
        case bus = "bus"
        case car = "car"
        case flight = "flight"
        case mixed = "mixed"
        
        var displayName: String {
            switch self {
            case .train: return "Train"
            case .bus: return "Bus"
            case .car: return "Car"
            case .flight: return "Flight"
            case .mixed: return "Mixed"
            }
        }
    }
    
    enum AccommodationType: String, CaseIterable, Codable {
        case budget = "budget"
        case dharamshala = "dharamshala"
        case midRange = "mid_range"
        case luxury = "luxury"
        
        var displayName: String {
            switch self {
            case .budget: return "Budget Hotel"
            case .dharamshala: return "Dharamshala"
            case .midRange: return "Mid-range Hotel"
            case .luxury: return "Luxury Hotel"
            }
        }
    }
}

struct Location: Identifiable, Codable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var address: String?
    
    enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D, address: String? = nil) {
        self.name = name
        self.coordinate = coordinate
        self.address = address
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}

struct Destination: Identifiable, Codable {
    let id = UUID()
    var location: Location
    var holysite: HolySite?
    var plannedDuration: TimeInterval
    var visitingOrder: Int
    
    init(location: Location, holysite: HolySite? = nil, plannedDuration: TimeInterval = 86400, visitingOrder: Int = 0) {
        self.location = location
        self.holysite = holysite
        self.plannedDuration = plannedDuration
        self.visitingOrder = visitingOrder
    }
}

enum WeatherAdvisability: String, Codable, CaseIterable {
    case recommended = "recommended"
    case caution = "caution"
    case notAdvisable = "not_advisable"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .recommended: return "Recommended to go"
        case .caution: return "Proceed with caution"
        case .notAdvisable: return "Not advisable"
        case .unknown: return "Weather data unavailable"
        }
    }
    
    var color: String {
        switch self {
        case .recommended: return "green"
        case .caution: return "yellow"
        case .notAdvisable: return "red"
        case .unknown: return "gray"
        }
    }
}