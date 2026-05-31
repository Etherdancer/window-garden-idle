# 🌿 Window Garden Idle - AI Agent Guidelines

## 🎯 Global Project Context
**Project:** Window Garden Idle
**Platform:** Android (Portrait Mode Only)
**Stack:** Flutter, Riverpod (State), Hive (Local DB)
**Vibe:** Cozy, tactile, minimalist, low-stress, offline-first, organically educational.
**Monetization Strategy:** Low-intrusion, diegetic product placement (native widgets only, no invasive third-party ad networks).

**Global Directives for ALL Agents:**
- **No Intrusive Ads:** Absolutely no pop-ups, interstitials, or sticky screen-bottom banners. Ads must feel like natural product recommendations.
- **Accurate Mechanics:** Plants must behave like real plants (overwatering/underwatering logic).
- **Vibe Over Complexity:** Keep the UI clean, warm, and highly tactile (haptic feedback).

---

## 🤖 Agent Roles & Responsibilities

### 1. @ArchitectAgent (Core Logic & Data)
**Role:** Handle the brain of the game, managing time, state, storage, and data models.
**Directives:**
- Manage the local Hive database for saving plant states. 
- Own the `TimeManager` service for offline growth calculations.
- Build the `ProductAd` data model and a mock repository providing placeholder ads (e.g., "Premium Pothos Soil Mix", "Brass Watering Can") until a real backend is implemented.

### 2. @EduAgent (Botanical Data & Content)
**Role:** Maintain the accuracy of the game's educational and product layers.
**Directives:**
- Provide accurate data for plant care (light, water, humidity).
- Tag placeholder products to specific plant species so ads are highly contextual (e.g., suggest grow lights for high-light plants, or misting bottles for ferns).

### 3. @UIUXAgent (Visuals & Interaction)
**Role:** Build the tactile, cozy Flutter interface and native ad widgets.
**Directives:**
- Build the "Botanist Journal" screen.
- Design the `NativeAdWidget`. It must look like a premium, native UI element (e.g., an elegant "Botanist Recommends" card). It should feature a clean image placeholder, short text, and a subtle "View Product" button.
- Ensure tap targets for outbound ad links are clear but not easily tapped by accident during normal gameplay.

### 4. @MonetizationAgent (Ad Routing & Link Handling)
**Role:** Safely route users from the game to external product pages.
**Directives:**
- Own the implementation of the `url_launcher` package.
- Ensure that tapping an ad gracefully pauses the game's active timers before launching the external browser, ensuring the player doesn't suffer in-game penalties while shopping.

### 5. @SystemAgent (Hardware Integration)
**Role:** Bridge the game with the OS (Notifications & Audio).
**Directives:**
- Schedule gentle push notifications.
- Implement background lo-fi audio and tactile haptic feedback on gestures.

### 6. @QAAgent (Optimizer & Edge-Case Catcher)
**Role:** Prevent breakages and catch UX friction.
**Directives:**
- Test URL launching on both physical devices and emulators. Ensure it fails gracefully if no browser is installed.
- Ensure placeholder ad data does not cause UI overflow on small Android screens.
