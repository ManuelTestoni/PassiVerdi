# Guida allo Sviluppo - PassiVerdi

## 📚 Indice
1. [Introduzione](#introduzione)
2. [Setup del progetto](#setup-del-progetto)
3. [Architettura MVVM](#architettura-mvvm)
4. [Struttura del codice](#struttura-del-codice)
5. [Componenti principali](#componenti-principali)
6. [Testing](#testing)
7. [Best Practices](#best-practices)

## Introduzione

PassiVerdi è un'applicazione iOS/watchOS sviluppata in **Swift e SwiftUI** che aiuta gli utenti a tracciare il loro impatto ambientale attraverso la mobilità sostenibile.

### Obiettivi di apprendimento
- Padroneggiare **SwiftUI** e il suo ecosistema
- Implementare il pattern **MVVM**
- Gestire **CoreLocation** e **CoreMotion**
- Sincronizzare dati tra **iPhone e Apple Watch**
- Utilizzare **CloudKit** per backend

## Setup del progetto

### Requisiti di sistema
- macOS 14.0+ (Sonoma)
- Xcode 15.0+
- iOS 17.0+ / watchOS 10.0+

### Primo avvio

1. **Apri il progetto**
   ```bash
   cd PassiVerdi
   open PassiVerdi.xcodeproj
   ```

2. **Configura il Bundle Identifier**
   - Target → PassiVerdi → General
   - Cambia il Bundle Identifier con uno unico
   - Esempio: `com.tuonome.PassiVerdi`

3. **Configura Signing & Capabilities**
   - Seleziona il tuo Team
   - Abilita automaticamente le capabilities necessarie

4. **Build & Run**
   - Seleziona un simulatore (iPhone 15 Pro consigliato)
   - Premi `Cmd + R`

## Architettura MVVM

PassiVerdi utilizza il pattern **Model-View-ViewModel**:

```
┌─────────────┐
│    View     │  ← SwiftUI Views (UI)
└─────────────┘
       ↕️
┌─────────────┐
│ ViewModel   │  ← Manager classes (@ObservableObject)
└─────────────┘
       ↕️
┌─────────────┐
│   Model     │  ← Data structures (Struct)
└─────────────┘
```

### Model (Dati)
```swift
struct User: Identifiable, Codable {
    var id: UUID
    var name: String
    var totalPoints: Int
    // ...
}
```

### ViewModel (Logica)
```swift
@MainActor
class UserManager: ObservableObject {
    @Published var currentUser: User?
    
    func updateUserProfile(_ user: User) {
        // Logica di business
    }
}
```

### View (UI)
```swift
struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        Text(userManager.currentUser?.name ?? "")
    }
}
```

## Struttura del codice

### Directory principale

```
PassiVerdi/
│
├── PassiVerdiApp.swift          # Entry point dell'app
├── ContentView.swift            # Root view con routing
│
├── Models/                      # Data models
│   ├── User.swift               # Modello utente
│   ├── Activity.swift           # Modello attività
│   ├── Badge.swift              # Modello badge
│   └── Challenge.swift          # Modello sfide
│
├── Managers/                    # Business logic (ViewModels)
│   ├── AuthenticationManager.swift
│   ├── UserManager.swift
│   ├── TrackingManager.swift
│   └── PointsManager.swift
│
├── Views/                       # UI Components
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── LoginView.swift
│   │   └── SignUpView.swift
│   │
│   ├── Main/
│   │   └── MainTabView.swift
│   │
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   │
│   ├── Tracking/
│   │   ├── TrackingView.swift
│   │   └── ManualEntryView.swift
│   │
│   ├── Challenges/
│   │   └── ChallengesView.swift
│   │
│   ├── Leaderboard/
│   │   └── LeaderboardView.swift
│   │
│   └── Profile/
│       ├── ProfileView.swift
│       └── EditProfileView.swift
│
└── PassiVerdi Watch/            # watchOS app
    ├── PassiVerdi_WatchApp.swift
    ├── WatchConnectivityManager.swift
    └── WatchMainView.swift
```

## Componenti principali

### 1. AuthenticationManager

Gestisce l'autenticazione degli utenti.

```swift
@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserID: String?
    
    func signInWithApple() { }
    func signInWithEmail(email: String, password: String) async { }
    func signUp(email: String, password: String, name: String, city: String) async { }
    func signOut() { }
}
```

**Concetti chiave:**
- `@MainActor` - Garantisce che le modifiche UI avvengano sul main thread
- `@Published` - Notifica automaticamente le view quando i valori cambiano
- `async` - Funzioni asincrone per operazioni di rete

### 2. TrackingManager

Gestisce il tracking GPS e il rilevamento del tipo di trasporto.

```swift
@MainActor
class TrackingManager: NSObject, ObservableObject {
    @Published var isTracking = false
    @Published var currentDistance: Double = 0.0
    
    private let locationManager = CLLocationManager()
    private let motionActivityManager = CMMotionActivityManager()
    
    func startTracking() { }
    func stopTracking() -> Activity? { }
}
```

**Frameworks utilizzati:**
- `CoreLocation` - GPS e tracking posizione
- `CoreMotion` - Rilevamento tipo di attività (camminata, bici, auto)

### 3. UserManager

Gestisce i dati dell'utente e le attività.

```swift
@MainActor
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var activities: [Activity] = []
    
    func addActivity(_ activity: Activity) { }
    func getTodayActivities() -> [Activity] { }
}
```

### 4. PointsManager

Calcola punti e assegna badge.

```swift
@MainActor
class PointsManager: ObservableObject {
    func calculatePoints(for activity: Activity) -> Int { }
    func checkAndAwardBadges(user: User, activities: [Activity]) -> [Badge] { }
}
```

## Testing

### Eseguire i test
```bash
# In Xcode
Cmd + U
```

### Scrivere test

```swift
import XCTest
@testable import PassiVerdi

class UserManagerTests: XCTestCase {
    var userManager: UserManager!
    
    override func setUp() {
        super.setUp()
        userManager = UserManager()
    }
    
    func testAddActivity() {
        let activity = Activity(
            transportType: .cycling,
            distance: 5.0,
            duration: 900,
            startTime: Date(),
            endTime: Date(),
            co2Saved: 0.85,
            pointsEarned: 60
        )
        
        userManager.addActivity(activity)
        XCTAssertEqual(userManager.activities.count, 1)
    }
}
```

## Best Practices

### 1. Naming Conventions

```swift
// ✅ BUONO
var userName: String
func calculateTotalPoints() -> Int
class UserManager

// ❌ CATTIVO
var un: String
func calcPts() -> Int
class UsrMgr
```

### 2. SwiftUI Views

```swift
// ✅ BUONO - View piccole e composte
struct ProfileView: View {
    var body: some View {
        VStack {
            ProfileHeader()
            ProfileStats()
            ProfileSettings()
        }
    }
}

// ❌ CATTIVO - View troppo grandi
struct ProfileView: View {
    var body: some View {
        VStack {
            // 500 righe di codice...
        }
    }
}
```

### 3. State Management

```swift
// ✅ BUONO - State in @ObservableObject
class UserManager: ObservableObject {
    @Published var user: User?
}

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
}

// ❌ CATTIVO - State direttamente nella View
struct ProfileView: View {
    @State private var user: User?  // Non scalabile
}
```

### 4. Async/Await

```swift
// ✅ BUONO
func loadData() async {
    do {
        let data = try await fetchData()
        self.data = data
    } catch {
        print("Error: \(error)")
    }
}

// ❌ CATTIVO - Completion handlers
func loadData(completion: @escaping (Result<Data, Error>) -> Void) {
    // Complesso e difficile da leggere
}
```

### 5. Error Handling

```swift
// ✅ BUONO
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

func fetchData() async throws -> Data {
    guard let url = URL(string: urlString) else {
        throw NetworkError.invalidURL
    }
    // ...
}

// ❌ CATTIVO
func fetchData() -> Data? {
    // Ignora gli errori
}
```

## Prossimi passi

1. **Completare l'integrazione CloudKit**
   - Implementare salvataggio cloud
   - Sincronizzazione tra dispositivi

2. **Aggiungere test**
   - Unit tests per i Manager
   - UI tests per le View

3. **Ottimizzare le performance**
   - Caching delle immagini
   - Lazy loading delle liste

4. **Implementare notifiche push**
   - Motivazione giornaliera
   - Reminder per sfide

## Risorse utili

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [WWDC Videos](https://developer.apple.com/videos/)

## Supporto

Per domande o problemi:
- Apri una [Issue su GitHub](https://github.com/ManuelTestoni/PassiVerdi/issues)
- Consulta la documentazione Apple
- Unisciti alla community Swift

---

Buon coding! 🚀🌱
