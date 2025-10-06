# PassiVerdi

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" />
  <img src="https://img.shields.io/badge/watchOS-10.0+-blue.svg" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" />
  <img src="https://img.shields.io/badge/SwiftUI-✓-green.svg" />
</p>

## 🌱 Descrizione

**PassiVerdi** è un'app iOS e watchOS che trasforma la mobilità sostenibile in un gioco coinvolgente. Traccia i tuoi spostamenti eco-friendly, guadagna punti verdi, sblocca badge e contribuisci a ridurre l'impatto ambientale della tua comunità.

## ✨ Funzionalità principali

### 📱 iPhone
- **Tracking automatico** degli spostamenti tramite GPS e CoreMotion
- **Dashboard personale** con statistiche e grafici
- **Sistema punti e badge** per gamification
- **Sfide giornaliere e settimanali** per incentivare comportamenti sostenibili
- **Classifica** locale per competizione sana
- **Calcolo CO₂ risparmiata** in tempo reale

### ⌚ Apple Watch
- Visualizzazione **punti e km giornalieri**
- **Notifiche motivazionali**
- **Sincronizzazione** continua con iPhone
- **Statistiche rapide** a portata di polso

## 🏗️ Architettura

Il progetto segue il pattern **MVVM (Model-View-ViewModel)** con una struttura modulare e scalabile:

```
PassiVerdi/
├── Models/              # Data models
│   ├── User.swift
│   ├── Activity.swift
│   ├── Badge.swift
│   └── Challenge.swift
├── Managers/            # Business logic
│   ├── AuthenticationManager.swift
│   ├── UserManager.swift
│   ├── TrackingManager.swift
│   └── PointsManager.swift
├── Views/               # UI Components
│   ├── Onboarding/
│   ├── Dashboard/
│   ├── Tracking/
│   ├── Challenges/
│   ├── Leaderboard/
│   └── Profile/
└── PassiVerdi Watch/    # watchOS app
```

## 🛠️ Tecnologie utilizzate

- **Swift 5.9+** e **SwiftUI**
- **CoreLocation** - Tracking GPS
- **CoreMotion** - Rilevamento attività
- **HealthKit** - Integrazione dati salute (futuro)
- **MapKit** - Mappe e visualizzazione percorsi
- **CloudKit** - Backend e sincronizzazione
- **WatchConnectivity** - Sincronizzazione iPhone-Watch
- **Swift Charts** - Grafici e visualizzazioni

## 🚀 Come iniziare

### Prerequisiti
- Xcode 15.0 o superiore
- macOS 14.0 (Sonoma) o superiore
- Account Apple Developer (per test su dispositivo)

### Installazione

1. **Clona il repository**
```bash
git clone https://github.com/ManuelTestoni/PassiVerdi.git
cd PassiVerdi
```

2. **Apri il progetto in Xcode**
```bash
open PassiVerdi.xcodeproj
```

3. **Configura il team di sviluppo**
   - Seleziona il target `PassiVerdi`
   - Vai su "Signing & Capabilities"
   - Seleziona il tuo team

4. **Compila ed esegui**
   - Seleziona il simulatore o dispositivo
   - Premi `Cmd + R` per compilare ed eseguire

## 📋 Permessi richiesti

L'app richiede i seguenti permessi (già configurati in `Info.plist`):

- **Location (Always)** - Per tracking spostamenti in background
- **Motion & Fitness** - Per rilevamento tipo di attività
- **HealthKit** (opzionale) - Per integrazione dati salute

## 🎯 Roadmap

### Fase 1 - MVP (Attuale) ✅
- [x] Struttura base dell'app
- [x] Sistema di autenticazione
- [x] Tracking manuale e automatico
- [x] Dashboard e statistiche
- [x] Sistema punti e badge
- [x] Integrazione Apple Watch

### Fase 2 - Community 🔄
- [ ] Classifica reale con CloudKit
- [ ] Sistema di sfide sociali
- [ ] Condivisione sui social
- [ ] Chat e messaggistica tra utenti

### Fase 3 - Partnership 📅
- [ ] Integrazione mappe POI ecologici
- [ ] Sistema premi con esercenti locali
- [ ] QR Code per validazione premi
- [ ] Dashboard per partner commerciali

### Fase 4 - Espansione 🚀
- [ ] Backend scalabile (Firebase/Supabase)
- [ ] API open data ambientali
- [ ] Widget iOS e watchOS
- [ ] App Clips per onboarding rapido

## 🤝 Come contribuire

Questo è un progetto educativo e di apprendimento. I contributi sono benvenuti!

1. Fork il progetto
2. Crea un branch per la tua feature (`git checkout -b feature/AmazingFeature`)
3. Commit le modifiche (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📝 Note per sviluppatori

### Testing
```bash
# Esegui i test
Cmd + U in Xcode
```

### Debug
- Utilizza i **breakpoint** in Xcode
- Console log per tracking: `print("Debug message")`
- View Hierarchy Debugger per UI issues

### Best Practices
- Segui le **Swift API Design Guidelines**
- Mantieni le **view leggere** e la logica nei Manager
- Usa **async/await** per operazioni asincrone
- Commenta il codice complesso

## 📱 Screenshot

_Coming soon..._

## 🙏 Ringraziamenti

- Icone da **SF Symbols**
- Ispirazione da app di sustainability tracking
- Community Swift e SwiftUI

## 📄 Licenza

Questo progetto è distribuito sotto licenza MIT. Vedi il file `LICENSE` per maggiori dettagli.

## 📧 Contatti

**Manuel Testoni** - [@ManuelTestoni](https://github.com/ManuelTestoni)

Link Progetto: [https://github.com/ManuelTestoni/PassiVerdi](https://github.com/ManuelTestoni/PassiVerdi)

---

⭐️ **Stella questo progetto** se ti è stato utile per imparare Swift e SwiftUI!
Primo progetto in Swing per realizzare un'applicazione IOS e WatchOS per instillare nelle persone un minimo di consapevolezza nei confronti dell'ambiente.
