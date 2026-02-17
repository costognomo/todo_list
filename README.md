
# TO DO LIST

---

# 📌 Descrizione del progetto

Questa applicazione desktop è stata sviluppata in **Flutter**.

L’applicazione consente di:

1. Gestire una lista di task (CRUD completo)
2. Gestire un wallet fittizio collegato alle azioni
3. Tenere traccia di tutte le operazioni tramite audit log persistente

L’obiettivo è stato realizzare una applicazione per gestire una To do list, con persistenza locale, validazioni, gestione errori e interfaccia moderna desktop-oriented.

---

# 🏗️ Architettura e Stack

## 🔧 Stack scelto

- Desktop application
- Flutter
- Dart
- Persistenza tramite file JSON locale

La scelta di Flutter Desktop consente:

- UI moderna e reattiva
- Codice strutturato e tipizzato

---

# ✅ Requisiti funzionali – Implementazione

## 1️⃣ Task (CRUD)

### Modello Task

Ogni task contiene:

- Titolo (obbligatorio)
- Descrizione
- Stato: `DA INIZIARE` / `INIZIATO` / `COMPLETATO`
- Priorità: `BASSA` / `MEDIA` / `ALTA`
- `ULTIMA MODIFICA`
- ID univoco

### Azioni implementate

- Creazione task
- Visualizzazione task
- Modifica task
- Cambio stato
- Eliminazione task

### UI

- Vista principale suddivisa in 3 colonne
- modalità di visualizzazione lettura e modifica
- Validazione titolo obbligatorio
- Blocco modifica task completate

---

## 2️⃣ Wallet (Crediti)

### Saldo iniziale

Saldo iniziale configurabile (default: 10)

### Regole implementate

- Creare una task → -1 credito
- Portare una task in DONE → +2 crediti
- Eliminare task non DONE → +1 credito
- Eliminare task DONE → nessun rimborso

### Vincoli

- Il wallet non può andare sotto 0
- Validazione con messaggio errore in UI

### UI

- Saldo visibile nella schermata principale
- Pagina dedicata allo storico movimenti
- Cronologia con timestamp

---

## 3️⃣ Audit Log (Registro Eventi)

Ogni azione rilevante genera un evento:

- `TASK_CREATED`
- `TASK_UPDATED`
- `TASK_STATUS_CHANGED`
- `TASK_DELETED`
- `WALLET_DEBIT`
- `WALLET_CREDIT`

Ogni evento contiene:

- type
- timestamp
- payload minimo (id task, evento)

### UI

- Pagina “Log”
- Filtro per testo
- Reset log

---

# 🧩 Requisiti Tecnici – Implementazione

## Persistenza

- File JSON locale
- Serializzazione manuale modelli
- Ripristino automatico all’avvio
- Sopravvive al riavvio dell’applicazione

Struttura dati salvata:

- Lista task
- Saldo wallet
- Storico movimenti
- Audit log

---

## Validazioni

- Titolo obbligatorio
- Wallet non negativo
- Gestione input utente con messaggi chiari

---

## Error Handling

- AlertDialog per errori utente
- Log interno per eventi critici
- Prevenzione stati inconsistenti

---

# ⭐ Funzionalità Aggiuntive Implementate

Oltre ai requisiti minimi, sono state implementate:

- Ricerca full-text su task
- Ricerca per ID (`id:123`)
- Ordinamento dinamico per priorità
- Ordinamento per ultima modifica
- Ordinamento per stato task
- UI responsive desktop

---

# 💻 Requisiti di sistema

- Flutter SDK ≥ 3.x
- Dart SDK (incluso in Flutter)
- Windows / macOS / Linux
- Supporto desktop abilitato (necessario Visual Studio con c++)

Verifica installazione:

```bash
flutter doctor
```

🚀 Istruzioni per avviare il progetto

1️. Clonare repository
```bash
git clone https://github.com/TUO_USERNAME/NOME_REPOSITORY.git
cd NOME_REPOSITORY
```

2️. Installare dipendenze
```bash
flutter pub get
```

3️. Abilitare desktop (se necessario)
```bash
flutter config --enable-windows-desktop
```

4️. Avviare applicazione
Windows
```bash
flutter run -d windows
```

⚙️ Variabili d’ambiente
