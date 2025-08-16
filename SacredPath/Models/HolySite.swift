import Foundation
import CoreLocation

struct HolySite: Identifiable, Codable, Equatable {
    let id = UUID()
    var name: String
    var description: String
    var significance: String
    var location: Location
    var religion: Religion
    var images: [String] // URLs to images
    var entryFee: Double?
    var timings: [DayTiming]
    var bestTimeToVisit: [String] // Months
    var facilities: [String]
    var nearbyAttractions: [String]
    var contactInfo: ContactInfo?
    var rating: Double?
    var reviewCount: Int?
    
    enum Religion: String, CaseIterable, Codable {
        case hinduism = "hinduism"
        case islam = "islam"
        case sikhism = "sikhism"
        case buddhism = "buddhism"
        case jainism = "jainism"
        case christianity = "christianity"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .hinduism: return "Hinduism"
            case .islam: return "Islam"
            case .sikhism: return "Sikhism"
            case .buddhism: return "Buddhism"
            case .jainism: return "Jainism"
            case .christianity: return "Christianity"
            case .other: return "Other"
            }
        }
        
        var iconName: String {
            switch self {
            case .hinduism: return "om.fill"
            case .islam: return "moon.stars.fill"
            case .sikhism: return "star.circle.fill"
            case .buddhism: return "leaf.fill"
            case .jainism: return "circle.fill"
            case .christianity: return "cross.fill"
            case .other: return "building.2.fill"
            }
        }
    }
}

struct DayTiming: Identifiable, Codable, Equatable {
    let id = UUID()
    var day: String // e.g., "Monday", "Tuesday", "Daily"
    var openTime: String // e.g., "5:00 AM"
    var closeTime: String // e.g., "10:00 PM"
    var specialNotes: String? // e.g., "Aarti at 7 PM"
    
    init(day: String, openTime: String, closeTime: String, specialNotes: String? = nil) {
        self.day = day
        self.openTime = openTime
        self.closeTime = closeTime
        self.specialNotes = specialNotes
    }
}

struct ContactInfo: Codable, Equatable {
    var phoneNumber: String?
    var email: String?
    var website: String?
    var address: String?
}