# Spidest Travel Website Module - PRD & Architecture Plan

**Project:** Spidest - Hajj & Umrah Travel CMS  
**Base:** Lara Dashboard v1.1.2 (Laravel 12 + Livewire 3 + Tailwind CSS v4)  
**Document Version:** 1.0  
**Last Updated:** 2026-04-26  
**Author:** Architecture Planning

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Vision & Goals](#vision--goals)
3. [Module Architecture Strategy](#module-architecture-strategy)
4. [User Personas](#user-personas)
5. [Core Features](#core-features)
6. [Database Design](#database-design)
7. [Module Structure](#module-structure)
8. [Frontend Architecture](#frontend-architecture)
9. [API Design](#api-design)
10. [Integration Points](#integration-points)
11. [Security & Compliance](#security--compliance)
12. [Performance & Scalability](#performance--scalability)
13. [Deployment Strategy](#deployment-strategy)
14. [Development Roadmap](#development-roadmap)

---

## Project Overview

### What is Spidest?

**Spidest** is a modular CMS platform designed specifically for Islamic travel services (Hajj & Umrah). It serves as:

1. **Admin Backend** - For travel operators to manage packages, bookings, payments, and customer relationships
2. **Public Website** - For general users to browse packages, make bookings, and manage their pilgrimages
3. **Extensible Foundation** - Can be reused for other business domains (Finance, CRM, Products, etc.)

### The Modular Philosophy

Spidest follows a **micro-modular architecture** where:

- **Core Base Project** (`spidest/`) - Stable, never changes, contains only infrastructure
- **Feature Modules** - Each business feature lives in its own repository
  - `spidest-travel-website/` - Public-facing travel website & booking system
  - `spidest-crm/` - Customer relationship management (future)
  - `spidest-finance/` - Invoicing, payments, reconciliation (future)
  - `spidest-reporting/` - Analytics & business intelligence (future)

This ensures:
✅ **Zero coupling** between modules  
✅ **Independent deployment** of each module  
✅ **Code stability** - Core project never breaks  
✅ **Reusability** - Base can power different businesses  
✅ **Team scalability** - Teams can work on modules independently

---

## Vision & Goals

### Primary Goals (MVP Phase)

1. **Enable Self-Service Bookings** - Users can browse & book hajj/umrah packages online
2. **Comprehensive Package Management** - Operators manage all package details, pricing, availability
3. **Secure Transactions** - Payment processing with audit trails and reconciliation
4. **User Journey Tracking** - From inquiry → booking → journey completion
5. **Regulatory Compliance** - Islamic travel regulations (visa, permits, health requirements)
6. **Reputation System** - Reviews, ratings, and testimonials for packages

### Secondary Goals (Phase 2-3)

- Multi-language support (Arabic, English, Indonesian, Urdu, etc.)
- Mobile app integration (via REST API)
- Advanced analytics & reporting
- CRM integration for lead management
- Automated email/SMS workflows
- Document management (passports, visas)

### Business Metrics

- Conversion rate: 2-5% (inquiry → booking)
- Customer satisfaction: 4.5+ stars
- Payment success rate: >99%
- Page load time: <2 seconds
- Uptime: 99.9%

---

## Module Architecture Strategy

### 1. Repository Structure

```
pesantech-group/
├── spidest/                          # Core (Base Project)
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── routes/
│   ├── resources/
│   ├── modules/                      # Installed modules go here
│   │   └── (empty in core - symlinks to external modules)
│   └── ...
│
├── spidest-travel-website/           # Travel Module (Separate Repo)
│   ├── Modules/TravelWebsite/
│   │   ├── Http/
│   │   ├── Services/
│   │   ├── Models/
│   │   ├── Database/
│   │   ├── Resources/
│   │   ├── Views/
│   │   ├── Tests/
│   │   └── routes/
│   ├── module.json
│   ├── composer.json
│   ├── package.json
│   └── README.md
│
├── spidest-crm/                      # Future CRM Module
├── spidest-finance/                  # Future Finance Module
└── spidest-infrastructure/           # Shared utilities (optional)
```

### 2. Installation Flow

**Development:**
```bash
# Clone core
git clone git@github.com:pesantech/spidest.git

# Clone and symlink module
git clone git@github.com:pesantech/spidest-travel-website.git modules/TravelWebsite

# Install dependencies
composer install && npm install

# Run migrations and seed
php artisan migrate --seed
```

**Production (Distributed Zip):**
```bash
# Download spidest-base.zip (core + Lara Dashboard)
# Download TravelWebsite-v1.0.0.zip (module)
# Extract modules/TravelWebsite/ into unzipped core
# Run setup
```

### 3. Dependency Flow (Unidirectional)

```
Public User
    ↓
Travel Website Module (spidest-travel-website)
    ↓
Core Base Project (spidest)
    ↓
Database / External Services
```

**STRICT RULE:** Core never imports from Travel Website or any module.

---

## User Personas

### Persona 1: Fatima (Hajj Pilgrim)
- Age: 35-55
- Tech Literacy: Medium
- Goal: Find affordable hajj packages with spiritual guidance
- Pain Points: Unsure about visa process, needs transparent pricing, wants community reviews
- Device: Mobile-first (smartphone)
- Languages: Arabic, English, Indonesian

### Persona 2: Ahmad (Travel Agency Manager)
- Age: 28-45
- Tech Literacy: High
- Goal: Manage multiple packages, track bookings, monitor payments
- Pain Points: Manual processes, scattered customer data, difficulty scaling
- Device: Desktop/Laptop
- Languages: Arabic, English

### Persona 3: Sarah (Customer Service Rep)
- Age: 22-35
- Tech Literacy: Medium
- Goal: Handle customer inquiries, provide timely support
- Pain Points: Long email chains, repeated questions, no customer history
- Device: Desktop + Mobile
- Languages: English, Arabic

### Persona 4: Admin (Finance/Compliance Officer)
- Age: 35-55
- Tech Literacy: Medium
- Goal: Ensure regulatory compliance, track payments, generate reports
- Pain Points: Manual reconciliation, audit trails, regulatory requirements
- Device: Desktop
- Languages: English

---

## Core Features

### Feature Tier 1: MVP (Foundation)

#### 1.1 Package Management
- ✅ Create/Edit/Delete hajj & umrah packages
- ✅ Dynamic pricing (per-person, group discounts)
- ✅ Availability calendar with departure dates
- ✅ Package itinerary with daily activities
- ✅ Inclusions/Exclusions listing
- ✅ Hotel & transport details
- ✅ Guide assignment
- ✅ Capacity management (min/max pilgrims)

#### 1.2 Package Discovery & Search
- ✅ Browse packages by type (hajj, umrah, mini-umrah)
- ✅ Filter by price, dates, duration, amenities
- ✅ Search by destination, hotel rating
- ✅ Package comparison tool
- ✅ Detailed package view with photos/videos
- ✅ FAQ & testimonials

#### 1.3 Booking System
- ✅ Shopping cart functionality
- ✅ Pilgrim details form (name, passport, contact)
- ✅ Medical requirements checklist
- ✅ Payment method selection
- ✅ Invoice generation
- ✅ Booking confirmation email
- ✅ Booking status tracking (pending, confirmed, paid, cancelled)

#### 1.4 Payment Processing
- ✅ Multiple payment gateways (Stripe, Paypal, Local: Midtrans)
- ✅ Installment plans (4/12 months)
- ✅ Partial payment support
- ✅ Refund management
- ✅ Payment audit trail
- ✅ Reconciliation reports

#### 1.5 User Accounts
- ✅ Self-registration (email verification)
- ✅ Profile management (personal + family members)
- ✅ Booking history
- ✅ Wishlist / saved packages
- ✅ Payment methods management
- ✅ Document upload (passport scan, visa)

#### 1.6 Admin Dashboard
- ✅ Package CRUD interface
- ✅ Booking management
- ✅ Payment tracking
- ✅ Customer management
- ✅ Revenue reports
- ✅ Email templates

### Feature Tier 2: Enhanced (Phase 2)

#### 2.1 Multi-Language & Localization
- Arabic, English, Indonesian, Urdu, Malay
- Automated translation via AI
- RTL support for Arabic

#### 2.2 Communication Hub
- Email templates (booking, payment, reminders)
- SMS notifications (important milestones)
- In-app notifications
- WhatsApp integration (optional)
- Notification preferences

#### 2.3 Regulations & Compliance
- Visa requirements by nationality
- Health requirements (vaccinations)
- Document checklist per country
- Automatic compliance checks
- Audit logs for regulatory inspection

#### 2.4 Reviews & Ratings
- Pilgrim testimonials with photos
- Package ratings (5-star)
- Guide ratings
- Community Q&A

#### 2.5 Group Management
- Group creation for family/organizations
- Group leader dashboard
- Collective invoicing
- Group communication tools

### Feature Tier 3: Advanced (Phase 3+)

- ✅ Mobile app (iOS/Android)
- ✅ Real-time GPS tracking (during pilgrimage)
- ✅ Virtual tour of hotels/routes (360° video)
- ✅ CRM integration for lead management
- ✅ Dynamic pricing based on demand
- ✅ Affiliate/referral program
- ✅ Custom package builder (A/B testing)

---

## Database Design

### Core Models & Relationships

```
┌─────────────────┐
│ User            │ (from core - Spatie\Permission)
├─────────────────┤
│ id              │
│ name            │
│ email           │
│ phone           │
│ created_at      │
└─────────────────┘
         ↓
         ├─→ Pilgrim Profile (extends User)
         ├─→ Bookings
         ├─→ Payments
         └─→ Reviews

┌─────────────────────┐
│ TravelPackage       │ (MVP Core)
├─────────────────────┤
│ id (uuid)           │
│ name                │
│ slug                │
│ type (hajj/umrah)   │
│ description         │
│ duration_days       │
│ price_base          │
│ capacity            │
│ published_at        │
│ created_at          │
└─────────────────────┘
         ↓
         ├─→ PackageItinerary (daily agenda)
         ├─→ PackageHotel (accommodations)
         ├─→ PackageTransport (flights/buses)
         ├─→ PackageGuide (spiritual guides)
         ├─→ PackagePricing (variants)
         └─→ PackageAvailability (departure dates)

┌──────────────────────┐
│ Booking              │ (MVP Core)
├──────────────────────┤
│ id (uuid)            │
│ package_id           │
│ user_id              │
│ booking_number       │
│ status               │ (pending, confirmed, paid, cancelled)
│ total_price          │
│ pilgrims_count       │
│ departure_date       │
│ notes                │
│ created_at           │
└──────────────────────┘
         ↓
         ├─→ BookingPilgrim (passenger details)
         ├─→ BookingPayment
         └─→ BookingDocument (passport, visa)

┌──────────────────────┐
│ Payment              │ (MVP Core)
├──────────────────────┤
│ id (uuid)            │
│ booking_id           │
│ amount               │
│ status               │ (pending, succeeded, failed, refunded)
│ gateway              │ (stripe, paypal, midtrans)
│ transaction_id       │
│ receipt_url          │
│ paid_at              │
│ created_at           │
└──────────────────────┘

┌──────────────────────┐
│ Review               │ (Phase 2)
├──────────────────────┤
│ id                   │
│ package_id           │
│ user_id              │
│ rating (1-5)         │
│ title                │
│ comment              │
│ photo_url            │
│ verified_purchase    │
│ helpful_count        │
│ created_at           │
└──────────────────────┘
```

### Key Relationships

```php
// User → Bookings (one-to-many)
User::with('bookings')->get()

// Booking → Pilgrims (one-to-many)
Booking::with('pilgrims')->get()

// Package → Bookings (one-to-many)
TravelPackage::with('bookings')->get()

// Package → Pricing (one-to-many, polymorphic)
TravelPackage::with('pricing')->get()

// Booking → Payments (one-to-many)
Booking::with('payments')->get()

// User → Reviews (one-to-many)
User::with('reviews')->get()
```

### Database Tables Schema

```sql
-- packages table
CREATE TABLE travel_packages (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    type ENUM('hajj', 'umrah', 'mini-umrah') NOT NULL,
    description LONGTEXT,
    duration_days INT,
    price_base DECIMAL(15, 2),
    capacity INT,
    image_url VARCHAR(255),
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- bookings table
CREATE TABLE bookings (
    id UUID PRIMARY KEY,
    package_id UUID NOT NULL FOREIGN KEY,
    user_id BIGINT NOT NULL FOREIGN KEY,
    booking_number VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('pending', 'confirmed', 'paid', 'completed', 'cancelled') DEFAULT 'pending',
    total_price DECIMAL(15, 2),
    pilgrims_count INT,
    departure_date DATE,
    notes TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (package_id) REFERENCES travel_packages(id)
);

-- booking_pilgrims table (passenger details)
CREATE TABLE booking_pilgrims (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    booking_id UUID NOT NULL FOREIGN KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    passport_number VARCHAR(50),
    nationality VARCHAR(100),
    date_of_birth DATE,
    health_conditions TEXT,
    created_at TIMESTAMP
);

-- payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY,
    booking_id UUID NOT NULL FOREIGN KEY,
    amount DECIMAL(15, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('pending', 'succeeded', 'failed', 'refunded') DEFAULT 'pending',
    gateway VARCHAR(50),
    transaction_id VARCHAR(255),
    receipt_url VARCHAR(255),
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- reviews table
CREATE TABLE reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    package_id UUID NOT NULL FOREIGN KEY,
    user_id BIGINT NOT NULL FOREIGN KEY,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    comment LONGTEXT,
    photo_url VARCHAR(255),
    verified_purchase BOOLEAN DEFAULT false,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (package_id) REFERENCES travel_packages(id)
);
```

---

## Module Structure

### Laradashboard Module Layout

```
Modules/TravelWebsite/
├── Http/
│   ├── Controllers/
│   │   ├── Admin/
│   │   │   ├── PackageController.php
│   │   │   ├── BookingController.php
│   │   │   └── PaymentController.php
│   │   └── Public/
│   │       ├── HomeController.php
│   │       ├── PackageController.php
│   │       └── BookingController.php
│   ├── Requests/
│   │   ├── StorePackageRequest.php
│   │   ├── StoreBookingRequest.php
│   │   └── StorePaymentRequest.php
│   └── Resources/
│       ├── PackageResource.php
│       ├── BookingResource.php
│       └── PaymentResource.php
│
├── Livewire/
│   ├── Admin/
│   │   ├── Packages/
│   │   │   ├── Index.php
│   │   │   ├── Create.php
│   │   │   └── Edit.php
│   │   ├── Bookings/
│   │   │   ├── Index.php
│   │   │   └── Show.php
│   │   └── Payments/
│   │       ├── Index.php
│   │       └── Reconcile.php
│   └── Frontend/
│       ├── PackageSearch.php
│       ├── PackageDetail.php
│       ├── BookingCart.php
│       └── CheckoutForm.php
│
├── Models/
│   ├── TravelPackage.php
│   ├── PackageItinerary.php
│   ├── PackageHotel.php
│   ├── PackageTransport.php
│   ├── PackagePricing.php
│   ├── PackageAvailability.php
│   ├── Booking.php
│   ├── BookingPilgrim.php
│   ├── Payment.php
│   └── Review.php
│
├── Services/
│   ├── PackageService.php
│   ├── BookingService.php
│   ├── PaymentService.php
│   ├── PricingService.php
│   └── ComplianceService.php
│
├── Jobs/
│   ├── SendBookingConfirmation.php
│   ├── ProcessPayment.php
│   ├── SendPaymentReminder.php
│   └── GenerateInvoice.php
│
├── Events/
│   ├── BookingCreated.php
│   ├── PaymentSucceeded.php
│   └── BookingCompleted.php
│
├── Listeners/
│   ├── SendBookingConfirmationEmail.php
│   ├── UpdateBookingStatus.php
│   └── LogPaymentTransaction.php
│
├── Database/
│   ├── Migrations/
│   │   ├── 2026_01_01_000001_create_travel_packages_table.php
│   │   ├── 2026_01_01_000002_create_bookings_table.php
│   │   ├── 2026_01_01_000003_create_payments_table.php
│   │   └── 2026_01_01_000004_create_reviews_table.php
│   ├── Seeders/
│   │   ├── TravelPackageSeeder.php
│   │   └── BookingSeeder.php
│   └── Factories/
│       ├── TravelPackageFactory.php
│       ├── BookingFactory.php
│       └── PaymentFactory.php
│
├── Resources/
│   ├── Views/
│   │   ├── admin/
│   │   │   ├── packages/
│   │   │   │   ├── index.blade.php
│   │   │   │   ├── create.blade.php
│   │   │   │   └── edit.blade.php
│   │   │   ├── bookings/
│   │   │   │   └── index.blade.php
│   │   │   └── payments/
│   │   │       └── index.blade.php
│   │   └── frontend/
│   │       ├── packages/
│   │       │   ├── index.blade.php
│   │       │   └── show.blade.php
│   │       ├── booking/
│   │       │   ├── cart.blade.php
│   │       │   └── checkout.blade.php
│   │       └── layouts/
│   │           ├── app.blade.php
│   │           └── footer.blade.php
│   ├── Css/
│   │   ├── travel-website.css (Tailwind with prefix)
│   │   └── components.css
│   └── Js/
│       ├── travel-website.js
│       └── booking-flow.js
│
├── Routes/
│   ├── api.php (REST API)
│   ├── web.php (Admin routes)
│   └── frontend.php (Public website routes)
│
├── Tests/
│   ├── Feature/
│   │   ├── PackageTest.php
│   │   ├── BookingTest.php
│   │   ├── PaymentTest.php
│   │   └── FrontendTest.php
│   └── Unit/
│       ├── Services/
│       │   ├── PackageServiceTest.php
│       │   └── PricingServiceTest.php
│       └── Models/
│           └── BookingTest.php
│
├── Policies/
│   ├── PackagePolicy.php
│   ├── BookingPolicy.php
│   └── PaymentPolicy.php
│
├── Enums/
│   ├── BookingStatus.php
│   ├── PaymentStatus.php
│   ├── PackageType.php
│   └── PaymentGateway.php
│
├── Hooks/
│   └── Hooks.php (WordPress-style hooks)
│
├── module.json
├── routes.php
├── vite.config.js
├── tailwind.config.js
├── composer.json
├── package.json
├── README.md
├── .env.example
└── CLAUDE.md
```

### Module Configuration (module.json)

```json
{
  "name": "TravelWebsite",
  "alias": "travel-website",
  "description": "Hajj & Umrah Travel Website - Public website and booking system",
  "keywords": ["travel", "hajj", "umrah", "booking"],
  "version": "1.0.0",
  "author": "Spidest Team",
  "active": 1,
  "order": 0,
  "providers": [
    "Modules\\TravelWebsite\\Providers\\TravelWebsiteServiceProvider"
  ],
  "aliases": {},
  "files": [],
  "requires": {
    "stripe/stripe-php": "^13.0",
    "laravel/cashier": "^14.0"
  }
}
```

---

## Frontend Architecture

### Two-UI Strategy

The module provides **two completely separate user interfaces**:

#### 1. Admin Panel (Backend Staff)
- **Framework:** Livewire 3 + Blade + Tailwind CSS v4
- **Location:** `/admin/travel-website/*`
- **Purpose:** Package management, booking control, payment tracking
- **Features:**
  - Datatables with sorting/filtering
  - Form builders with validation
  - Charts & analytics
  - Bulk operations
  - Real-time status updates (Livewire)

#### 2. Public Website (End Users)
- **Framework:** Blade templates + Alpine.js + Tailwind CSS v4
- **Location:** `/travel/*`
- **Purpose:** Package discovery, booking, account management
- **Features:**
  - Modern, mobile-first design
  - Smooth user experience
  - Payment integration
  - Responsive layouts
  - SEO optimized

### Frontend Component Hierarchy

```
Frontend Website
├── Header (Navigation, Search, User Menu)
├── Hero Section (Featured Packages)
├── Package Grid
│   ├── Package Card
│   │   ├── Image Gallery
│   │   ├── Price Display
│   │   ├── Rating Stars
│   │   └── CTA Button
├── Search & Filter Sidebar
│   ├── Price Range Slider
│   ├── Duration Filter
│   ├── Type Filter (Hajj/Umrah)
│   └── Amenities Filter
├── Package Detail Page
│   ├── Hero Image
│   ├── Itinerary Timeline
│   ├── Hotel Details
│   ├── Transport Info
│   ├── Pricing Breakdown
│   ├── Reviews Section
│   └── Booking Form
├── Shopping Cart
│   ├── Cart Items
│   ├── Price Summary
│   └── Checkout Button
├── Checkout Page (Multi-step)
│   ├── Step 1: Pilgrim Details
│   ├── Step 2: Payment Method
│   ├── Step 3: Review & Confirm
│   └── Step 4: Success Page
└── User Account
    ├── Profile Management
    ├── Booking History
    ├── Wishlist
    └── Settings
```

### Livewire Components (Admin)

```php
// Livewire\Admin\Packages\Index - Package datatable
class Index extends Component {
    public function render() { /* interactive datatable */ }
}

// Livewire\Admin\Packages\Create - Package creation form
class Create extends Component {
    public function save() { /* save package */ }
}

// Livewire\Admin\Bookings\Index - Live booking stream
class Index extends Component {
    #[On('booking-created')] 
    public function refreshBookings() { /* reload list */ }
}
```

### Tailwind CSS Prefixing

To avoid conflicts between admin & public interfaces:

```js
// tailwind.config.js (in module)
module.exports = {
  prefix: 'tw-', // prefix all classes with 'tw-'
  content: ['./Modules/TravelWebsite/**/*.{blade.php,js}']
};

// Usage in templates
<div class="tw-flex tw-gap-4">
  <button class="tw-bg-blue-500 tw-text-white">Book Now</button>
</div>
```

---

## API Design

### REST API Endpoints

The module exposes REST API endpoints for **mobile apps, third-party integrations, and SPAs**.

#### Authentication
```
POST   /api/v1/auth/login
POST   /api/v1/auth/register
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh-token
```

#### Packages
```
GET    /api/v1/packages              (List with filters)
GET    /api/v1/packages/{id}         (Detail with itinerary)
GET    /api/v1/packages/{id}/reviews (Package reviews)
```

#### Bookings
```
POST   /api/v1/bookings              (Create booking)
GET    /api/v1/bookings/{id}         (Get booking details)
PATCH  /api/v1/bookings/{id}         (Update booking)
DELETE /api/v1/bookings/{id}         (Cancel booking)
GET    /api/v1/bookings/{id}/status  (Track booking)
```

#### Payments
```
POST   /api/v1/payments              (Create payment)
GET    /api/v1/payments/{id}         (Payment status)
POST   /api/v1/payments/{id}/refund  (Request refund)
```

#### User Profile
```
GET    /api/v1/me                    (Current user)
PATCH  /api/v1/me                    (Update profile)
POST   /api/v1/me/documents          (Upload documents)
GET    /api/v1/me/bookings           (My bookings)
```

### API Response Format

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Umrah Plus 14 Days",
    "type": "umrah",
    "price": 2500.00,
    "currency": "USD",
    "duration_days": 14,
    "capacity": 30,
    "available_slots": 12,
    "rating": 4.8,
    "reviews_count": 127,
    "itinerary": [...],
    "hotels": [...],
    "transport": {...}
  },
  "meta": {
    "timestamp": "2026-04-26T10:30:00Z",
    "version": "1.0"
  }
}
```

### Error Handling

```json
{
  "success": false,
  "error": "validation_error",
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "phone": ["The phone must be a valid format."]
  }
}
```

---

## Integration Points

### With Lara Dashboard Core

**Module registers with core via Hooks (WordPress-style):**

```php
// In Providers/TravelWebsiteServiceProvider.php

public function boot(): void {
    // Register admin menu item
    add_filter('admin.menu.items', function ($items) {
        $items[] = [
            'title' => 'Travel Website',
            'icon' => 'icon-globe',
            'items' => [
                ['title' => 'Packages', 'route' => 'travel-website.packages.index'],
                ['title' => 'Bookings', 'route' => 'travel-website.bookings.index'],
                ['title' => 'Payments', 'route' => 'travel-website.payments.index'],
            ]
        ];
        return $items;
    });

    // Register roles & permissions
    add_action('core.roles.booting', function () {
        Permission::firstOrCreate(['name' => 'travel-website.packages.view']);
        Permission::firstOrCreate(['name' => 'travel-website.bookings.manage']);
        // ... more permissions
    });

    // Register API routes
    add_action('api.routes.booting', function () {
        // Load routes/api.php
    });

    // Register migrations
    $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');

    // Register views
    $this->loadViewsFrom(__DIR__.'/../Resources/Views', 'travel-website');

    // Register translations
    $this->loadTranslationsFrom(__DIR__.'/../Resources/Lang', 'travel-website');
}
```

### External Integrations

#### Payment Gateways
- **Stripe** - Primary gateway (high-volume payments)
- **PayPal** - Fallback gateway (legacy users)
- **Midtrans** - Local Southeast Asia payment gateway

```php
// PaymentService.php
class PaymentService {
    public function processPayment(Booking $booking, string $gateway): Payment {
        return match ($gateway) {
            'stripe' => (new StripeGateway())->charge($booking),
            'paypal' => (new PayPalGateway())->charge($booking),
            'midtrans' => (new MidtransGateway())->charge($booking),
        };
    }
}
```

#### Email Service
- Uses Laravel's Mail system (SMTP via core settings)
- Jobs dispatched to queue for async processing

```php
// Jobs/SendBookingConfirmation.php
class SendBookingConfirmation implements ShouldQueue {
    public function handle(): void {
        Mail::to($booking->user->email)
            ->send(new BookingConfirmationMail($booking));
    }
}
```

#### SMS/Notifications (Optional)
- Twillio for SMS
- OneSignal for push notifications
- In-app notifications via Livewire

#### Document Storage
- AWS S3 for scalability
- Local storage for small deployments
- Encrypted storage for sensitive documents (passports)

---

## Security & Compliance

### Data Security

#### Encryption
- All payments encrypted with TLS 1.3
- Sensitive data (passport numbers) encrypted at rest
- Customer PII protected with database encryption

```php
// Model encryption
class BookingPilgrim extends Model {
    protected $encrypted = ['passport_number', 'date_of_birth'];
}
```

#### Authentication & Authorization
- Session-based auth for web users (Laravel Sanctum)
- Token-based auth for API (Bearer tokens)
- Role-based access control (Spatie Permissions)

```php
// Only admins can view all bookings
class BookingPolicy {
    public function viewAny(User $user): bool {
        return $user->hasRole('admin');
    }
}
```

### PCI Compliance

- Never store full credit card numbers
- Use tokenized payments (Stripe, PayPal handle cards)
- PCI-DSS certified payment gateways only
- Regular security audits

### Data Privacy (GDPR-Ready)

- User data export functionality
- Right to be forgotten (soft delete + anonymization)
- Consent management (email opt-in/out)
- Privacy policy & terms acceptance

```php
// User can request data export
class UserController {
    public function exportData(User $user) {
        return response()->json([
            'profile' => $user->only(['name', 'email', 'phone']),
            'bookings' => $user->bookings,
            'payments' => $user->payments,
        ]);
    }
}
```

### Audit Logging

All sensitive actions logged via core's audit system:

```php
// Automatically tracked
Booking::create([...]);        // Logs: "Booking created by user_id:5"
Payment::update([...]);        // Logs: "Payment updated"
$booking->delete();            // Logs: "Booking soft-deleted"
```

### Regulatory Compliance

#### Hajj/Umrah Specific
- Visa requirement checking per nationality
- Health requirement enforcement (vaccinations)
- Group size limits per regulations
- Guide qualification verification
- Prayer time reminders & orientation

```php
// Auto-compliance checks
class ComplianceService {
    public function validateBooking(Booking $booking): array {
        return [
            'visa_required' => $this->checkVisa($booking->user->nationality),
            'vaccinations_required' => $this->getVaccinations($booking->departure_date),
            'documents_required' => $this->getDocuments($booking->user->nationality),
        ];
    }
}
```

---

## Performance & Scalability

### Database Optimization

```php
// Eager loading (prevent N+1 queries)
TravelPackage::with(['itinerary', 'hotels', 'transport'])->get();

// Caching
TravelPackage::with(['reviews', 'ratings'])
    ->cache(minutes: 60)
    ->get();

// Indexing
Schema::create('bookings', function (Blueprint $table) {
    $table->index('user_id');
    $table->index('package_id');
    $table->index('status');
    $table->index('created_at');
});
```

### Frontend Performance

- **Assets:** Minified CSS/JS with Vite
- **Images:** Lazy loading, WebP format, CDN delivery
- **Caching:** Browser cache + Redis cache layer
- **Code Splitting:** Livewire components load on demand

```blade
<!-- Lazy loading images -->
<img loading="lazy" src="{{ $package->image_url }}" alt="{{ $package->name }}">

<!-- Alpine defer loading for below-fold content -->
<div x-data="{loaded: false}">
    @if ($loaded)
        <livewire:related-packages :package="$package" />
    @endif
</div>
```

### Scalability Architecture

```
┌─────────────┐
│ Load Balancer│ (Nginx + Keepalived for HA)
└──────┬──────┘
       ├─→ App Server 1 (Laravel + Livewire)
       ├─→ App Server 2 (Laravel + Livewire)
       └─→ App Server N (Auto-scaling)
              ↓
       ┌─────────────┐
       │ Redis Cache │ (Session, Queue, Cache)
       └──────┬──────┘
              ↓
       ┌──────────────┐
       │ MySQL Cluster│ (Read replicas + Primary)
       └──────────────┘
              ↓
       ┌──────────────┐
       │ S3 / Storage │ (Images, Documents)
       └──────────────┘
```

### Queue Processing

Long-running operations pushed to queue:

```php
// Async job processing
SendBookingConfirmation::dispatch($booking); // Non-blocking

// Scheduled tasks (via Kernel)
$schedule->job(GenerateMonthlyReport::class)->monthlyOn(1, '00:00');
$schedule->job(SendPaymentReminders::class)->dailyAt('09:00');
```

---

## Deployment Strategy

### Development Environment

```bash
# Clone & setup
git clone git@github.com:pesantech/spidest.git
git clone git@github.com:pesantech/spidest-travel-website.git modules/TravelWebsite

composer install && npm install

# Run migrations
php artisan migrate:fresh --seed

# Start dev server
composer run dev
```

### Production Deployment

#### Option 1: Docker (Recommended for VPS)

```dockerfile
# Dockerfile
FROM php:8.3-fpm-alpine

RUN apk add --no-cache mysql-client postgresql-client redis
RUN docker-php-ext-install pdo_mysql pdo_pgsql redis

COPY . /app
WORKDIR /app

RUN composer install --no-dev --optimize-autoloader
RUN npm run build:all

CMD ["php-fpm"]
```

```yaml
# docker-compose.yml
services:
  web:
    build: .
    ports: ["8000:8000"]
    env_file: .env
  nginx:
    image: nginx:latest
    ports: ["80:80", "443:443"]
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
  db:
    image: mysql:8.0
    env_file: .env
  redis:
    image: redis:7-alpine
```

#### Option 2: Traditional Shared Hosting

```bash
# Build assets
npm run build:all

# Optimize for production
composer install --no-dev --optimize-autoloader

# Create distribution zip
php artisan core:zip

# Upload to cPanel, extract, configure .env, run migrations
```

#### Option 3: Heroku/PaaS

```procfile
web: vendor/bin/heroku-php-apache2 public/
release: php artisan migrate --force
```

### Deployment Checklist

- [ ] Environment variables configured (.env)
- [ ] Database migrations applied
- [ ] Assets built and minified
- [ ] Storage permissions configured
- [ ] Cache cleared (php artisan cache:clear)
- [ ] Jobs queue configured and running
- [ ] SSL certificate installed
- [ ] Backups configured (automated daily)
- [ ] Monitoring & alerts set up
- [ ] Error tracking (Sentry) configured
- [ ] CDN configured for static assets
- [ ] Database backups verified

---

## Development Roadmap

### Phase 1: MVP (Foundation) - Months 1-2
**Goal:** Minimal viable product for booking hajj/umrah packages

- [x] Database schema & models
- [x] Admin package management
- [x] Public package discovery & detail pages
- [x] Shopping cart & checkout
- [x] Payment processing (Stripe primary)
- [x] Booking confirmation & tracking
- [x] User registration & account management
- [x] REST API endpoints
- [x] Basic email notifications
- [x] Unit & feature tests (50%+ coverage)

**Deliverables:**
- Working website at https://travel.spidest.local
- Admin dashboard at https://admin.spidest.local
- REST API at /api/v1
- 30-50 test cases

### Phase 2: Enhanced UX & Compliance - Months 3-4
**Goal:** Improve user experience and add regulatory compliance

- [ ] Multi-language support (Arabic, English, Indonesian)
- [ ] Visa & health requirement checks
- [ ] Document checklist per country
- [ ] Advanced filters & search (map view, amenities)
- [ ] Group booking support
- [ ] Installment payment plans
- [ ] Email templates builder (admin)
- [ ] SMS notifications (Twillio)
- [ ] User reviews & ratings
- [ ] Wishlist & package comparison

**Deliverables:**
- Multi-language UI (5 languages)
- Compliance module integrated
- Advanced booking flow
- 80%+ test coverage

### Phase 3: Scalability & Integrations - Months 5-6
**Goal:** Scale to handle 1000s of concurrent users

- [ ] CRM integration (future crm module)
- [ ] Payment gateway optimization (PayPal, Midtrans)
- [ ] Advanced analytics & reporting
- [ ] Dynamic pricing based on demand
- [ ] Email campaign automation
- [ ] Virtual tour integration (360° video)
- [ ] Real-time booking updates (WebSockets)
- [ ] Performance optimization
- [ ] Security hardening & penetration testing
- [ ] Load testing & stress testing

**Deliverables:**
- 10,000+ bookings per month support
- 99.9% uptime
- <2 second page load time
- Advanced reporting dashboard

### Phase 4: Mobile & AI - Months 7-8 (Optional)
**Goal:** Mobile app and AI-powered features

- [ ] Native mobile app (iOS/Android)
- [ ] GPS tracking during pilgrimage
- [ ] AI chatbot for customer support
- [ ] AI-powered package recommendations
- [ ] Affiliate/referral program
- [ ] Whiteboard/white-label solution

---

## Appendix: Tech Stack Reference

### Backend Stack
- **Framework:** Laravel 12
- **ORM:** Eloquent
- **UI Framework:** Livewire 3
- **Package Manager:** Composer
- **Database:** MySQL 8.0
- **Cache:** Redis
- **Queue:** Redis Queues
- **Authentication:** Laravel Sanctum
- **Authorization:** Spatie Permissions
- **API Documentation:** Scramble

### Frontend Stack
- **Templating:** Blade
- **CSS Framework:** Tailwind CSS v4
- **JavaScript:** Alpine.js
- **Asset Bundler:** Vite
- **Package Manager:** npm

### DevOps Stack
- **Containerization:** Docker
- **Web Server:** Nginx
- **Version Control:** Git
- **CI/CD:** GitHub Actions
- **Monitoring:** New Relic / Datadog
- **Error Tracking:** Sentry
- **Email Service:** Mailgun / SendGrid
- **SMS Service:** Twillio
- **Payment Gateways:** Stripe, PayPal, Midtrans
- **File Storage:** AWS S3 / Local

### Testing Stack
- **Testing Framework:** Pest
- **Browser Testing:** Pest Plugin Browser
- **Static Analysis:** PHPStan (Larastan)
- **Code Formatting:** Pint
- **Type Safety:** Rector

---

## Document Versioning

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-26 | Architecture Team | Initial PRD creation |

---

**Status:** ✅ Ready for Development  
**Next Step:** Create initial module scaffold with `php artisan module:make TravelWebsite`
