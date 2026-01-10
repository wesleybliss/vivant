# Vivant

Vivant is a high-fidelity Point of Interest (POI) search and discovery application. It helps users find restaurants, bars, and establishments using fine-grained search filters powered by Google Maps and Places APIs, while allowing users to organize their discoveries into personalized lists.

## Features

- **POI Search**: Discover restaurants and bars with advanced filtering.
- **Interactive Maps**: Full Google Maps integration for visual discovery.
- **Personalized Lists**: Create and manage lists like "Want to go", "Favorites", or custom themed lists.
- **Cross-Platform**: Built with Flutter for Android and iOS.
- **Cloud Sync**: Seamless data synchronization using Convex and Firebase.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio or VS Code
- A Google Cloud Project with Maps and Places APIs enabled
- A Firebase Project for Authentication

### Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/vivant.git
    cd vivant
    ```

2.  **Environment Configuration**:
    Create a `.env` file in the root directory and add your API keys:
    ```
    GOOGLE_MAPS_API_KEY=your_api_key
    CONVEX_URL=your_convex_url
    ```

3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Run the Application**:
    ```bash
    flutter run
    ```

## Documentation

Comprehensive documentation is available in the [docs](./docs) directory:

- **[Technical Overview](./docs/technical_overview.md)**: Architecture, services, and data management.
- **[Setup Guide](./docs/setup.md)**: Detailed instructions for setting up the development environment.
- **[Maps API Setup](./docs/maps_api_setup.md)**: Instructions for configuring Google Maps and Places.
- **[Implementation Progress](./docs/progress.md)**: Current status of the project.
- **[Troubleshooting](./docs/troubleshooting/firebase_signin_fix.md)**: Solutions for common issues.

## Project Structure

```
lib/
├── models/         # Data models (User, ListModel, SavedPlace)
├── providers/      # State management (Auth, Lists, Settings)
├── screens/        # UI screens and navigation
├── services/       # External service integrations (Auth, Convex, Places)
└── utils/          # Utilities and loggers
```

## License

This project is private and intended for internal use only.
