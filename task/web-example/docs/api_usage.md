# Vivant Gastronomy API Usage

This document provides information about the APIs used in the Vivant Gastronomy application.

## Google Maps and Places APIs

The application uses the Google Maps and Places APIs to provide the core search and map functionality. To use these APIs, you will need to obtain API keys from the Google Cloud Platform Console.

### APIs Used

- **Google Maps JavaScript API:** Used to display the interactive map.
- **Google Places API:** Used to search for points of interest.
- **Google Geocoding API:** Used to convert addresses into geographic coordinates.

### Setup

1.  **Create a new project** in the [Google Cloud Platform Console](https://console.cloud.google.com/).
2.  **Enable the following APIs** for your project:
    *   Maps JavaScript API
    *   Places API
    *   Geocoding API
3.  **Create API keys** for your project.
4.  **Add the API keys** to your environment variables. The application expects the following environment variable:
    *   `VITE_GOOGLE_MAPS_API_KEY`

## Convex API

The application uses the Convex platform for its backend services. You will need to create a Convex account and project to use the application.

### Setup

1.  **Create a new project** in the [Convex dashboard](https://dashboard.convex.dev/).
2.  **Install the Convex CLI** by running the following command:
    ```bash
    pnpm install -g convex
    ```
3.  **Initialize Convex** in your project by running the following command:
    ```bash
    npx convex init
    ```
4.  **Follow the instructions** to link your project to your Convex account.

## Clerk API

The application uses Clerk for user authentication. You will need to create a Clerk account and project to use the application.

### Setup

1.  **Create a new project** in the [Clerk dashboard](https://dashboard.clerk.dev/).
2.  **Follow the instructions** to configure your Clerk project.
3.  **Add the Clerk API keys** to your environment variables. The application expects the following environment variables:
    *   `VITE_CLERK_PUBLISHABLE_KEY`
    *   `CONVEX_SITE`
