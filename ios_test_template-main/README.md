# 📋 Pokemon Viewer — README

## 🎯 Goal
- iOS app in Swift using UIKit and code-based AutoLayout
- Display Pokémon list and details for a selected Pokémon
- Focus: architecture, code quality, Favorites, image loading and in-memory caching
- No 3rd-party libraries

---

## 📱 Screen 1 — Pokémon List

**Navigation Bar:** title + Favorites icon with counter  

**List items:** image, name, ID, Favorite icon, Delete icon  

**Logic:**
- Show activity indicator for a loading image
- Pagination/lazy loading
- Add/remove from Favorites
- Delete items
- Navigate to details on click

---

## 📱 Screen 2 — Pokémon Details

**Content:** Pokémon image, name, height, weight, Favorite icon  

**Logic:**
- Add/remove from Favorites
- Synchronized with list screen

---

## 🔄 General Logic
- Images loaded and cached in memory only (max 20 images; oldest removed when adding new)
- Custom in-memory cache handles image downloading and caching without 3rd-party libraries
- Favorites state shared across both screens
- Functional UI (simplified is acceptable)

---

## ✅ Expectations
- Clean architecture (MVVM/MVP or other)
- Working custom in-memory image cache with downloading
- Correct UI behavior for Favorites and deletions

---

## ⭐ Bonus (optional)
- Unit tests
- Error handling

## 📋 Pokemons API
This template includes a PokemonsService that provides all the essential methods to kickstart your app development. Feel free to adapt or implement your own version to suit specific needs

---

## ⏱ Estimated time
1.5–2 hours
