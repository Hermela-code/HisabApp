# HisabApp
## Multi-Branch Stock & Sales Management System

**HisabApp** is an offline mobile business utility designed for retail owners and cashiers operating in environments with limited or unreliable internet connectivity. It replaces error-prone paper ledgers with a structured digital database, acting as a "digital bridge" between independent branches and a central owner.

---

## Project Overview

The primary goal of HisabApp is to automate complex business calculations—such as net profit, total income, and staff salaries—while eliminating the burden of manual paper-based recording. 

### Core Objectives:
* **For the Owner:** Minimize the hardship of managing diverse stock across multiple locations without constant physical supervision.
* **For the Cashier:** Simplify daily tasks through automatic stock subtraction and instant access to historical sales data.

---

## Team Members

| Full Name | ID | Section |
| :--- | :--- | :--- |
| **Abreham Yonatan** | [UGR/4463/16] | [1]|
| **Gelila Sintayehu** | [UGR/3508/16] |[2]|
| **Kidist Nega** | [UGR/1923/16] |[1]|
| **Nabon Amanuel** | [UGR/7416/16] |[1]|
| **Victory Bedru** | [UGR/4541/16] |[2]|

---

## Key Features

### Features-1. Dynamic Role-Based Onboarding & Schema Mapping
* **Unified Gateway:** Upon first launch, the app provides a landing page for users to identify as an **Owner** or **Cashier**. 
* **Questionnaire-Driven Configuration:** Users complete a "Business Definition" form (e.g., Electronics vs. Clothing). The app uses this input to dynamically generate labels and input fields for all future stock and sales forms.

### Features-2. Universal Inventory & Stock Management (CRUD)
* **Digital Stock Ledger:** Manage products with custom specifications defined during onboarding (e.g., Model, Size, Color).
* **Auto-Subtraction:** Real-time inventory updates as sales are recorded. The system prevents "ghost sales" by blocking transactions when stock reaches zero.
* **Inventory Alerts:** Dashboard notifications for **Low Stock** and **High Stock** levels.

### Features-3. Sales Recording & Personnel Management (CRUD)
* **Detailed Sales Capture:** Capture customer info (Name, Phone), product specs, and salesperson details for every transaction.
* **Performance Tracking:** Aggregated tables showing exactly how many units each staff member has sold to simplify salary and commission management.

### Features-4. Manual Data Synchronization (The "Digital Bridge")
* **Nightly Summary:** Generate a summarized daily report of sales including sales person report and remaining stock.
* **Asynchronous Transfer:** Since the app is 100% offline, the Cashier exports a **structured plain-text table** and shares it via Telegram or WhatsApp.
* **Owner Aggregation:** The Owner manually inputs this data into a "Smart Form" on their device to update global metrics.

### Features-5. Financial & Profit Intelligence
* **Net Profit Engine:** Automatically calculates branch-specific profit.
* **Private Financial Management:** A private section for Owners to log "Operational Costs" (Rent, Bulk Purchases, Salaries) that is strictly hidden from the Cashier.

---

## Role-Based Access Control (RBAC)

* **Owner Role:** Full administrative access. Owners can create/delete branch profiles, view global analytics, manage operational costs, and perform manual data syncs.
* **Cashier Role:** Restricted branch access. Cashiers are prohibited from seeing global company profit or data from other branches. Access is limited to local stock management and daily operational data.

---

## 🛠 Technical Specifications

* **Architecture:** Domain-Driven Design (DDD).
* **Backend:** Custom Local REST API (running on `localhost`); no Firebase or cloud services used.
* **Testing:** Comprehensive Unit, Widget, and Integration tests.

---

## How It Works: The Workflow

1.  **Setup:** Both users "Sign Up" locally. The app configures the database based on their role and business type.
2.  **Operation:** The Cashier records sales digitally. Stock is subtracted automatically, replacing paper logs.
3.  **Reporting:** The Cashier triggers an "Export," creating a summarized table stored in their local "Export Archive."
4.  **Sync:** The Cashier shares the text summary via Telegram/WhatsApp.
5.  **Analysis:** The Owner manually enters those figures into the "Smart Form" on their device to update profit metrics and staff performance.
# 🎨 UI/UX Design Philosophy

As a UI/UX-focused project, **HisabApp** prioritizes a clean, professional, and mobile-responsive interface.

- **Responsive Layouts:** Built using custom component styling to ensure usability across mobile and web platforms.

- **Role-Based Dashboards:** Distinct interfaces tailored to the functional needs of retail owners and branch cashiers.

