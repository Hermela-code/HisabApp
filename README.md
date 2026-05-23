# HisabApp
## Multi-Branch Stock & Sales Management System

**HisabApp** is an offline-first mobile business utility designed for retail owners and cashiers operating in environments with limited or unreliable internet connectivity. It replaces error-prone paper ledgers with a structured digital database, acting as a "digital bridge" between independent branches and a central owner.

---

## Project Overview

The primary goal of HisabApp is to automate complex business calculations—such as net profit, total income, and staff salaries—while eliminating the burden of manual paper-based recording. 

### Core Objectives:
* **For the Owner:** Minimize the hardship of managing diverse stock across multiple locations without constant physical supervision.
* **For the Cashier:** Simplify daily tasks through automatic stock subtraction and instant access to historical sales data.

---

## Team Members

| Full Name | ID |
| :--- | :--- |
| **Abreham Yonatan** | [UGR/4463/16] |
| **Gelila Sintayehu** | [UGR/3508/16] |
| **Kidist Nega** | [UGR/1923/16] |
| **Nabon Amanuel** | [UGR/7416/16] |
| **Victory Bedru** | [UGR/4541/16] |

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

- **Centralized Control:** All application routes are managed in a single file (`lib/core/navigation/app_router.dart`), preventing merge conflicts in `main.dart`.

- **State-Aware Routing:** Easily handles redirects based on user authentication status or roles (Owner vs. Cashier).

- **Clean Transitions:** Provides smoother navigation patterns suitable for the web-based version of the platform.

---
# 📂 Project Structure

The project follows a clean, decoupled architecture to separate the frontend, backend, and core logic:

```plaintext
HisabApp/ (Root)
├── hisab_server/         # Backend: Node.js/PHP API services
├── hisabapp/             # Frontend: Flutter mobile & web application
│   ├── android/          # Native Android configuration
│   ├── ios/              # Native iOS configuration
│   ├── assets/           # Application images and branding
│   ├── lib/              # Main Dart source code
│   │   ├── core/         # Shared logic and Navigation (GoRouter)
│   │   ├── features/     # Feature-based modules (Auth, Inventory, POS)
│   │   └── main.dart     # App entry point
│   └── pubspec.yaml      # Project dependencies
└── README.md
