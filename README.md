# 🌙 Islami App

A beautiful, comprehensive, and scalable Islamic companion application built with **Flutter**. Islami App provides Muslims with an elegant and seamless digital experience to read the Holy Quran, explore Ahadith, track daily Azkar, listen to the Holy Quran Radio, and get accurate Prayer Times based on their location.

---

## ✨ Core Features

- **🕌 Advanced Prayer Times:**
  - **GPS Integration:** Automatically detects the user's location via GPS (`geolocator` & `geocoding`) to fetch highly accurate prayer times from the AlAdhan API.
  - **City/Country Search:** Allows users to manually search for any city worldwide to get its prayer times.
  - **Dynamic Next-Prayer Countdown:** A real-time reactive timer calculating the exact hours, minutes, and seconds remaining until the next prayer.
  - **Offline Caching:** Uses `SharedPreferences` to cache the latest fetched prayer times so the app works flawlessly offline.
- **📻 Live Holy Quran Radio:** Features real-time audio streaming of the Holy Quran broadcast with reactive play/pause states using `audioplayers`.
- **📿 Smart Azkar (Sebha):** A deeply interactive digital Sebha with categorized daily Azkar (Morning, Evening, etc.) featuring complex ring-progress animations and haptic feedback.
- **📖 Holy Quran:** Read the Holy Quran smoothly with beautiful typography. Tracks your reading progress, surah indexing, and renders localized Arabic text perfectly.
- **📜 Hadith Collection:** A collection of authentic Ahadith with a clean reading interface and seamless navigation.

---

## 🏗️ Architecture & Advanced Technical Skills Demonstrated

This project is not just a UI showcase; it is engineered using Enterprise-Level architectural patterns to ensure maximum scalability, maintainability, and testability.

### 🧠 Layer-First Clean Architecture
The entire codebase strictly follows Clean Architecture principles, completely decoupling the UI from the business logic and data layers.
- **Domain Layer:** Pure Dart entities, use cases, and abstract repository contracts.
- **Data Layer:** API DataSources, JSON models, and concrete repository implementations.
- **Presentation Layer:** UI screens and BLoC state management.

### ⚙️ State Management (BLoC + Contract Pattern)
- Fully migrated away from legacy state management tools (like standard Providers) to the robust **BLoC (Business Logic Component)** pattern.
- Implements the **Contract Pattern**, where all Events and States for a specific feature are cleanly bundled into a unified `contract.dart` file.
- Ensures a strict, one-way data flow: `Screen` ➔ `Bloc` ➔ `UseCase` ➔ `Repository (Interface)` ➔ `Repository (Impl)` ➔ `DataSource`.

### 💉 Dependency Injection (GetIt)
- The entire dependency graph is centrally managed using **GetIt** (`lib/di/injector.dart`).
- DataSources, Repositories, UseCases, and BLoCs are injected seamlessly, completely preventing tight coupling between classes.

### 🧹 0-Error Static Analysis & Code Quality
- The project is heavily linted and deeply refactored to achieve **0 Errors and 0 Warnings** in `flutter analyze`.
- Dead code, unused assets, and duplicate imports have been aggressively pruned to optimize the build size and maintain a pristine codebase.

### 🎨 Premium & Responsive UI/UX
- **Unified Branding:** Custom SVG-based headers and dynamic routing across the app.
- **Responsive Layouts:** The app uses layout builders and constraints to ensure it looks gorgeous on any screen size.
- **Smooth Animations:** Integrated micro-animations, implicit animated containers, and elegant page transitions.

---

## 📂 Folder Structure

The codebase is organized by **Features**, adhering to a modular, feature-first approach:

```text
lib/
 ┣ core/              # Global constants, theme, colors, routing, errors, and utils
 ┣ data/              # Global raw data (e.g., local JSONs)
 ┣ di/                # Dependency Injection setup (injector.dart)
 ┗ features/
    ┣ quran/          # Quran reading and sura details
    ┣ hadith/         # Authentic Ahadith collection
    ┣ azkar/          # Categorized Azkar and animated Sebha
    ┣ radio/          # Audio streaming radio
    ┣ times/          # GPS, AlAdhan API, and countdown timer
    ┗ onboarding/     # First-launch welcome experience
```

---

## 🛠️ Technologies & Packages Used

- **Flutter & Dart** (Latest SDK)
- **flutter_bloc:** For reactive, predictable state management.
- **get_it:** For Dependency Injection.
- **dio:** For robust REST API networking (AlAdhan API).
- **shared_preferences:** For local offline caching of data and app state.
- **flutter_svg:** For crisp and performant vector assets (logos and icons).
- **audioplayers:** For Radio stream playback.
- **geolocator / geocoding:** For fetching and reversing GPS coordinates.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10.0 or higher recommended)
- Dart SDK
- Android Studio / VS Code

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/islami-app.git
   cd islami-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

---

<p align="center">
  Built with ❤️ for the Muslim Community, focusing on Code Quality and Clean Architecture.
</p>
