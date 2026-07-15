# GiftsWale — Flutter Mobile App 🎁

A premium gift shopping mobile app built with Flutter, mirroring the [GiftsWale.com](https://giftswale.com) website. Uses the same Node.js/Prisma backend.

## Features

- 🏠 **Homepage** — Hero banners, category circles, product sections, gift cards
- 🛍️ **Shop** — Search, filters, sort, category chips, product grid
- 📦 **Product Detail** — Image gallery, price/discount, stock, qty stepper, add-to-cart
- 🛒 **Cart** — Items grouped by store, order summary, free shipping tracker
- ❤️ **Wishlist** — API-driven wishlist grid
- 💳 **Checkout** — 3-step flow (Address → Gift Options → Payment)
- 📋 **Orders** — Status filter tabs, order cards, cancel action
- 👤 **Profile** — Edit profile, change password, quick links, logout
- 🔐 **Auth** — Login, Register, Forgot Password with Bearer token
- 📱 **Bottom Navigation** — 4-tab shell (Home, Shop, Cart, Profile) with cart badge

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Routing | GoRouter (StatefulShellRoute) |
| HTTP | Dio (with Bearer token interceptor) |
| Secure Storage | flutter_secure_storage |
| Image Caching | cached_network_image |
| Backend | Node.js + Prisma (shared with web) |

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/          → AppColors, AppTextStyles, AppTheme
│   ├── constants/      → ApiConstants, AppConstants
│   ├── network/        → DioClient (interceptors, token refresh)
│   ├── router/         → GoRouter with StatefulShellRoute
│   ├── utils/          → Formatters, Validators
│   └── widgets/        → 11 shared widgets (Button, Input, Card, etc.)
├── models/             → User, Product, Category, Banner, CartItem, etc.
├── repositories/       → AuthRepository, HomepageRepository
├── providers/          → AuthProvider, HomepageProvider, CartProvider
└── features/
    ├── auth/           → Login, Register, ForgotPassword
    ├── home/           → HomeScreen + 4 section widgets
    ├── shop/           → ShopScreen, ProductDetailScreen
    ├── cart/           → CartScreen
    ├── wishlist/       → WishlistScreen
    ├── checkout/       → CheckoutScreen (3-step)
    ├── orders/         → OrdersScreen
    └── profile/        → ProfileScreen
```

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Android Studio / VS Code
- Node.js backend running on port 5000

### Run the Backend
```bash
cd "c:\RR CREATION\giftswale.com\backened"
npm run dev
```

### Run the App
```bash
cd "c:\RR CREATION\giftswaleApp"
flutter run
```

> **Note:** The Android emulator uses `10.0.2.2` to reach the host machine's `localhost`. This is already configured in `ApiConstants.baseUrl`.

## Design System

The app mirrors GiftsWale.com's design system:
- **Primary**: `#516F2C` (Olive Green)
- **Backgrounds**: White + warm stone tones
- **Typography**: System font with weight scale
- **Borders**: Subtle `rgba(0,0,0,0.08)`
- **Shadows**: 3-level elevation system
