# Come aprire il progetto in Xcode

## 🎯 Guida rapida per iniziare

### Passo 1: Verifica i requisiti

Prima di iniziare, assicurati di avere:
- ✅ Un Mac con macOS 14.0 (Sonoma) o superiore
- ✅ Xcode 15.0 o superiore installato
- ✅ Account Apple (gratuito va bene per il simulatore)

### Passo 2: Crea il progetto Xcode

Attualmente hai solo i **file di codice Swift**. Per testarli in Xcode devi creare un **progetto Xcode**.

#### Opzione A: Crea manualmente il progetto (CONSIGLIATO)

1. **Apri Xcode**
2. **File → New → Project**
3. Seleziona:
   - Platform: **iOS**
   - Template: **App**
   - Clicca **Next**

4. Configura il progetto:
   ```
   Product Name: PassiVerdi
   Team: Seleziona il tuo team (o lascia vuoto)
   Organization Identifier: com.tuonome
   Interface: SwiftUI
   Language: Swift
   Storage: None
   ☑️ Include Tests
   ```

5. **Salva** il progetto nella cartella `/Users/chad/Desktop/Documenti/PassiVerdi`

6. **IMPORTANTE:** Quando salvi, Xcode creerà una sottocartella. Sposta i file generati nella root:
   ```
   Prima:
   PassiVerdi/
   ├── PassiVerdi/          ← cartella creata da Xcode
   │   └── PassiVerdiApp.swift
   ├── Models/              ← I tuoi file
   ├── Managers/
   └── Views/
   
   Dopo (corretto):
   PassiVerdi/
   ├── PassiVerdi.xcodeproj/
   ├── PassiVerdi/
   │   ├── PassiVerdiApp.swift
   │   ├── ContentView.swift
   │   ├── Models/
   │   ├── Managers/
   │   └── Views/
   ```

7. **Sostituisci** i file generati da Xcode con quelli esistenti:
   - Trascina i file dalla cartella `PassiVerdi/` (quella alla root) 
   - Nella cartella `PassiVerdi/` dentro il progetto Xcode
   - Seleziona "Move" quando richiesto

8. **Aggiungi il target watchOS**:
   - File → New → Target
   - Seleziona **watchOS → Watch App**
   - Nome: `PassiVerdi Watch`
   - Clicca **Finish**

### Passo 3: Configura i file

1. **Apri il progetto**: `PassiVerdi.xcodeproj`

2. **Nel Project Navigator** (pannello sinistro), la struttura dovrebbe essere:
   ```
   PassiVerdi
   ├─ PassiVerdi
   │  ├─ PassiVerdiApp.swift
   │  ├─ ContentView.swift
   │  ├─ Models/
   │  ├─ Managers/
   │  └─ Views/
   │
   ├─ PassiVerdi Watch Watch App
   │  ├─ PassiVerdi_WatchApp.swift
   │  └─ WatchMainView.swift
   │
   └─ PassiVerdiTests
   ```

3. **Verifica che tutti i file siano aggiunti al target**:
   - Seleziona un file nel Navigator
   - Pannello destro → File Inspector
   - Assicurati che sia spuntato "PassiVerdi" in Target Membership

### Passo 4: Configura le Capabilities

1. Seleziona il progetto **PassiVerdi** nel Navigator
2. Vai su **Signing & Capabilities**
3. Aggiungi le seguenti capabilities (pulsante **+ Capability**):
   - ✅ **Sign in with Apple**
   - ✅ **Background Modes**
     - Spunta: Location updates
     - Spunta: Background fetch

4. Seleziona **PassiVerdi Watch** target
5. Ripeti l'aggiunta delle capabilities necessarie

### Passo 5: Configura Info.plist

1. Nel Navigator, trova **Info.plist**
2. Aggiungi le seguenti chiavi (click destro → Add Row):

```xml
Privacy - Location When In Use Usage Description
→ "PassiVerdi ha bisogno della tua posizione per tracciare i tuoi spostamenti sostenibili"

Privacy - Location Always and When In Use Usage Description
→ "PassiVerdi traccia i tuoi spostamenti anche in background per calcolare automaticamente i punti"

Privacy - Motion Usage Description
→ "PassiVerdi usa i sensori di movimento per rilevare il tipo di trasporto utilizzato"
```

### Passo 6: Compila ed esegui

