import Foundation

class ConfigurationService {
    static let shared = ConfigurationService()
    
    private var config: [String: Any] = [:]
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("Warning: Config.plist not found or invalid")
            return
        }
        config = plist
    }
    
    func getValue(for key: String) -> String? {
        return config[key] as? String
    }
    
    // API Keys
    var googleMapsAPIKey: String? {
        getValue(for: "GOOGLE_MAPS_API_KEY")
    }
    
    var openWeatherAPIKey: String? {
        getValue(for: "OPENWEATHER_API_KEY")
    }
    
    var firebaseAPIKey: String? {
        getValue(for: "FIREBASE_API_KEY")
    }
    
    var irctcAPIKey: String? {
        getValue(for: "IRCTC_API_KEY")
    }
    
    var redBusAPIKey: String? {
        getValue(for: "REDBUS_API_KEY")
    }
    
    var makeMyTripAPIKey: String? {
        getValue(for: "MAKEMYTRIP_API_KEY")
    }
    
    var oyoAPIKey: String? {
        getValue(for: "OYO_API_KEY")
    }
}