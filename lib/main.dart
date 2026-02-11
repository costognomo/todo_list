import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Applicazione stage g-nous',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 32, 29, 180),
        ),
      ),
      home: const MyHomePage(title: 'To Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Struttura dati di una task
class Task {
  String titolo;
  String descrizione;
  String avanzamento; // "Da iniziare" | "Iniziato" | "Completato"
  String priorita; // "Bassa" | "Media" | "Alta"

  Task(this.titolo, this.descrizione, this.avanzamento, this.priorita);
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 10;
  final List<Task> _task = [];

  // ---------------------------------------------------------------------------
  //  ALERT ERRORE (riutilizzabile)
  // ---------------------------------------------------------------------------
  void _schermataerrore(String messaggio) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Errore'),
        content: Text(messaggio),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // chiude SOLO l'alert
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  FILTRO: ritorna gli indici reali della lista _task per uno stato
  // ---------------------------------------------------------------------------
  List<int> _filtrostatoavanzamento(String stato) {
    final result = <int>[];
    for (int i = 0; i < _task.length; i++) {
      if (_task[i].avanzamento == stato) result.add(i);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  //  BOX UI riutilizzabile per una task (
  // ---------------------------------------------------------------------------
  Widget widget_taskBox(int index) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(230, 255, 255, 255),
        border: Border.all(
          color: const Color.fromARGB(200, 255, 255, 255),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _task[index].titolo,
          style: const TextStyle(
            fontSize: 21,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  DETTAGLIO TASK: lettura -> (se non completata) modifica -> salva
  //  Regole richieste:
  //    - se Completato: non modificabile
  //    - se Completato ed eliminata: NON aumenta i crediti
  // ---------------------------------------------------------------------------
  void _openTaskDetail(int index) {
    // Controller testo
    final titoloController = TextEditingController(text: _task[index].titolo);
    final descrizioneController = TextEditingController(
      text: _task[index].descrizione,
    );

    // Dropdown (valori correnti)
    String prioritaselezionata = _task[index].priorita;
    String avanzamentoselezionato = _task[index].avanzamento;

    // Copie originali per "Annulla modifiche"
    final titoloOriginale = _task[index].titolo;
    final descrizioneOriginale = _task[index].descrizione;
    final prioritaOriginale = _task[index].priorita;
    final avanzamentoOriginale = _task[index].avanzamento;

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isEditing = false; // stato locale: editing on/off

        // Regola: se la task è completata, è "bloccata"
        final bool isCompletata = (_task[index].avanzamento == 'Completato');

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Dettaglio task'),
              content: SizedBox(
                width: MediaQuery.of(dialogContext).size.width * 0.6,
                height: MediaQuery.of(dialogContext).size.height * 0.6,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Dropdown priorità + avanzamento
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: prioritaselezionata,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Bassa',
                                  child: Text('Bassa'),
                                ),
                                DropdownMenuItem(
                                  value: 'Media',
                                  child: Text('Media'),
                                ),
                                DropdownMenuItem(
                                  value: 'Alta',
                                  child: Text('Alta'),
                                ),
                              ],
                              // Abilita cambio SOLO se editing e NON completata
                              onChanged: (isEditing && !isCompletata)
                                  ? (value) {
                                      if (value == null) return;
                                      setDialogState(
                                        () => prioritaselezionata = value,
                                      );
                                    }
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Priorità',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: avanzamentoselezionato,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Da iniziare',
                                  child: Text('Da iniziare'),
                                ),
                                DropdownMenuItem(
                                  value: 'Iniziato',
                                  child: Text('Iniziato'),
                                ),
                                DropdownMenuItem(
                                  value: 'Completato',
                                  child: Text('Completato'),
                                ),
                              ],
                              onChanged: (isEditing && !isCompletata)
                                  ? (value) {
                                      if (value == null) return;
                                      setDialogState(
                                        () => avanzamentoselezionato = value,
                                      );
                                    }
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Avanzamento',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Titolo (bloccato se completata)
                      TextField(
                        controller: titoloController,
                        enabled: isEditing && !isCompletata,
                        maxLength: 40,
                        decoration: const InputDecoration(labelText: 'Titolo'),
                      ),

                      const SizedBox(height: 12),

                      // Descrizione (bloccato se completata)
                      TextField(
                        controller: descrizioneController,
                        enabled: isEditing && !isCompletata,
                        minLines: 20,
                        maxLines: 50,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          labelText: 'Contenuto',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                // ------------------ ELIMINA ------------------
                TextButton(
                  onPressed: () {
                    setState(() {
                      // Se era completata -> NON incrementare crediti
                      final bool eraCompletata =
                          (_task[index].avanzamento == 'Completato');

                      _task.removeAt(index);

                      if (!eraCompletata) {
                        _counter++; // crediti tornano solo se non completata
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Elimina'),
                ),

                // ------------------ BOTTONI DESTRA ------------------
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chiudi oppure annulla modifiche
                    TextButton(
                      onPressed: () {
                        if (isEditing) {
                          // Ripristina testi e dropdown ai valori originali
                          titoloController.text = titoloOriginale;
                          descrizioneController.text = descrizioneOriginale;

                          setDialogState(() {
                            prioritaselezionata = prioritaOriginale;
                            avanzamentoselezionato = avanzamentoOriginale;
                            isEditing = false;
                          });
                        } else {
                          Navigator.pop(dialogContext);
                        }
                      },
                      child: Text(isEditing ? 'Annulla modifiche' : 'Chiudi'),
                    ),
                    const SizedBox(width: 8),

                    // Modifica / Salva
                    TextButton(
                      onPressed: () {
                        // Regola: completata -> non modificabile
                        if (isCompletata) {
                          _schermataerrore(
                            'La task è completata e non può più essere modificata.',
                          );
                          return;
                        }

                        // Se in lettura -> entra in modifica
                        if (!isEditing) {
                          setDialogState(() => isEditing = true);
                          return;
                        }

                        // Se in modifica -> salva
                        if (titoloController.text.isEmpty) return;

                        setState(() {
                          _task[index].titolo = titoloController.text;
                          _task[index].descrizione = descrizioneController.text;
                          _task[index].priorita = prioritaselezionata;
                          _task[index].avanzamento = avanzamentoselezionato;
                        });

                        Navigator.pop(dialogContext);
                      },
                      child: Text(isEditing ? 'Salva' : 'Modifica'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  //  CREAZIONE TASK
  //  - Se non selezioni titolo/priorità/avanzamento -> alert
  //  Nota: nessun setState esterno al dialog
  // ---------------------------------------------------------------------------
  void _creditnumber() {
    if (_counter < 1) {
      _schermataerrore(
        'i tuoi crediti sono finiti, porta a termine le tue task per guadagnarne altri',
      );
      return;
    }

    final titoloController = TextEditingController();
    final descrizioneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Stato locale del dialog: dropdown
        String prioritaselezionata = 'Priorità';
        String avanzamentoselezionato = 'Avanzamento';

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Crea una nuova task'),
              content: SizedBox(
                width: MediaQuery.of(dialogContext).size.width * 0.6,
                height: MediaQuery.of(dialogContext).size.height * 0.6,
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Dropdown priorità + avanzamento
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: prioritaselezionata,
                            items: const [
                              DropdownMenuItem(
                                value: 'Priorità',
                                child: Text('Priorità'),
                              ),
                              DropdownMenuItem(
                                value: 'Bassa',
                                child: Text('Bassa'),
                              ),
                              DropdownMenuItem(
                                value: 'Media',
                                child: Text('Media'),
                              ),
                              DropdownMenuItem(
                                value: 'Alta',
                                child: Text('Alta'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setDialogState(() => prioritaselezionata = value);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: avanzamentoselezionato,
                            items: const [
                              DropdownMenuItem(
                                value: 'Avanzamento',
                                child: Text('Avanzamento'),
                              ),
                              DropdownMenuItem(
                                value: 'Da iniziare',
                                child: Text('Da iniziare'),
                              ),
                              DropdownMenuItem(
                                value: 'Iniziato',
                                child: Text('Iniziato'),
                              ),
                              DropdownMenuItem(
                                value: 'Completato',
                                child: Text('Completato'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setDialogState(
                                () => avanzamentoselezionato = value,
                              );
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Titolo
                    TextField(
                      controller: titoloController,
                      maxLength: 40,
                      decoration: const InputDecoration(labelText: 'Titolo'),
                    ),
                    const SizedBox(height: 12),

                    // Corpo testo
                    Expanded(
                      child: TextField(
                        controller: descrizioneController,
                        keyboardType: TextInputType.multiline,
                        expands: true,
                        maxLines: null,
                        textAlign: TextAlign.left,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          labelText: 'Corpo del testo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () {
                    // Validazioni
                    if (titoloController.text.isEmpty) {
                      _schermataerrore(
                        'Il titolo è obbligatorio per creare la task',
                      );
                      return;
                    }

                    if (avanzamentoselezionato == 'Avanzamento') {
                      _schermataerrore(
                        'Selezionare lo stato di avanzamento è obbligatorio per creare la task',
                      );
                      return;
                    }

                    if (prioritaselezionata == 'Priorità') {
                      _schermataerrore(
                        'Selezionare la priorità è obbligatorio per creare la task',
                      );
                      return;
                    }
                    // Crea la task
                    setState(() {
                      _counter--;
                      _task.add(
                        Task(
                          titoloController.text,
                          descrizioneController.text,
                          avanzamentoselezionato,
                          prioritaselezionata,
                        ),
                      );
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Crea'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  //  UI PRINCIPALE: 3 colonne in base ad avanzamento
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final daIniziare = _filtrostatoavanzamento('Da iniziare');
    final iniziato = _filtrostatoavanzamento('Iniziato');
    final completato = _filtrostatoavanzamento('Completato');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 0, 255),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.black),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/SfondoToDoList.png', fit: BoxFit.cover),
          ),
          Row(
            children: [
              // ----------------------------------------------------------------
              // COLONNA 1: DA INIZIARE
              // ----------------------------------------------------------------
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    // Crediti in alto
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Text(
                        'I tuoi crediti sono: $_counter',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lista "Da iniziare"
                    Positioned.fill(
                      top: 160,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: daIniziare.length,
                        itemBuilder: (context, i) {
                          final indexReale = daIniziare[i];
                          return InkWell(
                            onTap: () => _openTaskDetail(indexReale),
                            child: widget_taskBox(indexReale),
                          );
                        },
                      ),
                    ),

                    // Bottone +
                    Positioned(
                      top: 100,
                      left: 290,
                      child: FloatingActionButton(
                        onPressed: _creditnumber,
                        tooltip: 'Aggiungi una nuova task',
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),

              // ----------------------------------------------------------------
              // COLONNA 2: INIZIATO
              // ----------------------------------------------------------------
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(height: 160), // abbassa la lista
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: iniziato.length,
                        itemBuilder: (context, i) {
                          final indexReale = iniziato[i];
                          return InkWell(
                            onTap: () => _openTaskDetail(indexReale),
                            child: widget_taskBox(indexReale),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ----------------------------------------------------------------
              // COLONNA 3: COMPLETATO
              // ----------------------------------------------------------------
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(height: 160), // abbassa la lista
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: completato.length,
                        itemBuilder: (context, i) {
                          final indexReale = completato[i];
                          return InkWell(
                            onTap: () => _openTaskDetail(indexReale),
                            child: widget_taskBox(indexReale),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
