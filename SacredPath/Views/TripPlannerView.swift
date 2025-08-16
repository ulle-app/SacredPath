import SwiftUI

struct TripPlannerView: View {
    @EnvironmentObject var viewModel: TripPlannerViewModel
    @EnvironmentObject var locationService: LocationService
    @State private var showingDestinationSearch = false
    @State private var destinationSearchText = ""
    @State private var showingItinerary = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Budget Section
                    budgetSection
                    
                    // Travelers Section
                    travelersSection
                    
                    // Dates Section
                    datesSection
                    
                    // Start Location Section
                    startLocationSection
                    
                    // Destinations Section
                    destinationsSection
                    
                    // Travel Preferences Section
                    travelPreferencesSection
                    
                    // Generate Trip Button
                    generateTripButton
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Plan Your Trip")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDestinationSearch) {
                DestinationSearchView(
                    searchText: $destinationSearchText,
                    onDestinationSelected: { placeResult in
                        viewModel.addDestination(placeResult)
                        showingDestinationSearch = false
                        destinationSearchText = ""
                    }
                )
                .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingItinerary) {
                if let trip = viewModel.currentTrip {
                    ItineraryView(trip: trip)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: viewModel.currentTrip) { trip in
                if trip != nil {
                    showingItinerary = true
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "map.fill")
                .font(.system(size: 50))
                .foregroundColor(.saffron)
            
            Text("Plan Your Sacred Journey")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Tell us your preferences and we'll create the perfect pilgrimage itinerary for you")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var budgetSection: some View {
        FormSectionView(title: "Budget", icon: "indianrupeesign.circle") {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Enter your total budget", text: $viewModel.budgetText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("This includes travel, accommodation, food, and activities")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var travelersSection: some View {
        FormSectionView(title: "Travelers", icon: "person.2") {
            Stepper(value: $viewModel.numberOfTravelers, in: 1...20) {
                Text("\(viewModel.numberOfTravelers) \(viewModel.numberOfTravelers == 1 ? "person" : "people")")
            }
        }
    }
    
    private var datesSection: some View {
        FormSectionView(title: "Travel Dates", icon: "calendar") {
            VStack(spacing: 12) {
                DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                
                DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }
        }
    }
    
    private var startLocationSection: some View {
        FormSectionView(title: "Starting Point", icon: "location") {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Enter your starting location", text: $viewModel.startLocationText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: useCurrentLocation) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Use Current Location")
                    }
                    .font(.subheadline)
                    .foregroundColor(.saffron)
                }
            }
        }
    }
    
    private var destinationsSection: some View {
        FormSectionView(title: "Destinations", icon: "building.2") {
            VStack(spacing: 12) {
                // Selected destinations
                ForEach(Array(viewModel.selectedDestinations.enumerated()), id: \.offset) { index, destination in
                    DestinationRow(
                        destination: destination,
                        onRemove: {
                            viewModel.removeDestination(at: index)
                        }
                    )
                }
                
                // Add destination button
                Button(action: {
                    showingDestinationSearch = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Destination")
                    }
                    .font(.subheadline)
                    .foregroundColor(.saffron)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.saffron.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var travelPreferencesSection: some View {
        FormSectionView(title: "Travel Preferences", icon: "car") {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Travel Mode")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Travel Mode", selection: $viewModel.selectedTravelMode) {
                        ForEach(Trip.TravelMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Accommodation Type")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Accommodation", selection: $viewModel.selectedAccommodationType) {
                        ForEach(Trip.AccommodationType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
    }
    
    private var generateTripButton: some View {
        Button(action: {
            viewModel.createTrip()
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "sparkles")
                }
                
                Text(viewModel.isLoading ? "Generating..." : "Generate Trip")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(viewModel.isValidForm && !viewModel.isLoading ? Color.saffron : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!viewModel.isValidForm || viewModel.isLoading)
    }
    
    private func useCurrentLocation() {
        locationService.getCurrentLocation { location in
            if let location = location {
                DispatchQueue.main.async {
                    viewModel.startLocationText = "Current Location"
                }
            }
        }
    }
}

struct FormSectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.saffron)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct DestinationRow: View {
    let destination: Destination
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(destination.location.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let address = destination.location.address {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct DestinationSearchView: View {
    @Binding var searchText: String
    @EnvironmentObject var viewModel: TripPlannerViewModel
    @Environment(\.dismiss) private var dismiss
    let onDestinationSelected: (PlaceResult) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: {
                    viewModel.searchDestinations(query: searchText)
                })
                
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty && !searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try searching for temples, mosques, or holy sites")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.searchResults, id: \.placeId) { result in
                        Button(action: {
                            onDestinationSelected(result)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if let address = result.formattedAddress {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .navigationTitle("Search Destinations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search temples, holy sites...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            Button("Search", action: onSearchButtonClicked)
                .disabled(text.isEmpty)
        }
        .padding()
    }
}

#Preview {
    TripPlannerView()
        .environmentObject(TripPlannerViewModel())
        .environmentObject(LocationService.shared)
}