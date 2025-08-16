# SacredPath India iOS App

A budget-conscious pilgrimage planning app for iOS that helps users plan journeys to holy sites across India with route optimization, weather advisories, and comprehensive budget management.

## Overview

SacredPath India is a SwiftUI-based iOS application that integrates:
- Google Maps API for route optimization
- Weather APIs for travel advisability
- Budget planning and breakdown
- Multi-language support (22 Indian languages)
- Offline mode for remote areas
- Booking integrations with major travel platforms

## Features (MVP)

### Core Features
- **Route Optimization**: Google Maps integration for shortest travel routes
- **Budget Planning**: Comprehensive budget breakdown (travel/stay/food)
- **Weather Advisability**: AI-driven travel recommendations based on weather conditions
- **Itinerary Generation**: Day-by-day travel plans with accommodations and meals
- **Destination Profiles**: Holy site information with images and spiritual significance
- **Multi-language Support**: Full localization for Indian languages

### Technical Features
- **Offline Mode**: Cached maps and itineraries for poor connectivity areas
- **Booking Integration**: Deep links to IRCTC, RedBus, MakeMyTrip, OYO
- **Push Notifications**: Trip reminders and weather alerts
- **User Authentication**: Sign in with Apple/Google

## Tech Stack

- **Platform**: iOS 17+ 
- **Framework**: SwiftUI
- **Architecture**: MVVM
- **Database**: Firebase Firestore
- **Maps**: Google Maps SDK
- **Weather**: OpenWeatherMap API
- **Authentication**: Firebase Auth
- **Notifications**: Firebase Cloud Messaging

## Project Structure

```
SacredPath/
├── SacredPath/              # Main app code
│   ├── Views/              # SwiftUI views
│   ├── ViewModels/         # MVVM view models
│   ├── Models/             # Data models
│   ├── Services/           # API services
│   ├── Utils/              # Utility classes
│   └── Resources/          # Assets, localizations
├── SacredPathTests/         # Unit tests
└── SacredPathUITests/       # UI tests
```

## Development Workflow

### Branching Strategy
- `main` - Production ready code
- `dev` - Development branch (default for features)
- `qa` - Quality assurance testing
- `prod` - Production deployment

### Feature Development
1. Create feature branch from `dev`
2. Implement feature with tests
3. Merge to `dev` for integration
4. Move to `qa` for testing
5. Deploy to `prod` after QA approval

## Setup Instructions

### Prerequisites
- Xcode 15+
- iOS 17+ deployment target
- Apple Developer Account
- Google Maps API key
- OpenWeatherMap API key

### Installation
1. Clone the repository
2. Open `SacredPath.xcodeproj` in Xcode
3. Configure API keys in `Config.plist`
4. Build and run on simulator or device

## Recent Updates

**August 16, 2025**: 
- ✅ Project structure and repository setup completed
- ✅ Xcode project created with SwiftUI and Core Data
- 🔄 Currently setting up app architecture and dependencies

## Contributing

1. Create feature branch from `dev`
2. Follow SwiftUI and iOS coding standards
3. Add unit tests for new functionality
4. Update documentation as needed
5. Submit pull request to `dev` branch

---

**Last Updated**: August 16, 2025  
**Version**: 1.0 MVP  
**Team**: Prajñā saḍaka  