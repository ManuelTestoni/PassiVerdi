# Struttura Progetto PassiVerdi

Questa è la struttura completa del progetto PassiVerdi con spiegazioni.

## 📁 Struttura completa

```
PassiVerdi/
│
├── .git/                                    # Git repository
├── .gitignore                               # File ignorati da Git
├── LICENSE                                  # Licenza MIT
├── README.md                                # Documentazione principale
├── GETTING_STARTED.md                       # Guida per iniziare
├── DEVELOPER_GUIDE.md                       # Guida sviluppatore
│
├── PassiVerdi.xcodeproj/                    # Progetto Xcode (da creare)
│   ├── project.pbxproj
│   └── xcshareddata/
│
├── PassiVerdi/                              # Main iOS App
│   │
│   ├── PassiVerdiApp.swift                  # ⭐ Entry point dell'app
│   ├── ContentView.swift                    # Root view con routing
│   │
│   ├── Models/                              # 📦 Data Models
│   │   ├── User.swift                       # Modello utente
│   │   ├── Activity.swift                   # Modello attività (spostamenti)
│   │   ├── Badge.swift                      # Modello badge e achievement
│   │   └── Challenge.swift                  # Modello sfide
│   │
│   ├── Managers/                            # 🧠 Business Logic (ViewModels)
│   │   ├── AuthenticationManager.swift      # Gestione autenticazione
│   │   ├── UserManager.swift                # Gestione dati utente
│   │   ├── TrackingManager.swift            # GPS e tracking spostamenti
│   │   └── PointsManager.swift              # Calcolo punti e badge
│   │
│   ├── Views/                               # 🎨 UI Components
│   │   │
│   │   ├── Onboarding/                      # Schermate onboarding
│   │   │   ├── OnboardingView.swift         # Tutorial iniziale
│   │   │   ├── LoginView.swift              # Schermata login
│   │   │   └── SignUpView.swift             # Registrazione utente
│   │   │
│   │   ├── Main/                            # Struttura principale
│   │   │   └── MainTabView.swift            # TabBar principale
│   │   │
│   │   ├── Dashboard/                       # Dashboard (Home)
│   │   │   └── DashboardView.swift          # Panoramica punti e statistiche
│   │   │
│   │   ├── Tracking/                        # Tracking spostamenti
│   │   │   ├── TrackingView.swift           # Tracking in tempo reale
│   │   │   └── ManualEntryView.swift        # Inserimento manuale attività
│   │   │
│   │   ├── Challenges/                      # Sfide
│   │   │   └── ChallengesView.swift         # Lista sfide attive
│   │   │
│   │   ├── Leaderboard/                     # Classifica
│   │   │   └── LeaderboardView.swift        # Classifica utenti
│   │   │
│   │   └── Profile/                         # Profilo utente
│   │       ├── ProfileView.swift            # Pagina profilo
│   │       └── EditProfileView.swift        # Modifica profilo
│   │
│   ├── Assets.xcassets/                     # Risorse grafiche
│   │   ├── AppIcon.appiconset/              # Icona app
│   │   ├── AccentColor.colorset/            # Colore principale
│   │   └── Colors/                          # Palette colori
│   │
│   ├── Info.plist                           # Configurazione app
│   └── PassiVerdi.entitlements              # Capabilities (CloudKit, ecc)
│
├── PassiVerdi Watch Watch App/              # ⌚ Apple Watch App
│   │
│   ├── PassiVerdi_WatchApp.swift            # Entry point Watch
│   ├── WatchConnectivityManager.swift       # Sincronizzazione iPhone↔Watch
│   ├── WatchMainView.swift                  # View principale Watch
│   │
│   ├── Assets.xcassets/                     # Risorse Watch
│   │   └── AppIcon.appiconset/
│   │
│   └── Info.plist                           # Configurazione Watch
│
├── PassiVerdiTests/                         # 🧪 Unit Tests
│   ├── PassiVerdiTests.swift
│   ├── UserManagerTests.swift
│   └── TrackingManagerTests.swift
│
└── PassiVerdiUITests/                       # 🎭 UI Tests
    ├── PassiVerdiUITests.swift
    └── PassiVerdiUITestsLaunchTests.swift
```

## 📝 Spiegazione dei componenti

### 🎯 App Entry Point

**PassiVerdiApp.swift**
- Punto di ingresso dell'app
- Inizializza i Manager (@StateObject)
- Configura l'Environment

```swift
@main
struct PassiVerdiApp: App {
    @StateObject private var authManager = AuthenticationManager()
    // ...
}
```

### 📦 Models (Dati)

**User.swift** - Struttura dati utente
```swift
struct User {
    var id, email, name, city
    var totalPoints, totalKilometers, totalCO2Saved
    var badges: [Badge]
}
```

**Activity.swift** - Traccia spostamenti
```swift
struct Activity {
    var transportType: TransportType
    var distance, duration, co2Saved, pointsEarned
}
```

**Badge.swift** - Sistema achievement
```swift
struct Badge {
    var type: BadgeType
    var earnedDate
    var isUnlocked
}
```

