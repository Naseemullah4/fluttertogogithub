# UniWash Laundry & Dry Cleaning Platform 🧺✨

Professional On-Demand Laundry & Dry Cleaning Multi-Portal Ecosystem built with **Flutter** (iOS, Android, Web & Desktop).

---

## 🌟 Ecosystem Architecture (5 Modules in One Unified Solution)

The ecosystem is partitioned into:
- 📱 **Mobile Apps**: Customer Mobile App & Driver Mobile Dispatch App
- 💻 **Browser Web Portals**: Super Admin Global Portal, Regional Operations Admin Portal, Laundry Dashboard & Worker Web App (Designed for Laptops, Apple MacBooks, iMacs & Desktop PCs).

```
                              ┌────────────────────────────────────────┐
                              │  SUPER ADMIN GLOBAL WEB PORTAL 💻       │
                              │  (Pricing, Per KG/Pcs, Sales, 15 Reg)  │
                              └───────────────────┬────────────────────┘
                                                  │
                              ┌───────────────────┴────────────────────┐
                              │    REGIONAL ADMIN WEB PORTAL 💻        │
                              │   (Qatar Operations, Warnings, TM)     │
                              └───────────────────┬────────────────────┘
                                                  │
         ┌────────────────────────────────────────┼────────────────────────────────────────┐
         │                                        │                                        │
┌────────┴───────────────┐               ┌────────┴───────────────┐               ┌────────┴───────────────┐
│ CUSTOMER MOBILE APP 📱 │               │ DRIVER MOBILE APP 📱   │               │ LAUNDRY WEB PORTAL 💻  │
│ (Catalog, Sales, Cart) │               │ (Live Route, QR Pick)  │               │ (Thermal Print, Count) │
└────────────────────────┘               └────────────────────────┘               └────────────────────────┘
```

---

## ⚡ What's New in This Version:

### 1. 🏷️ Super Admin Live Pricing & Sale Manager
- **Price Adjustment (Up & Down)**:
  - Super Admin can adjust any item's price up or down with 1 tap (`+1 QAR`, `-1 QAR`, `+5 QAR`, `-5 QAR`) or type custom prices.
- **Per KG & Per Piece Dual Pricing Modes**:
  - Super Admin can set whether each item/service is billed **Per Item (Pcs)** OR **By Weight / Per KG (KG)**.
  - In Customer App: When ordering KG items (e.g. Daily Wash & Fold, Bedding, Curtains), customers select weight (1.0 KG, 2.5 KG, 5.0 KG, etc.), and prices scale dynamically!
- **Sales & Discount Pricing**:
  - Super Admin can activate discounts (e.g. 10%, 20%, 30%, 50% OFF).
  - In Customer App: Original price is displayed with a red strikethrough (e.g. ~~15 QAR~~) alongside the bold discounted price and a discount badge (`20% OFF`).
- **Special Offer Badges**:
  - Super Admin can set special offer tags on any item (e.g. `"RAMADAN 50% OFF"`, `"HOT DEAL"`, `"TOP SELLER"`, `"WEEKEND SPECIAL"`).
- **Custom Icon / Emoji Picker**:
  - Super Admin can customize the garment icon or emoji for every single item.
- **Exclusive Privileges**:
  - Only **Super Admin** has access to the Catalog & Pricing Manager tab. Changes synchronize instantaneously across all connected portals.

---

### 2. 💻 Browser Web App Edition for Laptops & Desktop PCs
- **Super Admin Global Portal (Web Edition)**:
  - Wide-screen desktop layout optimized for Apple MacBook, iMac, and PC browsers.
  - Real-time catalog editor table, 15 country analytics, GMV tracking, and staff approval queue.
- **Regional Admin Operations Web Portal**:
  - Dedicated browser workspace for Qatar operations, escalation warnings, driver credentials generation, and TM agreements.
- **Laundry Dashboard & Worker Web App**:
  - Tablet and laptop browser-ready order fulfillment screen with manual count verification and 80mm ESC/POS thermal invoice printing.

---

## 📱 Detailed Modules

### 1. Customer Mobile App
- **Live Catalog with Sales & Per KG tags**:
  - Displays sale badges, discount strikethroughs, and `/kg` or `/item` pricing indicators.
  - Category filters: All, Wash & Fold, Tops, Bottoms, Suits, Dresses, Traditional, Kids, Outerwear, Home Items, Accessories, Bathroom.
