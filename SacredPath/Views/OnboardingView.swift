import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to SacredPath",
            subtitle: "Your Sacred Journey, Perfectly Planned",
            description: "Plan budget-conscious pilgrimages to holy sites across India with intelligent route optimization and weather advisories.",
            imageName: "temple.golden",
            backgroundColor: Color.saffron
        ),
        OnboardingPage(
            title: "Smart Route Planning",
            subtitle: "Optimized Sacred Journeys",
            description: "Get the shortest routes between multiple destinations with real-time travel updates and cost optimization.",
            imageName: "map.fill",
            backgroundColor: Color.deepBlue
        ),
        OnboardingPage(
            title: "Weather-Aware Travel",
            subtitle: "Safe and Timely Visits",
            description: "AI-powered weather analysis helps you choose the best time to visit, avoiding monsoons, heat waves, and other risks.",
            imageName: "cloud.sun.rain.fill",
            backgroundColor: Color.earthyBrown
        ),
        OnboardingPage(
            title: "Budget Management",
            subtitle: "Affordable Pilgrimage Planning",
            description: "Comprehensive budget breakdown for travel, accommodation, and meals within your specified budget.",
            imageName: "indianrupeesign.circle.fill",
            backgroundColor: Color.saffron
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Page indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 50)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Language selection
                        LanguageSelectionView(selectedLanguage: $selectedLanguage)
                            .padding(.horizontal)
                        
                        Button(action: completeOnboarding) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.saffron)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal)
                    } else {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    currentPage = pages.count - 1
                                }
                            }) {
                                Text("Skip")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    currentPage += 1
                                }
                            }) {
                                HStack {
                                    Text("Next")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.saffron)
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [pages[currentPage].backgroundColor, pages[currentPage].backgroundColor.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }
    
    private func completeOnboarding() {
        withAnimation(.spring()) {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Image
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: String
    @State private var showingLanguagePicker = false
    
    private let languages = [
        ("en", "English", "🇺🇸"),
        ("hi", "हिन्दी", "🇮🇳"),
        ("ta", "தமிழ்", "🇮🇳"),
        ("te", "తెలుగు", "🇮🇳"),
        ("bn", "বাংলা", "🇮🇳"),
        ("mr", "मराठी", "🇮🇳"),
        ("gu", "ગુજરાતી", "🇮🇳"),
        ("kn", "ಕನ್ನಡ", "🇮🇳"),
        ("ml", "മലയാളം", "🇮🇳"),
        ("pa", "ਪੰਜਾਬੀ", "🇮🇳")
    ]
    
    private var selectedLanguageName: String {
        languages.first { $0.0 == selectedLanguage }?.1 ?? "English"
    }
    
    private var selectedLanguageFlag: String {
        languages.first { $0.0 == selectedLanguage }?.2 ?? "🇺🇸"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Language / भाषा चुनें")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Button(action: {
                showingLanguagePicker = true
            }) {
                HStack {
                    Text(selectedLanguageFlag)
                        .font(.title2)
                    
                    Text(selectedLanguageName)
                        .font(.body)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showingLanguagePicker) {
            LanguagePickerView(selectedLanguage: $selectedLanguage, languages: languages)
        }
    }
}

struct LanguagePickerView: View {
    @Binding var selectedLanguage: String
    @Environment(\.dismiss) private var dismiss
    let languages: [(String, String, String)]
    
    var body: some View {
        NavigationView {
            List(languages, id: \.0) { language in
                Button(action: {
                    selectedLanguage = language.0
                    dismiss()
                }) {
                    HStack {
                        Text(language.2)
                            .font(.title2)
                        
                        Text(language.1)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedLanguage == language.0 {
                            Image(systemName: "checkmark")
                                .foregroundColor(.saffron)
                        }
                    }
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

// Custom colors for the app theme
extension Color {
    static let saffron = Color(red: 1.0, green: 0.65, blue: 0.0)
    static let deepBlue = Color(red: 0.0, green: 0.2, blue: 0.4)
    static let earthyBrown = Color(red: 0.6, green: 0.4, blue: 0.2)
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}