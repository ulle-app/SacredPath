import Foundation

struct Itinerary: Identifiable, Codable {
    let id = UUID()
    var tripId: UUID
    var days: [DayPlan]
    var totalDistance: Double // in kilometers
    var totalDuration: TimeInterval // in seconds
    var costBreakdown: CostBreakdown
    var route: RouteInfo?
    
    var numberOfDays: Int {
        days.count
    }
}

struct DayPlan: Identifiable, Codable {
    let id = UUID()
    var dayNumber: Int
    var date: Date
    var activities: [Activity]
    var accommodation: Accommodation?
    var meals: [Meal]
    var transport: [Transportation]
    var totalCost: Double
    var notes: String?
    
    var totalDuration: TimeInterval {
        activities.reduce(0) { $0 + $1.duration }
    }
}

struct Activity: Identifiable, Codable {
    let id = UUID()
    var type: ActivityType
    var title: String
    var description: String
    var startTime: Date
    var duration: TimeInterval
    var location: Location?
    var cost: Double
    var isOptional: Bool = false
    
    enum ActivityType: String, CaseIterable, Codable {
        case darshan = "darshan"
        case sightseeing = "sightseeing"
        case travel = "travel"
        case meal = "meal"
        case rest = "rest"
        case shopping = "shopping"
        case cultural = "cultural"
        
        var displayName: String {
            switch self {
            case .darshan: return "Darshan"
            case .sightseeing: return "Sightseeing"
            case .travel: return "Travel"
            case .meal: return "Meal"
            case .rest: return "Rest"
            case .shopping: return "Shopping"
            case .cultural: return "Cultural Event"
            }
        }
        
        var iconName: String {
            switch self {
            case .darshan: return "hands.and.sparkles.fill"
            case .sightseeing: return "camera.fill"
            case .travel: return "car.fill"
            case .meal: return "fork.knife"
            case .rest: return "bed.double.fill"
            case .shopping: return "bag.fill"
            case .cultural: return "theatermasks.fill"
            }
        }
    }
}

struct Accommodation: Identifiable, Codable {
    let id = UUID()
    var name: String
    var type: Trip.AccommodationType
    var location: Location
    var pricePerNight: Double
    var rating: Double?
    var amenities: [String]
    var bookingUrl: String?
    var contactInfo: ContactInfo?
    var checkInTime: String
    var checkOutTime: String
}

struct Meal: Identifiable, Codable {
    let id = UUID()
    var type: MealType
    var restaurantName: String?
    var cuisine: String
    var estimatedCost: Double
    var location: Location?
    var recommendedTime: String
    var isIncluded: Bool // Included in accommodation
    
    enum MealType: String, CaseIterable, Codable {
        case breakfast = "breakfast"
        case lunch = "lunch"
        case dinner = "dinner"
        case snacks = "snacks"
        
        var displayName: String {
            switch self {
            case .breakfast: return "Breakfast"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
            case .snacks: return "Snacks"
            }
        }
        
        var iconName: String {
            switch self {
            case .breakfast: return "cup.and.saucer.fill"
            case .lunch: return "fork.knife"
            case .dinner: return "wineglass.fill"
            case .snacks: return "leaf.fill"
            }
        }
    }
}

struct Transportation: Identifiable, Codable {
    let id = UUID()
    var mode: Trip.TravelMode
    var from: Location
    var to: Location
    var departureTime: Date
    var arrivalTime: Date
    var cost: Double
    var bookingReference: String?
    var bookingUrl: String?
    var provider: String? // e.g., "IRCTC", "RedBus"
    var seatInfo: String?
    
    var duration: TimeInterval {
        arrivalTime.timeIntervalSince(departureTime)
    }
    
    var distance: Double? // in kilometers
}

struct CostBreakdown: Codable {
    var travel: Double
    var accommodation: Double
    var food: Double
    var activities: Double
    var miscellaneous: Double
    
    var total: Double {
        travel + accommodation + food + activities + miscellaneous
    }
    
    var travelPercentage: Double {
        total > 0 ? (travel / total) * 100 : 0
    }
    
    var accommodationPercentage: Double {
        total > 0 ? (accommodation / total) * 100 : 0
    }
    
    var foodPercentage: Double {
        total > 0 ? (food / total) * 100 : 0
    }
    
    var activitiesPercentage: Double {
        total > 0 ? (activities / total) * 100 : 0
    }
    
    var miscellaneousPercentage: Double {
        total > 0 ? (miscellaneous / total) * 100 : 0
    }
}

struct RouteInfo: Codable {
    var waypoints: [Location]
    var totalDistance: Double // in kilometers
    var estimatedDuration: TimeInterval // in seconds
    var encodedPolyline: String?
    var alternativeRoutes: [AlternativeRoute]?
}

struct AlternativeRoute: Identifiable, Codable {
    let id = UUID()
    var name: String
    var distance: Double
    var duration: TimeInterval
    var costDifference: Double
    var encodedPolyline: String?
}