1. **Seleziona il target**: PassiVerdi
2. **Seleziona il simulatore**: iPhone 15 Pro
3. **Premi**: `Cmd + B` per compilare
4. Se ci sono errori, leggi il messaggio e correggili
5. **Premi**: `Cmd + R` per eseguire

### Passo 7: Testa su Apple Watch (opzionale)

1. Seleziona target: **PassiVerdi Watch**
2. Seleziona: **iPhone 15 Pro + Apple Watch Series 9 (45mm)**
3. Premi `Cmd + R`

## 🐛 Risoluzione problemi comuni

### Errore: "No such module 'SwiftUI'"
**Soluzione:** Assicurati che il deployment target sia iOS 17.0+
- Target → General → Minimum Deployments → iOS 17.0

### Errore: "Cannot find 'AuthenticationManager' in scope"
**Soluzione:** I file non sono aggiunti al target
- Seleziona tutti i file Swift
- File Inspector → Target Membership → Spunta PassiVerdi

### Errore di firma (Code Signing)
**Soluzione:** 
- Target → Signing & Capabilities
- Seleziona "Automatically manage signing"
- Seleziona il tuo team o "Add Account" per aggiungere il tuo Apple ID

### L'app si blocca su CoreLocation
**Soluzione:** Verifica che Info.plist contenga le chiavi privacy per Location

### Preview non funziona
**Soluzione:** 
- Assicurati di essere su un Mac con Apple Silicon (M1/M2/M3)
- Oppure attiva "Rosetta" per Xcode Preview

## 📱 Test su dispositivo fisico

Per testare su iPhone o Apple Watch reale:

1. **Collega il dispositivo** al Mac
2. **Fidati del computer** sul dispositivo
3. **Seleziona** il dispositivo nel menu Xcode
4. **Potrebbe richiedere**:
   - Apple Developer Account (gratuito)
   - Abilitare "Developer Mode" su iOS 16+
     - Settings → Privacy & Security → Developer Mode → ON

## 🎓 Consigli per imparare

### 1. Esplora il codice
- Leggi i commenti nei file
- Usa `Cmd + Click` su una classe per vedere la definizione
- Usa `Cmd + Shift + O` per aprire rapidamente un file

### 2. Sperimenta
- Modifica i colori nelle View
- Cambia i testi
- Aggiungi nuove funzionalità

### 3. Debug
- Usa `print()` per vedere i valori
- Imposta breakpoint (click sulla riga)
- Usa il debugger per seguire l'esecuzione

### 4. Preview
SwiftUI ha preview in tempo reale:
```swift
#Preview {
    DashboardView()
        .environmentObject(UserManager())
}
```

### 5. Documentazione
- Seleziona un metodo → `Option + Click` per vedere la documentazione
- Cerca nella documentazione Apple: `Cmd + Shift + 0`

## 📚 Risorse consigliate

### Tutorials Apple
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift)

### YouTube
- Paul Hudson (Hacking with Swift)
- Sean Allen
- Stewart Lynch

### Libri
- "SwiftUI by Tutorials" - Raywenderlich
- "100 Days of SwiftUI" - Paul Hudson (gratuito)

## 🚀 Prossimi passi dopo il setup

1. **Esplora l'app**: Naviga tra le varie schermate
2. **Leggi il codice**: Inizia da `PassiVerdiApp.swift`
3. **Modifica qualcosa**: Cambia un colore o un testo
4. **Aggiungi una feature**: Prova ad aggiungere un nuovo badge
5. **Consulta la guida**: Leggi `DEVELOPER_GUIDE.md`

---

## ✅ Checklist finale

Prima di iniziare a sviluppare, verifica:

- [ ] Xcode aperto con il progetto PassiVerdi
- [ ] Struttura file corretta nel Navigator
- [ ] App compila senza errori (`Cmd + B`)
- [ ] App si avvia sul simulatore (`Cmd + R`)
- [ ] Preview funzionanti (opzionale)
- [ ] Hai letto `DEVELOPER_GUIDE.md`

## 💡 Hai bisogno di aiuto?

- Leggi i commenti nel codice
- Consulta `DEVELOPER_GUIDE.md`
- Apri una Issue su GitHub
- Cerca su Stack Overflow

**Buon divertimento con Swift e SwiftUI!** 🎉🌱