---
# Navigation & Routing

The application utilizes the `GoRouter` package for all navigation logic. This declarative routing approach offers several advantages for our team:

- **Deep Linking:** Enables direct navigation to specific screens (e.g., inventory or sales reports) via URL.

- **State-Aware Routing:** Easily handles redirects based on user authentication status or roles (Owner vs. Cashier).

- **Clean Transitions:** Provides smoother navigation patterns suitable for the web-based version of the platform.

---
# 📂 Project Structure

The project follows a clean, decoupled architecture to separate the frontend, backend, and core logic:

HisabApp/ (Root)
├── hisab_server/         # Backend: Node.js/PHP API services
├── hisabapp/             # Frontend: Flutter mobile & web application
│   ├── android/          # Native Android configuration
│   ├── ios/              # Native iOS configuration
│   ├── assets/           # Application images and branding
│   ├── lib/              # Main Dart source code
│   │   ├── application/  # Application layer (DI, providers, use cases)
│   │   │   ├── di.dart                              # Dependency injection setup
│   │   │   ├── providers/                           # Riverpod state providers
│   │   │   ├── use_cases/                           # Business logic operations
│   │   │   ├── models/                              # API/DTOs and mappers
│   │   │   ├── app_repository_factory.dart          # Factory pattern for repositories
│   │   │   ├── app_repository_factory_io.dart       # Platform-specific (iOS/Android)
│   │   │   ├── app_repository_factory_web.dart      # Web platform implementation
│   │   │   └── app_repository_factory_stub.dart     # Stub for testing
│   │   │
│   │   ├── core/         # Shared logic, navigation, utilities
│   │   │   ├── navigation/
│   │   │   │   └── app_router.dart                  # GoRouter configuration & routes
│   │   │   ├── constants/                           # App-wide constants and configs
│   │   │   ├── platform/
│   │   │   │   ├── sqlite_initializer_web.dart      # SQLite web initialization
│   │   │   │   └── sqlite_initializer_io.dart       # SQLite mobile initialization
│   │   │   ├── error/                               # Error handling & exceptions
│   │   │   ├── presentation/                        # Reusable UI components
│   │   │   └── util/                                # Helper functions & utilities
│   │   │
│   │   ├── domain/       # Business logic entities & interfaces
│   │   │   ├── entities/                            # Core business objects (User, Branch, Product)
│   │   │   └── repositories/                        # Abstract repository interfaces
│   │   │
│   │   ├── features/     # Feature-specific UI & presentation
│   │   │   ├── Auth/
│   │   │   │   ├── login/
│   │   │   │   └── signup/
│   │   │   ├── Landing_page/                        # Initial role selection screen
│   │   │   ├── cashier/                             # Cashier-specific screens

│   │   │   ├── owner/                               # Owner-specific screens
│   │   │   ├── settings/                            # App settings & configuration
│   │   │   └── widgets/                             # Shared feature components
│   │   │
│   │   ├── infrastructure/  # Data sources & repository implementations
│   │   │   ├── local/
│   │   │   │   └── sqlite_service.dart              # SQLite database service (singleton)
│   │   │   ├── remote/                              # Remote API data sources
│   │   │   ├── data_sources/                        # Data source interfaces & implementations
│   │   │   ├── repositories/
│   │   │   │   ├── sqlite_app_repository.dart       # SQLite-based repository
│   │   │   │   └── cache_first_app_repository.dart  # Cache-first strategy decorator
│   │   │   └── repositories/
│   │   │
│   │   └── main.dart     # App entry point with Riverpod setup
│   │
│   └── pubspec.yaml      # Project dependencies
└── README.md
## 🗄 Database Management (SQLite)

HisabApp uses SQLite as its local database engine for persistent offline storage. The database is platform-independent and provides reliable data persistence across all platforms (iOS, Android, Web, Linux, macOS, Windows).

### SQLite Service Architecture

Location: lib/infrastructure/local/sqlite_service.dart

The SqliteService is implemented as a Singleton pattern, ensuring only one database connection exists throughout the app lifecycle:

class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();
}
### Key Features:

- Lazy Initialization: Database is only initialized when first accessed via db getter
- Version Control: Database supports schema versioning (currently on version 3) with automatic migrations
- Cross-Platform Compatibility:
  - iOS/Android: Uses native SQLite via sqflite package
  - Web: Uses sqflite_common_ffi_web for browser-based SQLite implementation
  - Desktop (Linux/macOS/Windows): Uses FFI bindings for direct SQLite access