**Challenge.swift** - Sfide giornaliere/settimanali
```swift
struct Challenge {
    var title, description
    var targetValue, currentValue
    var reward, isCompleted
}
```

### 🧠 Managers (Business Logic)

**AuthenticationManager**
- Login/Logout
- Sign in with Apple
- Gestione sessione

**UserManager**
- CRUD dati utente
- Lista attività
- Aggiornamento profilo

**TrackingManager**
- GPS tracking (CoreLocation)
- Rilevamento tipo trasporto (CoreMotion)
- Start/Stop tracking

**PointsManager**
- Calcolo punti per attività
- Assegnazione badge
- Logica gamification

### 🎨 Views (UI)

#### Onboarding Flow
1. **OnboardingView** → Tutorial a slide
2. **LoginView** → Login esistente
3. **SignUpView** → Nuovo account

#### Main App Flow (TabBar)
1. **Dashboard** → Panoramica (Home)
2. **Tracking** → Traccia spostamenti
3. **Challenges** → Sfide attive
4. **Leaderboard** → Classifica
5. **Profile** → Profilo personale

### ⌚ Apple Watch

**PassiVerdi_WatchApp.swift**
- Entry point Watch

**WatchConnectivityManager**
- Sincronizzazione bidirezionale iPhone↔Watch
- Utilizza WatchConnectivity framework

**WatchMainView**
- Dashboard compatta
- Visualizzazione punti giornalieri
- Notifiche motivazionali

## 🔗 Flusso dati

```
User Input → View → Manager → Model
              ↓       ↓
           Update   Save to
             UI    Storage
```

### Esempio pratico:

```
1. Utente preme "Start Tracking"
   ↓
2. TrackingView chiama trackingManager.startTracking()
   ↓
3. TrackingManager usa CoreLocation per tracciare
   ↓
4. Al termine, crea un Activity e lo passa a UserManager
   ↓
5. UserManager salva Activity e aggiorna User
   ↓
6. View si aggiorna automaticamente (@Published)
```

## 🎯 Funzionalità implementate

### ✅ Fase 1 - MVP
- [x] Autenticazione (Sign in with Apple, Email)
- [x] Tracking GPS e classificazione automatica
- [x] Inserimento manuale attività
- [x] Dashboard con statistiche
- [x] Grafici settimanali (Swift Charts)
- [x] Sistema punti e badge
- [x] Sfide giornaliere/settimanali
- [x] Classifica locale
- [x] Profilo utente con modifica
- [x] Integrazione Apple Watch

### 🔄 Da implementare (Fase 2)
- [ ] CloudKit per sincronizzazione cloud
- [ ] CoreData per persistenza locale
- [ ] Notifiche push
- [ ] Mappe con POI ecologici
- [ ] Social sharing
- [ ] Widget iOS e watchOS

## 📱 Tecnologie utilizzate

| Framework | Utilizzo |
|-----------|----------|
| SwiftUI | Interfaccia utente |
| CoreLocation | GPS tracking |
| CoreMotion | Rilevamento attività |
| Swift Charts | Grafici e visualizzazioni |
| WatchConnectivity | Sincronizzazione Watch |
| CloudKit | Backend (futuro) |
| CoreData | Persistenza locale (futuro) |
| HealthKit | Dati salute (futuro) |

## 🎓 Per studenti

### Cosa imparare da ogni file:

**PassiVerdiApp.swift**
- App lifecycle
- Dependency injection con @StateObject
- Environment objects

**Models/**
- Strutture dati
- Codable per serializzazione
- Computed properties
- Enums con associated values

**Managers/**
- MVVM pattern
- @Published e Combine
- async/await
- Delegates (CLLocationManager, WCSession)

**Views/**
- SwiftUI components
- State management (@State, @Binding, @EnvironmentObject)
- Navigation (NavigationStack, TabView)
- Custom modifiers
- Preview providers

## 🚀 Come estendere il progetto

### Aggiungere un nuovo tipo di trasporto:
1. Modifica `TransportType` in `Activity.swift`
2. Aggiungi logica in `TrackingManager.swift`
3. Aggiorna UI in `TrackingView.swift`

### Aggiungere un nuovo badge:
1. Aggiungi case in `BadgeType` in `Badge.swift`
2. Implementa logica in `PointsManager.swift`
3. Aggiorna UI in `ProfileView.swift`

### Aggiungere una nuova schermata:
1. Crea file Swift in `Views/NuovaCartella/`
2. Aggiungi tab in `MainTabView.swift`
3. Implementa la View con SwiftUI

## 💡 Best Practices nel codice

1. **Separazione responsabilità**: View ≠ Logic
2. **Nomi descrittivi**: `calculateTotalPoints()` non `calc()`
3. **Type safety**: Usa enums invece di String
4. **Async/await**: Invece di completion handlers
5. **Commenti**: Spiega il "perché", non il "cosa"

---

Per domande sulla struttura, consulta `DEVELOPER_GUIDE.md` o apri una issue su GitHub.

**Happy Coding! 🌱💻**
