# 🌱 PassiVerdi - "Ogni passo conta"

![Platform](https://img.shields.io/badge/platform-iOS%2017.0%2B%20%7C%20watchOS%2010.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

**PassiVerdi** è un'applicazione iOS e watchOS che incentiva comportamenti sostenibili attraverso gamification, tracking automatico degli spostamenti e un sistema di ricompense basato su punti verdi.

---

## 📋 Indice

- [Vision](#-vision)
- [Features](#-features)
- [Architettura](#-architettura)
- [Requisiti](#-requisiti)
- [Installazione](#-installazione)
- [Struttura del Progetto](#-struttura-del-progetto)
- [Tecnologie Utilizzate](#-tecnologie-utilizzate)
- [Configurazione](#-configurazione)
- [Build e Run](#-build-e-run)
- [Testing](#-testing)
- [Roadmap](#-roadmap)
- [Contribuire](#-contribuire)
- [Licenza](#-licenza)

---

## 🎯 Vision

Creare un'app che:
- **Misura** l'impatto ambientale personale in base alle scelte quotidiane
- **Incoraggia** piccoli gesti sostenibili attraverso obiettivi, sfide e ricompense
- **Coinvolge** il territorio con una rete di enti, negozi e associazioni per premi "green"

### Idea Chiave
Trasformare la sostenibilità in un **gioco di comunità**:
- Ogni utente accumula "punti verdi" per azioni eco-friendly
- I punti possono essere scambiati con premi locali
- L'app crea classifiche comunali per favorire competizione sana e sensibilizzazione

---

## ✨ Features

### 📱 iPhone App

#### Core Features
- **Tracking Automatico**: Rilevamento automatico degli spostamenti via GPS e CoreMotion
- **Riconoscimento Mezzo**: Identifica se stai camminando, pedalando, usando mezzi pubblici o auto
- **Sistema Punti**: Guadagna punti verdi per ogni km percorso in modo sostenibile
  - 🚶 A piedi: 10 punti/km
  - 🚴 Bicicletta: 8 punti/km
  - 🚌 Trasporto pubblico: 5 punti/km
- **Badge & Achievements**: Sistema di badge sbloccabili con progressione
- **Streak System**: Bonus punti per giorni consecutivi di attività
- **Dashboard Completa**: Visualizzazione di punti, km percorsi, CO₂ risparmiata
- **Statistiche Dettagliate**: Analisi per periodo con grafici e insights
- **Profilo Utente**: Gestione informazioni personali e impostazioni

#### Funzionalità Avanzate
- **CloudKit Integration**: Backup automatico su iCloud
- **Calcolo CO₂**: Stima precisa della CO₂ risparmiata rispetto all'uso dell'auto
- **Sistema Livelli**: Progressione automatica ogni 100 punti
- **Impatto Ambientale**: Equivalenze comprensibili (alberi piantati, benzina risparmiata)

### ⌚ Apple Watch App

- **Sincronizzazione Real-time**: Dati sempre aggiornati dall'iPhone
- **Statistiche Giornaliere**: Punti, km e CO₂ a portata di polso
- **Widget Complicazioni**: Visualizzazione rapida dei progressi
- **Design Ottimizzato**: UI pensata per lo schermo piccolo del Watch
- **Notifiche Motivazionali**: Promemoria e congratulazioni

---

## 🏗 Architettura

### Pattern Architetturale
Il progetto utilizza **MVVM (Model-View-ViewModel)** con:
- **SwiftUI** per tutte le interfacce
- **Combine** per reactive programming
- **@ObservableObject** per state management

### Componenti Principali

```
PassiVerdi/
├── App/
│   └── PassiVerdiApp.swift          # Entry point
├── Models/
│   ├── UserProfile.swift            # Modello profilo utente
│   ├── Activity.swift               # Modello attività
│   └── Badge.swift                  # Modello badge
├── Views/
│   ├── OnboardingView.swift         # Onboarding nuovi utenti
│   ├── DashboardView.swift          # Dashboard principale
│   ├── StatisticsView.swift         # Statistiche dettagliate
│   ├── BadgesView.swift             # Visualizzazione badge
│   └── ProfileView.swift            # Profilo utente
├── Managers/
│   ├── LocationManager.swift        # Gestione GPS
│   ├── MotionManager.swift          # Gestione sensori movimento
│   ├── PointsManager.swift          # Sistema punti e gamification
│   ├── WatchConnectivityManager.swift # Sincronizzazione Watch
│   └── CloudKitManager.swift        # Sincronizzazione iCloud
└── Resources/
    ├── Assets.xcassets              # Immagini e colori
    └── Info.plist                   # Configurazione app
```

---

## 📋 Requisiti

### Sistema
- **macOS**: Sequoia 15.6 o superiore
- **Xcode**: 15.0 o superiore
- **iOS Deployment Target**: 17.0+
- **watchOS Deployment Target**: 10.0+

### Hardware per Testing
- iPhone con iOS 17.0+
- Apple Watch con watchOS 10.0+ (opzionale)

### Account
- Apple Developer Account (per testing su dispositivo)
- iCloud Account (per funzionalità CloudKit)

---

## 🚀 Installazione

### 1. Clone del Repository

```bash
git clone https://github.com/ManuelTestoni/PassiVerdi.git
cd PassiVerdi
```

### 2. Apri il Progetto in Xcode

```bash
open PassiVerdi.xcodeproj
```

### 3. Configura Signing & Capabilities

1. Seleziona il target **PassiVerdi**
2. Vai su **Signing & Capabilities**
3. Seleziona il tuo **Team**
4. Modifica il **Bundle Identifier** (es. `com.tuonome.passiverdi`)

Ripeti per il target **PassiVerdi Watch App**.

### 4. Configura CloudKit

1. In **Signing & Capabilities** > **iCloud**
2. Assicurati che **CloudKit** sia abilitato
3. Verifica il **Container**: `iCloud.com.passiverdi.app` (o il tuo custom)

---

## 📁 Struttura del Progetto

```
PassiVerdi/
├── PassiVerdi.xcodeproj/           # File progetto Xcode
├── PassiVerdi/                      # App iOS
│   ├── PassiVerdiApp.swift         # Entry point iOS
│   ├── ContentView.swift           # Vista principale con TabView
│   ├── Models/                     # Modelli dati
│   ├── Views/                      # Viste SwiftUI
│   ├── Managers/                   # Business logic
│   ├── Assets.xcassets/            # Risorse grafiche
│   ├── Info.plist                  # Configurazione app
│   └── PassiVerdi.entitlements     # Entitlements (iCloud, etc)
├── PassiVerdi Watch App/           # App watchOS
│   ├── PassiVerdiWatchApp.swift   # Entry point Watch
│   ├── WatchContentView.swift     # Vista principale Watch
│   └── Assets.xcassets/           # Risorse Watch
└── README.md                       # Questo file
```

---

## 🛠 Tecnologie Utilizzate

### Frameworks Apple

| Framework | Utilizzo |
|-----------|----------|
| **SwiftUI** | UI dichiarativa per iOS e watchOS |
| **CoreLocation** | Tracking GPS e localizzazione |
| **CoreMotion** | Sensori movimento e rilevamento attività |
| **MapKit** | Mappe e visualizzazione coordinate |
| **CloudKit** | Backup e sincronizzazione iCloud |
| **WatchConnectivity** | Comunicazione iPhone ↔ Watch |
| **Combine** | Reactive programming |
| **Charts** | Grafici statistiche (iOS 16+) |

### Pattern e Architetture
- **MVVM** (Model-View-ViewModel)
- **Singleton Pattern** (Managers)
- **Observer Pattern** (Combine, @Published)
- **Dependency Injection** (EnvironmentObject)

---

## ⚙️ Configurazione

### Permessi Richiesti

Il file `Info.plist` include le seguenti richieste di permesso:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>PassiVerdi usa la tua posizione per tracciare gli spostamenti sostenibili.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>PassiVerdi usa la tua posizione per tracciare gli spostamenti sostenibili.</string>

<key>NSMotionUsageDescription</key>
<string>PassiVerdi usa i sensori di movimento per rilevare il tipo di trasporto.</string>
```

### Entitlements

- **iCloud**: CloudKit container
- **Background Modes**: Location updates
- **App Groups**: Condivisione dati tra app e watch

---

## 🏃 Build e Run

### Build per iPhone

1. Seleziona il target **PassiVerdi**
2. Scegli un simulatore iPhone o dispositivo fisico
3. Premi **Cmd + R** o clicca sul pulsante Play

### Build per Apple Watch

1. Seleziona il target **PassiVerdi Watch App**
2. Scegli un simulatore Watch abbinato a un iPhone
3. Premi **Cmd + R**

### Build Contemporaneo (iPhone + Watch)

1. Seleziona il target **PassiVerdi**
2. Il Watch si installerà automaticamente come dipendenza

---

## 🧪 Testing

### Test Manuali

#### Test Tracking GPS
1. Avvia l'app in simulatore o dispositivo
2. Nel simulatore: **Features > Location > City Run**
3. Verifica che venga tracciata la distanza

#### Test Aggiunta Attività
1. Nella **Dashboard**, tap sul menu (⋯)
2. Seleziona "Aggiungi attività test"
3. Verifica che i punti aumentino

#### Test Badge
1. Accumula punti attraverso attività
2. Vai su **Badge**
3. Verifica la progressione verso i badge

#### Test Sincronizzazione Watch
1. Avvia sia app iPhone che Watch
2. Aggiungi un'attività sull'iPhone
3. Verifica che si aggiorni sul Watch

### Unit Test (Future)
```bash
# Da implementare
Cmd + U
```

---

## 🗺 Roadmap

### Fase 1 - MVP Base ✅ (Completata)
- [x] Registrazione utente e profilo
- [x] Tracking GPS e movimento
- [x] Sistema punti e badge
- [x] Dashboard e statistiche
- [x] Integrazione Apple Watch
- [x] Sincronizzazione CloudKit

### Fase 2 - Partnership (3-6 mesi)
- [ ] Sistema premi con esercizi locali
- [ ] Mappe interattive punti verdi
- [ ] QR Code per validazione premi
- [ ] Integrazione comuni (open data)

### Fase 3 - Espansione (6-12 mesi)
- [ ] Backend scalabile (Firebase/Supabase)
- [ ] Sistema challenge e competizioni
- [ ] Classifiche comunali
- [ ] Social features (amici, squadre)
- [ ] Integrazione HealthKit completa

### Fase 4 - Scalabilità Nazionale (12+ mesi)
- [ ] Collaborazioni con ONG
- [ ] API pubbliche per terze parti
- [ ] Widget iOS 18
- [ ] Live Activities
- [ ] Vision Pro support

---

## 🤝 Contribuire

Contributi, issue e feature request sono benvenuti!

### Come Contribuire

1. **Fork** il progetto
2. Crea un **branch** per la feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** i cambiamenti (`git commit -m 'Add some AmazingFeature'`)
4. **Push** al branch (`git push origin feature/AmazingFeature`)
5. Apri una **Pull Request**

### Coding Guidelines

- Seguire le convenzioni Swift standard
- Commentare codice complesso
- Usare nomi descrittivi per variabili e funzioni
- Mantenere funzioni sotto le 50 righe
- Scrivere unit test per nuove feature

---

## 📝 Licenza

Questo progetto è rilasciato sotto licenza MIT. Vedi il file [LICENSE](LICENSE) per i dettagli.

---

## 👥 Team

**PassiVerdi** è sviluppato da Manuel Testoni.

### Contatti
- GitHub: [@ManuelTestoni](https://github.com/ManuelTestoni)
- Repository: [PassiVerdi](https://github.com/ManuelTestoni/PassiVerdi)

---

## 🙏 Ringraziamenti

- Apple per gli eccellenti framework e documentazione
- La community Swift per supporto e ispirazione
- Tutti i beta tester che aiuteranno a migliorare l'app

---

## 📸 Screenshots

> Coming soon - Screenshots verranno aggiunti dopo il primo build

---

## 🐛 Known Issues

### iOS Simulator
- Il tracking GPS potrebbe non funzionare perfettamente: usa "City Run" in Features > Location
- CoreMotion activity detection limitata su simulatore

### Apple Watch Simulator
- La sincronizzazione potrebbe essere più lenta rispetto a dispositivi fisici

---

## 💡 Tips & Tricks

### Per Sviluppatori

**Debug Tracking:**
```swift
// In LocationManager.swift, abilita logging dettagliato
print("📍 Location: \(location.coordinate)")
```

**Reset Dati di Test:**
- Vai su Profilo > Reset Dati
- Oppure elimina e reinstalla l'app

**Test Badge Veloce:**
- Usa il pulsante "Aggiungi attività test" nella Dashboard
- Oppure modifica i requisiti in `Badge.swift`

### Per Utenti

**Ottimizza Batteria:**
- Il tracking GPS consuma batteria
- Disattiva "Tracking Automatico" quando non serve

**Migliora Accuracy:**
- Abilita "Posizione Precisa" nelle impostazioni iOS
- Usa l'app all'aperto per miglior segnale GPS

---

## 🔄 Changelog

### v1.0.0 - 07/10/2025
- 🎉 Release iniziale MVP
- ✨ Tracking automatico spostamenti
- ⭐ Sistema punti e badge
- 📊 Dashboard e statistiche
- ⌚ Integrazione Apple Watch
- ☁️ Sincronizzazione iCloud

---

**Made with 💚 for a sustainable future**
