# ✅ Checklist Setup Xcode - PassiVerdi

## 📋 Procedura passo-passo

### ✅ Step 1: Verifica prerequisiti

- [ ] macOS 14.0+ (Sonoma o superiore)
- [ ] Xcode 15.0+ installato
- [ ] Apple ID configurato in Xcode (Settings → Accounts)

---

### ✅ Step 2: Crea nuovo progetto Xcode

1. Apri **Xcode**
2. Seleziona **Create New Project** (o File → New → Project)
3. Scegli template:
   - [ ] Platform: **iOS**
   - [ ] Template: **App**
   - [ ] Click **Next**

4. Configurazione progetto:
   ```
   Product Name: PassiVerdi
   Team: [Seleziona il tuo team]
   Organization Identifier: com.tuonome
   Bundle Identifier: com.tuonome.PassiVerdi
   Interface: SwiftUI
   Language: Swift
   Storage: None
   ✓ Include Tests
   ```
   - [ ] Compila campi come sopra
   - [ ] Click **Next**

5. Salva il progetto:
   - [ ] Naviga a: `/Users/chad/Desktop/Documenti/PassiVerdi`
   - [ ] Click **Create**

---

### ✅ Step 3: Organizza i file

**IMPORTANTE:** Xcode ha creato una sottocartella con file template.

1. **Nel Finder**, vai alla cartella progetto
2. Dovresti vedere:
   ```
   PassiVerdi/
   ├── PassiVerdi.xcodeproj/    ← Progetto Xcode
   ├── PassiVerdi/              ← Cartella codice (da Xcode)
   │   ├── PassiVerdiApp.swift
   │   ├── ContentView.swift
   │   └── Assets.xcassets
   ├── Models/                  ← I tuoi file
   ├── Managers/
   ├── Views/
   └── PassiVerdi Watch Watch App/
   ```

3. **Sposta i tuoi file**:
   - [ ] Sposta cartella `Models/` dentro `PassiVerdi/`
   - [ ] Sposta cartella `Managers/` dentro `PassiVerdi/`
   - [ ] Sposta cartella `Views/` dentro `PassiVerdi/`
   - [ ] Sostituisci `PassiVerdiApp.swift` con il tuo
   - [ ] Sostituisci `ContentView.swift` con il tuo

4. Struttura finale dovrebbe essere:
   ```
   PassiVerdi/
   ├── PassiVerdi.xcodeproj/
   ├── PassiVerdi/
   │   ├── PassiVerdiApp.swift
   │   ├── ContentView.swift
   │   ├── Assets.xcassets/
   │   ├── Models/
   │   ├── Managers/
   │   └── Views/
   ├── PassiVerdi Watch Watch App/
   └── PassiVerdiTests/
   ```

---

### ✅ Step 4: Aggiungi file in Xcode

1. **Apri** `PassiVerdi.xcodeproj`

2. **Nel Project Navigator** (pannello sinistro):
   - [ ] Click destro su cartella **PassiVerdi**
   - [ ] Seleziona **Add Files to "PassiVerdi"...**

3. **Aggiungi cartelle**:
   - [ ] Seleziona cartella `Models`
   - [ ] ✓ Spunta "Create groups"
   - [ ] ✓ Spunta "PassiVerdi" in "Add to targets"
   - [ ] Click **Add**
   
4. **Ripeti** per:
   - [ ] Cartella `Managers`
   - [ ] Cartella `Views`

5. **Verifica** che tutti i file .swift siano visibili nel Navigator

---

### ✅ Step 5: Aggiungi watchOS Target

1. **File → New → Target**
2. Seleziona:
   - [ ] Platform: **watchOS**
   - [ ] Template: **Watch App**
   - [ ] Click **Next**

3. Configurazione:
   ```
   Product Name: PassiVerdi Watch
   Bundle Identifier: com.tuonome.PassiVerdi.watchkitapp
   ```
   - [ ] Compila campi
   - [ ] Click **Finish**

4. **Aggiungi file Watch**:
   - [ ] Nel Navigator, trova gruppo `PassiVerdi Watch Watch App`
   - [ ] Elimina file template (se presenti)
   - [ ] Click destro → Add Files
   - [ ] Aggiungi i file da `PassiVerdi Watch Watch App/`

---

### ✅ Step 6: Configura permessi (Info.plist)

1. **Nel Navigator**, seleziona `PassiVerdi/Info.plist`
2. **Click destro → Open As → Source Code**
3. **Aggiungi** prima di `</dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>PassiVerdi ha bisogno della tua posizione per tracciare i tuoi spostamenti sostenibili</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>PassiVerdi traccia i tuoi spostamenti anche in background per calcolare automaticamente i punti</string>

<key>NSMotionUsageDescription</key>
<string>PassiVerdi usa i sensori di movimento per rilevare il tipo di trasporto utilizzato</string>
```

- [ ] Permessi aggiunti

---

### ✅ Step 7: Configura Capabilities

