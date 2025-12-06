# TravelMate

TravelMate is a comprehensive travel companion app for aggregating live flight and hotel deals. By integrating third-party APIs, the app provides a semaless travel planning experience, allowing users to store search results as favourites for bookmarking.

## Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Backend**: Firebase (Authentication)

## Features

#### Currency Selection
- select between USD, CAD, EUR, GBP, CNY, JPY
- currency state is persistent throughout the app on flight, hotel, and favourites screens.

#### Flight Search
- **Airport Autocomplete** - search and select origin and destination airports with fast and reliable real-time filtering.
- **Trip Types** - select and switch between round-trip or one-way flights
- **Date Picker** - select departure and return dates using the calendar
- **Passenger/Class Selection** - select the number of passenger and travel class (Economy, Business, Premium, First)
- **Flight Results** - view available flights with detailed information

#### Hotel Search
- **Hotel Autocomplete** - search for hotels in a selected city
- **Hotel Details** - view the hotel rating
- **Room Pricing** - view the lowest room prices

#### Intuitive Interface
- **Light/Dark Theme** - persistent, clean layout optimized for clarity and ease-of-use.
- **Bookmarks** - save and review a personalized list of flight and hotel results, with edit/delete functionality

#### Account Management
- **Authentication** - user signup is required for app usage
- **Account Settings** - users can change their password, logout, and delete their account from within the app.

#### Technical Features
- **Flight API**: AmadeusAPI (https://developers.amadeus.com/)
- **Hotel API**: LiteAPI (https://liteapi.travel/)
- **Currency API**: Fixer.io (https://fixer.io/)

## Bugs & Known Issues
- currently, there is a bug with the hotel details not being displayed correctly (all fields are null/unknown), but the hotels are still able to be saved to SavedScreen correctly.
- the thumbnails on HomeScreen were meant to route directly to HotelSearchScreen and prefill the city name, but that feature is not working as intended.

## AI Disclaimer
This project used Claude Sonnet 4.5 to generate two configuration files - more specifically `/themes/app_theme.dart` (provides the system theming for light and dark mode) and `filter_airports.py` (a Python script used for filtering down a large 12MB csv file into `airports.json`).
