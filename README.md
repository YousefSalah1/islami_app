# 🌙 Islami App

A beautiful, comprehensive, and scalable Islamic companion application built with **Flutter**. Islami App provides Muslims with an elegant and seamless digital experience to read the Holy Quran, explore Ahadith, track daily Azkar, listen to the Holy Quran Radio, and get accurate Prayer Times based on their location.

---

## ✨ Features

- **📖 Holy Quran:** Read the Holy Quran smoothly with beautiful typography and UI. It tracks your reading progress and surah indexing.
- **📜 Hadith Collection:** A collection of authentic Ahadith with a clean reading interface.
- **📿 Azkar (Sebha):** A smart digital Sebha with categorized daily Azkar (Morning, Evening, etc.) and a beautiful ring-progress animation.
- **📻 Live Radio:** Listen to the Holy Quran broadcasts live directly from the app.
- **🕌 Prayer Times:** Accurate prayer times based on the user's city/country, featuring next-prayer countdowns and caching for offline use.
- **🎨 Premium UI:** Custom-designed SVGs, beautiful per-tab backgrounds, and smooth animations.

---

## 🏗️ Architecture & State Management

This project is built using a **Highly Scalable, Layer-First Clean Architecture** to ensure maintainability, testability, and clear separation of concerns.

### 🧠 State Management
- **BLoC (Business Logic Component):** All features use the strict BLoC pattern with the **Contract Pattern** (Event & State classes are bundled into a unified `contract.dart` file).
- No legacy `Provider`, `Cubit`, or `Riverpod` are used.

### 💉 Dependency Injection
- **GetIt:** Used as the central Service Locator.
- The entire dependency graph (DataSources → Repositories → UseCases → BLoCs) is registered cleanly in `lib/di/injector.dart`.

### 📂 Folder Structure

The codebase is organized by **Features**, where each feature strictly follows the Clean Architecture layers:

```text
lib/
 ┣ core/              # Global constants, theme, colors, routing, errors, and utils
 ┣ data/              # Global raw data (e.g., local JSONs)
 ┣ di/                # Dependency Injection setup (injector.dart)
 ┗ features/
    ┣ quran/
    ┣ hadith/
    ┣ azkar/
    ┣ radio/
    ┣ times/
    ┗ onboarding/
```

Inside **every feature** (e.g., `times/`), the structure is:
```text
features/times/
 ┣ domain/
 ┃  ┣ entities/       # Pure Dart domain objects
 ┃  ┣ repository/     # Abstract repository contracts
 ┃  ┗ usecase/        # Business logic executors
 ┣ data/
 ┃  ┣ models/         # JSON serializable models (extends Entities)
 ┃  ┣ data_source/    # Remote/Local API calls
 ┃  ┗ repository/     # Repository implementations
 ┗ presentation/
    ┗ screens/        # UI and BLoC implementations
```
*Data Flow:* `Screen` ➔ `Bloc` ➔ `UseCase` ➔ `Repository (Interface)` ➔ `Repository (Impl)` ➔ `DataSource`

---

## 🛠️ Technologies & Packages Used

- **Flutter & Dart** (Latest SDK)
- **flutter_bloc:** For reactive state management.
- **get_it:** For Dependency Injection.
- **dio:** For handling REST API requests (e.g., AlAdhan Prayer Times API).
- **shared_preferences:** For local caching (Prayer Times, Location, Onboarding state).
- **flutter_svg:** For crisp and performant vector assets and icons.
- **audioplayers:** For Radio stream playback.
- **geolocator / geocoding:** For fetching location-based prayer times.

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

## 🎨 Design Assets

All UI vectors, backgrounds, and icons are custom-made and properly linked in `lib/core/utils/app_assets.dart`. Unused assets have been completely pruned for an optimized build size.

---

<p align="center">
  Built with ❤️ for the Muslim Community.
</p>