1. **Seleziona** il progetto PassiVerdi nel Navigator
2. **Seleziona** target **PassiVerdi**
3. **Tab: Signing & Capabilities**

4. **Signing**:
   - [ ] ✓ Automatically manage signing
   - [ ] Seleziona il tuo **Team**

5. **Aggiungi Capabilities** (pulsante **+ Capability**):
   - [ ] **Sign in with Apple**
   - [ ] **Background Modes**
     - [ ] ✓ Location updates
     - [ ] ✓ Background fetch

6. **Ripeti** per target **PassiVerdi Watch**:
   - [ ] Automatically manage signing
   - [ ] Seleziona Team

---

### ✅ Step 8: Configura Build Settings

1. **Seleziona** target **PassiVerdi**
2. **Tab: General**
3. **Minimum Deployments**:
   - [ ] iOS: **17.0**

4. **Seleziona** target **PassiVerdi Watch**
5. **Minimum Deployments**:
   - [ ] watchOS: **10.0**

---

### ✅ Step 9: Verifica Target Membership

Per ogni file Swift in `Models/`, `Managers/`, `Views/`:

1. **Seleziona** il file
2. **File Inspector** (pannello destro)
3. **Target Membership**:
   - [ ] ✓ PassiVerdi (per file iPhone)
   
Per file in `PassiVerdi Watch Watch App/`:
   - [ ] ✓ PassiVerdi Watch Watch App

---

### ✅ Step 10: Prima compilazione

1. **Seleziona** scheme: **PassiVerdi**
2. **Seleziona** simulatore: **iPhone 15 Pro**
3. **Premi** `Cmd + B` (Build)

**Se ci sono errori:**
- [ ] Leggi il messaggio di errore
- [ ] Verifica che tutti i file siano aggiunti ai target corretti
- [ ] Controlla che i permessi siano in Info.plist
- [ ] Ricompila con `Cmd + Shift + K` (Clean) poi `Cmd + B`

4. **Se compila con successo** ✅:
   - [ ] Premi `Cmd + R` per eseguire

---

### ✅ Step 11: Test Apple Watch (opzionale)

1. **Seleziona** scheme: **PassiVerdi Watch Watch App**
2. **Seleziona**: **iPhone 15 Pro + Apple Watch Series 9 (45mm)**
3. **Premi** `Cmd + R`
4. **Attendi** che entrambi i simulatori si avviino

- [ ] App iPhone funzionante
- [ ] App Watch funzionante
- [ ] Sincronizzazione tra i due

---

## 🐛 Troubleshooting

### Errore: "No such module 'SwiftUI'"
**Soluzione:**
```
Target → Build Settings → Search "iOS Deployment Target"
Assicurati sia 17.0+
```

### Errore: "Cannot find 'AuthenticationManager' in scope"
**Soluzione:**
```
1. Seleziona AuthenticationManager.swift
2. File Inspector → Target Membership
3. ✓ PassiVerdi
```

### Errore di firma (Code Signing)
**Soluzione:**
```
1. Xcode → Settings → Accounts
2. Aggiungi Apple ID
3. Target → Signing → Seleziona Team
```

### App si blocca al lancio
**Soluzione:**
```
1. Verifica Info.plist contiene le chiavi privacy
2. Controlla console per errori
3. Verifica tutti i Manager siano inizializzati in PassiVerdiApp.swift
```

### Preview non funziona
**Soluzione:**
```
1. Assicurati di essere su Mac Apple Silicon (M1/M2/M3)
2. O attiva Rosetta in Get Info del file Xcode.app
3. Ricompila il target
```

---

## ✅ Checklist finale

Prima di iniziare a sviluppare:

- [ ] Progetto compila senza errori (`Cmd + B`)
- [ ] App si avvia su simulatore iPhone (`Cmd + R`)
- [ ] Tutte le tab sono visibili (Dashboard, Tracking, Sfide, Classifica, Profilo)
- [ ] Onboarding appare al primo avvio
- [ ] Watch app compila (opzionale)
- [ ] Hai letto `DEVELOPER_GUIDE.md`
- [ ] Hai letto `PROJECT_STRUCTURE.md`

---

## 🎉 Congratulazioni!

Se hai completato tutti gli step, il tuo progetto è pronto!

### Prossimi passi:

1. **Esplora l'app**: Naviga tra le schermate
2. **Leggi il codice**: Inizia da `PassiVerdiApp.swift`
3. **Modifica qualcosa**: Cambia un colore o un testo
4. **Compila e testa**: Verifica che funzioni
5. **Impara**: Leggi la documentazione e sperimenta

---

## 📚 Documentazione di riferimento

- `START_HERE.md` - Overview generale
- `GETTING_STARTED.md` - Guida dettagliata
- `DEVELOPER_GUIDE.md` - Architettura e best practices
- `PROJECT_STRUCTURE.md` - Spiegazione struttura

---

## 💪 Sei pronto!

Hai ora una base completa per imparare Swift e SwiftUI.

**Happy coding! 🚀🌱**