### Database Schema

Main tables include:
- users - User accounts (Owner/Cashier login)
- branches - Branch/outlet information
- products - Stock items with specifications
- sales - Transaction records
- staff - Employee information and performance metrics
- branch_costs - Operational costs (Rent, Salaries, Bulk purchases)
- reports - Daily/weekly/monthly reports
- product_attributes - Dynamic product field definitions
---

## 💾 Caching Strategy (Cache-First Pattern)

HisabApp implements a Cache-First data fetching strategy to minimize database queries and improve performance. This is crucial for offline-first applications.

### How Cache-First Works

Location: lib/infrastructure/repositories/cache_first_app_repository.dart

The CacheFirstAppRepository wraps both local and remote repositories, implementing this workflow:
Request Data
    ↓
Check Local Cache (SQLite)
    ↓
Found ✓ → Return Cached Data (Fast Response)
    ↓
Not Found ✗ → Query Remote/API
    ↓
Update Local Cache with New Data
    ↓
Return Data
## 🎛 State Management (Riverpod)

HisabApp uses Riverpod for reactive state management, providing a clean, testable, and scalable approach to handling application state.
### Benefits of Riverpod in HisabApp:

- Reactive UI Updates: Automatic rebuilds when state changes
- No Context Lookup: Avoid passing BuildContext through deep widget trees
- Shared State: Multiple widgets can access the same provider instance
- Built-in Caching: Providers cache results and invalidate appropriately
- Family Modifiers: Parameterized providers for dynamic state (e.g., by branch ID)

---
## 🔄 Understanding DDD Architecture

HisabApp follows Domain-Driven Design (DDD) principles for a clean, maintainable codebase:

### Layer Breakdown

#### 1. Domain Layer (lib/domain/)
- Purpose: Core business logic independent of frameworks
- Contains: Entities, Repository interfaces, Business rules
- Examples:
  - Branch, Product, Sale entities
  - AppRepository interface
- Key Principle: 100% framework-agnostic Dart code

#### 2. Application Layer (lib/application/)
- Purpose: Orchestrate domain logic and manage state
- Contains: Use cases, Riverpod providers, DTOs, Dependency Injection
- Responsibilities:
  - Translate user actions into use cases
  - Manage application state via Riverpod
  - Handle cross-cutting concerns (logging, error handling)
#### 3. Infrastructure Layer (lib/infrastructure/)
- Purpose: Implement data access and external services
- Contains: Repository implementations, SQLite service, API clients
- Examples:
  - SqliteAppRepository - SQLite-based data persistence
  - CacheFirstAppRepository - Caching strategy
  - SqliteService - Database connection management

#### 4. Presentation Layer (lib/features/, lib/core/)
- Purpose: UI and user interactions
- Contains: Screens, Widgets, UI logic
- Dependencies: Only on Application and Domain layers

### Data Flow Example: Recording a Sale
User Input (Presentation)
    ↓
ConsumerWidget watches provider
    ↓
Riverpod Provider (Application)
    ↓
Use Case / Repository Method
    ↓
Repository Implementation (Infrastructure)
    ↓
SQLite Service
    ↓
Local Database
    ↓
Result returned through FutureProvider
    ↓
UI Rebuilds with New Data
## 🧪 Testing Architecture

HisabApp includes comprehensive test coverage:

- Unit Tests: test/ directory - Test business logic, use cases, and repositories
- Widget Tests: test/ directory - Test UI components and interactions
- Integration Tests: Test complete user workflows (authentication, sales recording, etc.)
## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK (>=3.11.4)
- Dart SDK (included with Flutter)
- Xcode (for iOS development)
- Android Studio (for Android development)
### Clone & Setup
# Clone repository
git clone <repository-url>
cd HisabApp/hisabapp

# Install dependencies
flutter pub get

# Generate code (if using build_runner)
flutter pub run build_runner build

### Running the App
**# Run on connected device/emulator
**flutter run

**# Run on web
**flutter run -d chrome

**# Run on desktop (macOS)
**flutter run -d macos

**# Build production APK (Android)
**flutter build apk --release

**# Build iOS app
****flutter build ios --release
**---
## 📞 Support & Troubleshooting

### Common Issues

Q: App crashes on first run
- A: Delete app data, clear Gradle cache, reinstall

Q: SQLite database locked error
- A: Ensure only one database connection exists (SqliteService Singleton pattern)

Q: Riverpod "provider not found" error
- A: Check that all providers are properly defined in lib/application/di.dart or feature-specific provider files

---

