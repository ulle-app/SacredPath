import Foundation
import CoreLocation
import Combine

@MainActor
class TripPlannerViewModel: ObservableObject {
    @Published var currentTrip: Trip?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchResults: [PlaceResult] = []
    @Published var weatherAdvisability: WeatherAdvisability = .unknown
    
    // Form inputs
    @Published var budgetText = ""
    @Published var numberOfTravelers = 1
    @Published var startDate = Date()
    @Published var endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @Published var selectedTravelMode: Trip.TravelMode = .train
    @Published var selectedAccommodationType: Trip.AccommodationType = .budget
    @Published var startLocationText = ""
    @Published var selectedDestinations: [Destination] = []
    
    private let googleMapsService = GoogleMapsService.shared
    private let weatherService = WeatherService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var budget: Double {
        Double(budgetText) ?? 0
    }
    
    var isValidForm: Bool {
        !budgetText.isEmpty &&
        budget > 0 &&
        numberOfTravelers > 0 &&
        !startLocationText.isEmpty &&
        !selectedDestinations.isEmpty &&
        startDate <= endDate
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Auto-update end date when start date changes
        $startDate
            .sink { [weak self] newStartDate in
                guard let self = self else { return }
                if self.endDate <= newStartDate {
                    self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: newStartDate) ?? newStartDate
                }
            }
            .store(in: &cancellables)
    }
    
    func searchDestinations(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        googleMapsService.searchPlaces(query: "\(query) temple pilgrimage India")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.searchResults = response.results
                }
            )
            .store(in: &cancellables)
    }
    
    func addDestination(_ placeResult: PlaceResult) {
        let location = Location(
            name: placeResult.name,
            coordinate: CLLocationCoordinate2D(
                latitude: placeResult.geometry.location.lat,
                longitude: placeResult.geometry.location.lng
            ),
            address: placeResult.formattedAddress
        )
        
        let destination = Destination(
            location: location,
            visitingOrder: selectedDestinations.count
        )
        
        selectedDestinations.append(destination)
        searchResults = []
    }
    
    func removeDestination(at index: Int) {
        guard index < selectedDestinations.count else { return }
        selectedDestinations.remove(at: index)
        
        // Update visiting order
        for i in 0..<selectedDestinations.count {
            selectedDestinations[i].visitingOrder = i
        }
    }
    
    func createTrip() {
        guard isValidForm else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Get start location coordinate
        getCurrentLocationForStartLocation { [weak self] startLocation in
            guard let self = self, let startLocation = startLocation else {
                self?.isLoading = false
                self?.errorMessage = "Could not determine start location"
                return
            }
            
            let trip = Trip(
                name: "Pilgrimage to \(self.selectedDestinations.first?.location.name ?? "Sacred Places")",
                budget: self.budget,
                numberOfTravelers: self.numberOfTravelers,
                startDate: self.startDate,
                endDate: self.endDate,
                startLocation: startLocation,
                destinations: self.selectedDestinations,
                travelMode: self.selectedTravelMode,
                accommodationType: self.selectedAccommodationType
            )
            
            self.currentTrip = trip
            self.generateItinerary(for: trip)
        }
    }
    
    private func getCurrentLocationForStartLocation(completion: @escaping (Location?) -> Void) {
        if startLocationText.lowercased().contains("current") || startLocationText.lowercased().contains("my location") {
            locationService.getCurrentLocation { location in
                guard let location = location else {
                    completion(nil)
                    return
                }
                
                let startLocation = Location(
                    name: "Current Location",
                    coordinate: location.coordinate
                )
                completion(startLocation)
            }
        } else {
            // Search for the location
            googleMapsService.searchPlaces(query: startLocationText)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { response in
                        guard let firstResult = response.results.first else {
                            completion(nil)
                            return
                        }
                        
                        let startLocation = Location(
                            name: firstResult.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: firstResult.geometry.location.lat,
                                longitude: firstResult.geometry.location.lng
                            ),
                            address: firstResult.formattedAddress
                        )
                        completion(startLocation)
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    private func generateItinerary(for trip: Trip) {
        // Get optimized route
        let destinations = trip.destinations.map { $0.location.coordinate }
        
        googleMapsService.getDirections(
            from: trip.startLocation.coordinate,
            to: trip.destinations.last?.location.coordinate ?? trip.startLocation.coordinate,
            waypoints: Array(destinations.dropLast()),
            travelMode: trip.travelMode,
            optimizeWaypoints: true
        )
        .flatMap { [weak self] directionsResponse -> AnyPublisher<WeatherAdvisability, NetworkService.NetworkError> in
            guard let self = self else {
                return Just(.unknown).setFailureType(to: NetworkService.NetworkError.self).eraseToAnyPublisher()
            }
            
            // Check weather advisability
            let allCoordinates = [trip.startLocation.coordinate] + destinations
            let dateRange = DateInterval(start: trip.startDate, end: trip.endDate)
            
            return self.weatherService.analyzeWeatherAdvisability(for: allCoordinates, during: dateRange)
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to generate itinerary: \(error.localizedDescription)"
                }
            },
            receiveValue: { [weak self] advisability in
                self?.weatherAdvisability = advisability
                self?.updateTripWithWeatherAdvisability(advisability)
            }
        )
        .store(in: &cancellables)
    }
    
    private func updateTripWithWeatherAdvisability(_ advisability: WeatherAdvisability) {
        currentTrip?.weatherAdvisability = advisability
        
        // Here you would also generate the detailed itinerary
        // For now, we'll create a basic structure
        generateBasicItinerary()
    }
    
    private func generateBasicItinerary() {
        guard var trip = currentTrip else { return }
        
        let numberOfDays = Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 1
        var days: [DayPlan] = []
        
        for dayNumber in 1...numberOfDays {
            let date = Calendar.current.date(byAdding: .day, value: dayNumber - 1, to: trip.startDate) ?? trip.startDate
            
            // Create basic day plan
            let dayPlan = DayPlan(
                dayNumber: dayNumber,
                date: date,
                activities: [],
                accommodation: nil,
                meals: [],
                transport: [],
                totalCost: trip.budget / Double(numberOfDays)
            )
            
            days.append(dayPlan)
        }
        
        let costBreakdown = CostBreakdown(
            travel: trip.budget * 0.4,
            accommodation: trip.budget * 0.3,
            food: trip.budget * 0.2,
            activities: trip.budget * 0.05,
            miscellaneous: trip.budget * 0.05
        )
        
        let itinerary = Itinerary(
            tripId: trip.id,
            days: days,
            totalDistance: 0,
            totalDuration: 0,
            costBreakdown: costBreakdown
        )
        
        trip.itinerary = itinerary
        trip.totalCost = costBreakdown.total
        
        currentTrip = trip
    }
    
    func resetForm() {
        budgetText = ""
        numberOfTravelers = 1
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        selectedTravelMode = .train
        selectedAccommodationType = .budget
        startLocationText = ""
        selectedDestinations = []
        currentTrip = nil
        weatherAdvisability = .unknown
        errorMessage = nil
        searchResults = []
    }
}