- **Item Detail Sheet**:
  - Treatment selection: *Wash & Iron*, *Iron Only*, *Dry Clean*, *Only Wash*.
  - Quantity picker (1, 2, 3...) or Weight picker (0.5 KG, 1.0 KG, 2.0 KG, 5.0 KG...).
  - Special garment care instructions.
- **Dynamic Basket & Checkout**:
  - POS Card on delivery or Cash on delivery.
  - Door-to-door delivery fee (15 QAR) and subtotal breakdown.
- **7-State Live Order Stepper**:
  - `Order Placed` ➔ `Driver Assigned` ➔ `Picked Up / Received by Laundry` ➔ `In Washing/Dry Cleaning` ➔ `Order Ready for Delivery` ➔ `Out for Delivery` ➔ `Delivered`.
- **Order QR Code Generator**:
  - Instant `UNIWASH-ORD-XXXX` QR code for pickup driver collection verification.
- **Referral Campaign & Help Desk**:
  - "Invite 3 friends, get 100 QAR credit" progress tracker.
  - Live In-App Chat with Driver/Support & WhatsApp bridge.

### 2. Driver Mobile App
- **Fleet Dispatch Console**:
  - Online/Offline availability toggle with GPS live transmission.
  - Active missions list with order addresses and customer contact.
- **Interactive Mission Navigation**:
  - Step-by-step driver workflow: `Start Ride` ➔ `Reached` (activates Call Customer) ➔ `Scan Customer QR Code & Collect` ➔ `Dispatch to Laundry` ➔ `Start Delivery Ride` ➔ `Mark Delivered`.
- **Driver Diagnostics**:
  - Incident filing with photo upload (traffic breakdown, pre-existing garment tears).
  - Performance dashboard: rating (⭐ 4.9), trips count, daily earnings (QAR).

### 3. Laundry Dashboard & Worker Web App 💻
- **Order Queue & Manual Count Verification**:
  - Item-by-item manual count check and quantity adjustment before washing.
- **Status Switches**:
  - Progress orders through Washing, Dry Cleaning, and Pressing to Ready for Delivery.
- **ESC/POS Thermal Invoice Printing**:
  - 80mm POS receipt preview with Laundry name, CR number, QR code, itemized breakdown, and VAT.
  - Direct output triggers for **USB Thermal (ESC/POS raw bytes)** and **Bluetooth Mobile Printers**.
- **Financial Analytics & Driver Recruitment**:
  - Reports across Daily, Weekly, Monthly, Yearly, and Lifetime date ranges.
  - Driver onboarding application submission with Passport, Visa, License, and Photo attachments.

### 4. Regional Admin Operations Web Portal 💻 (Qatar 🇶🇦)
- **Warning Escalation Matrix**:
  - `None (Good Standing)` ➔ `Light Yellow` ➔ `Yellow` ➔ `Light Red` ➔ `Full Red` ➔ `Account Termination`.
- **TM Legal Agreement Onboarding**:
  - Standardized contract terms: 15% platform royalty, 100% delivery fees to platform, $55 USD/day early cancellation penalty, 2 working days advance notice policy.
- **Driver Credential Generation & Staff Management**:
  - Issue system logins and submit internal staff applications for Super Admin sign-off.

### 5. Super Admin Global Web Portal 💻 (15 Territories)
- **Catalog & Pricing Manager**:
  - Real-time price editing, Per KG / Per Piece unit toggling, sale discounts %, special offer tags, and emoji customization.
- **15 Global Territories**:
  - 🇶🇦 Qatar, 🇦🇪 UAE, 🇸🇦 Saudi Arabia, 🇰🇼 Kuwait, 🇴🇲 Oman, 🇧🇭 Bahrain, 🇬🇧 UK, 🇺🇸 US, 🇨🇦 Canada, 🇪🇺 Europe, 🇸🇬 Singapore, 🇲🇾 Malaysia, 🇵🇰 Pakistan, 🇮🇳 India, 🇿🇦 South Africa.
- **Master Financials & Approvals Queue**:
  - Platform royalties audit, escrow reserves, and regional staff authorization.

---

## 🚀 How to Run

### 1. Launch in Browser (Laptop / Mac / PC Web App)
```bash
flutter run -d chrome
```

### 2. Launch on Connected Android Device
```bash
flutter run -d adb-111232543L001251-6lPrLY
```

### 3. Run Automated Tests
```bash
flutter test
```
