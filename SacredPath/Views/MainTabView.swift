import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            TripPlannerView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Plan Trip")
                }
                .tag(1)
            
            MyTripsView()
                .tabItem {
                    Image(systemName: "suitcase.fill")
                    Text("My Trips")
                }
                .tag(2)
            
            ExploreView()
                .tabItem {
                    Image(systemName: "compass.drawing")
                    Text("Explore")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.saffron)
    }
}

// Placeholder views for now
struct HomeView: View {
    @EnvironmentObject var tripPlannerViewModel: TripPlannerViewModel
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero section
                    VStack(spacing: 16) {
                        Image(systemName: "hands.and.sparkles.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.saffron)
                        
                        Text("Welcome to SacredPath")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Plan your perfect pilgrimage with intelligent route optimization and budget management")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Quick action buttons
                    VStack(spacing: 12) {
                        NavigationLink(destination: TripPlannerView()) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Plan New Trip")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.saffron)
                            .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: ExploreView()) {
                            HStack {
                                Image(systemName: "compass.drawing")
                                    .font(.title2)
                                Text("Explore Holy Sites")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.deepBlue)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Featured destinations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Popular Destinations")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(featuredDestinations, id: \.name) { destination in
                                    DestinationCard(destination: destination)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private let featuredDestinations = [
        FeaturedDestination(name: "Golden Temple", location: "Amritsar", imageName: "building.2.fill", religion: "Sikhism"),
        FeaturedDestination(name: "Vaishno Devi", location: "Jammu", imageName: "mountain.2.fill", religion: "Hinduism"),
        FeaturedDestination(name: "Tirupati", location: "Andhra Pradesh", imageName: "building.columns.fill", religion: "Hinduism"),
        FeaturedDestination(name: "Ajmer Sharif", location: "Rajasthan", imageName: "moon.stars.fill", religion: "Islam")
    ]
}

struct DestinationCard: View {
    let destination: FeaturedDestination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: destination.imageName)
                .font(.system(size: 40))
                .foregroundColor(.saffron)
                .frame(width: 150, height: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(destination.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(destination.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(destination.religion)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.saffron.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .frame(width: 150)
    }
}

struct FeaturedDestination {
    let name: String
    let location: String
    let imageName: String
    let religion: String
}

struct MyTripsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "suitcase")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("No trips yet")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Start planning your first pilgrimage")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: TripPlannerView()) {
                    Text("Plan Your First Trip")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.saffron)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .navigationTitle("My Trips")
        }
    }
}

struct ExploreView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(sampleHolySites, id: \.name) { site in
                        HolySiteCard(site: site)
                    }
                }
                .padding()
            }
            .navigationTitle("Explore")
        }
    }
    
    private let sampleHolySites = [
        SampleHolySite(name: "Golden Temple", location: "Amritsar, Punjab", description: "The holiest Sikh shrine, known for its golden dome and spiritual significance.", religion: "Sikhism"),
        SampleHolySite(name: "Vaishno Devi", location: "Jammu & Kashmir", description: "Sacred Hindu temple dedicated to Goddess Vaishno Devi, located in the Trikuta Mountains.", religion: "Hinduism"),
        SampleHolySite(name: "Tirupati Balaji", location: "Tirupati, Andhra Pradesh", description: "One of the richest temples in the world, dedicated to Lord Venkateswara.", religion: "Hinduism"),
        SampleHolySite(name: "Ajmer Sharif", location: "Ajmer, Rajasthan", description: "Shrine of the Sufi saint Moinuddin Chishti, visited by people of all faiths.", religion: "Islam")
    ]
}

struct HolySiteCard: View {
    let site: SampleHolySite
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(site.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(site.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(site.religion)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.saffron.opacity(0.2))
                    .cornerRadius(6)
            }
            
            Text(site.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct SampleHolySite {
    let name: String
    let location: String
    let description: String
    let religion: String
}

struct ProfileView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.saffron)
                        
                        VStack(alignment: .leading) {
                            Text("Pilgrim")
                                .font(.headline)
                            Text("Welcome to SacredPath")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Preferences") {
                    HStack {
                        Image(systemName: "globe")
                        Text("Language")
                        Spacer()
                        Text(getLanguageName(selectedLanguage))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                        Text("Location Services")
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Support") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Help & FAQ")
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                        Text("Contact Us")
                    }
                    
                    HStack {
                        Image(systemName: "star")
                        Text("Rate App")
                    }
                }
                
                Section {
                    Button(action: {
                        hasCompletedOnboarding = false
                    }) {
                        Text("Reset Onboarding")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    private func getLanguageName(_ code: String) -> String {
        let languages = [
            "en": "English",
            "hi": "हिन्दी",
            "ta": "தமிழ்",
            "te": "తెలుగు",
            "bn": "বাংলা",
            "mr": "मराठी",
            "gu": "ગુજરાતી",
            "kn": "ಕನ್ನಡ",
            "ml": "മലയാളം",
            "pa": "ਪੰਜਾਬੀ"
        ]
        return languages[code] ?? "English"
    }
}

#Preview {
    MainTabView()
        .environmentObject(TripPlannerViewModel())
        .environmentObject(LocationService.shared)
}