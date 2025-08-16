import SwiftUI
import Charts

struct ItineraryView: View {
    let trip: Trip
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with trip info
                tripHeaderView
                
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Itinerary").tag(1)
                    Text("Budget").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    OverviewTabView(trip: trip)
                        .tag(0)
                    
                    ItineraryTabView(trip: trip)
                        .tag(1)
                    
                    BudgetTabView(trip: trip)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Trip Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Implement save functionality
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var tripHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(trip.numberOfTravelers) \(trip.numberOfTravelers == 1 ? "traveler" : "travelers")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                WeatherAdvisabilityBadge(advisability: trip.weatherAdvisability)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(daysBetween(trip.startDate, trip.endDate)) days")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(Int(trip.budget))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Destinations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(trip.destinations.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
}

struct WeatherAdvisabilityBadge: View {
    let advisability: WeatherAdvisability
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(badgeColor)
                .frame(width: 8, height: 8)
            
            Text(advisability.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var badgeColor: Color {
        switch advisability {
        case .recommended:
            return .green
        case .caution:
            return .orange
        case .notAdvisable:
            return .red
        case .unknown:
            return .gray
        }
    }
}

struct OverviewTabView: View {
    let trip: Trip
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Route map placeholder
                routeMapSection
                
                // Quick stats
                quickStatsSection
                
                // Destinations list
                destinationsSection
                
                // Weather advisory
                weatherAdvisorySection
            }
            .padding()
        }
    }
    
    private var routeMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Route Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "map")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Map integration coming soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            StatCard(title: "Total Distance", value: "~500 km", icon: "road.lanes")
            StatCard(title: "Travel Time", value: "~8 hours", icon: "clock")
            StatCard(title: "Estimated Cost", value: "₹\(Int(trip.totalCost))", icon: "indianrupeesign.circle")
        }
    }
    
    private var destinationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Destinations")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(Array(trip.destinations.enumerated()), id: \.offset) { index, destination in
                    DestinationOverviewCard(destination: destination, order: index + 1)
                }
            }
        }
    }
    
    private var weatherAdvisorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather Advisory")
                .font(.headline)
                .fontWeight(.semibold)
            
            WeatherAdvisoryCard(advisability: trip.weatherAdvisability)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.saffron)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct DestinationOverviewCard: View {
    let destination: Destination
    let order: Int
    
    var body: some View {
        HStack {
            Text("\(order)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.saffron)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
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
            
            Text("1 day")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct WeatherAdvisoryCard: View {
    let advisability: WeatherAdvisability
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: weatherIcon)
                    .foregroundColor(advisabilityColor)
                
                Text(advisability.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            Text(weatherDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(advisabilityColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var weatherIcon: String {
        switch advisability {
        case .recommended:
            return "sun.max.fill"
        case .caution:
            return "cloud.sun.fill"
        case .notAdvisable:
            return "cloud.rain.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    private var advisabilityColor: Color {
        switch advisability {
        case .recommended:
            return .green
        case .caution:
            return .orange
        case .notAdvisable:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    private var weatherDescription: String {
        switch advisability {
        case .recommended:
            return "Weather conditions are favorable for travel. Good visibility and comfortable temperatures expected."
        case .caution:
            return "Some weather concerns. Monitor forecasts and be prepared for changing conditions."
        case .notAdvisable:
            return "Severe weather conditions expected. Consider postponing or rescheduling your trip."
        case .unknown:
            return "Weather data unavailable. Please check local forecasts before traveling."
        }
    }
}

struct ItineraryTabView: View {
    let trip: Trip
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let itinerary = trip.itinerary {
                    ForEach(itinerary.days, id: \.id) { day in
                        DayPlanCard(day: day)
                    }
                } else {
                    Text("Itinerary not available")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

struct DayPlanCard: View {
    let day: DayPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Day \(day.dayNumber)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(day.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if day.activities.isEmpty {
                Text("Activities will be planned based on your destinations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(spacing: 8) {
                    ForEach(day.activities, id: \.id) { activity in
                        ActivityRow(activity: activity)
                    }
                }
            }
            
            HStack {
                Text("Estimated cost: ₹\(Int(day.totalCost))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.iconName)
                .foregroundColor(.saffron)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(activity.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("₹\(Int(activity.cost))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct BudgetTabView: View {
    let trip: Trip
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Budget overview
                budgetOverviewSection
                
                // Budget breakdown chart
                if let itinerary = trip.itinerary {
                    budgetChartSection(itinerary.costBreakdown)
                }
                
                // Cost optimization suggestions
                costOptimizationSection
            }
            .padding()
        }
    }
    
    private var budgetOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Budget")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(Int(trip.budget))")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Estimated Cost")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(Int(trip.totalCost))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(trip.totalCost <= trip.budget ? .green : .red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private func budgetChartSection(_ breakdown: CostBreakdown) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                BudgetBreakdownRow(category: "Travel", amount: breakdown.travel, percentage: breakdown.travelPercentage, color: .blue)
                BudgetBreakdownRow(category: "Accommodation", amount: breakdown.accommodation, percentage: breakdown.accommodationPercentage, color: .green)
                BudgetBreakdownRow(category: "Food", amount: breakdown.food, percentage: breakdown.foodPercentage, color: .orange)
                BudgetBreakdownRow(category: "Activities", amount: breakdown.activities, percentage: breakdown.activitiesPercentage, color: .purple)
                BudgetBreakdownRow(category: "Miscellaneous", amount: breakdown.miscellaneous, percentage: breakdown.miscellaneousPercentage, color: .gray)
            }
        }
    }
    
    private var costOptimizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cost Optimization Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                OptimizationTipCard(
                    icon: "train.side.front.car",
                    title: "Consider Train Travel",
                    description: "Train travel can be 40-60% cheaper than flights for most routes"
                )
                
                OptimizationTipCard(
                    icon: "building.2",
                    title: "Stay in Dharamshalas",
                    description: "Many temples offer free or low-cost accommodation for pilgrims"
                )
                
                OptimizationTipCard(
                    icon: "calendar",
                    title: "Travel Off-Season",
                    description: "Avoid peak seasons and festivals for better rates"
                )
            }
        }
    }
}

struct BudgetBreakdownRow: View {
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                    
                    Text(category)
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₹\(Int(amount))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(Int(percentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: percentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
    }
}

struct OptimizationTipCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.saffron)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    let sampleTrip = Trip(
        name: "Golden Triangle Pilgrimage",
        budget: 25000,
        numberOfTravelers: 2,
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
        startLocation: Location(name: "Delhi", coordinate: .init(latitude: 28.6139, longitude: 77.2090)),
        destinations: [
            Destination(location: Location(name: "Golden Temple", coordinate: .init(latitude: 31.6200, longitude: 74.8765))),
            Destination(location: Location(name: "Vaishno Devi", coordinate: .init(latitude: 32.9916, longitude: 74.9500)))
        ],
        travelMode: .train,
        accommodationType: .budget
    )
    
    ItineraryView(trip: sampleTrip)
}