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

  // ----------------------------------------------------
  // LOG: lista eventi + helper
  // ----------------------------------------------------
  final List<String> _log = [];

  //----------------------------------------------------------------------------
  // CREAZIONE STRINGA LOG
  //----------------------------------------------------------------------------

  void _addLog(String msg) {
    final now = DateTime.now();
    final riga = "[${now.toIso8601String()}] ${msg.toUpperCase()}";

    // Console (debug)
    debugPrint(riga);

    // Salva in memoria per mostrarlo in UI
    setState(() {
      _log.add(riga);
    });
  }

  // ---------------------------------------------------------------------------
  //  ALERT ERRORE (riutilizzabile)
  // ---------------------------------------------------------------------------
  void _schermataerrore(String messaggio) {
    //LOG ERRORE
    _addLog("ERRORE: $messaggio");

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
  Widget widget_taskBox(int index, Color coloreTask) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(230, 0, 11, 168),
        border: Border.all(color: const Color.fromARGB(117, 0, 0, 0), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(151, 66, 52, 255), //colore ombra
            blurRadius: 12, //quanto è morbida
          ),
        ],
      ),

      //------------------------------------------------------------------------
      // CONTENUTO: titolo + descrizione
      //------------------------------------------------------------------------
      padding: const EdgeInsets.all(12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TITOLO
          Text(
            _task[index].titolo,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis, // evita testi troppo lunghi
          ),

          const SizedBox(height: 6),
          SizedBox(
            child: Stack(
              children: [
                // DESCRIZIONE
                Text(
                  _task[index].descrizione,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 5,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentGeometry.topCenter,
                        end: AlignmentGeometry.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(195, 0, 11, 168),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                              initialValue: prioritaselezionata,
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
                      final titoloEliminato = _task[index].titolo;

                      _task.removeAt(index);

                      if (!eraCompletata) {
                        _addLog("ELIMINATA_:_'$titoloEliminato',");
                      } else {
                        _addLog(
                          "ELIMINATA_task:_'$titoloEliminato',ERA_COMPLETATA",
                        );
                      }

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
                          //--------------------------------------------------------------------------------------------------
                          // CONTROLLO CAMBIO STATO -> +2 | LOG INCREMENTO DI CREDITI PER COMPLETAMENTO TASK
                          //--------------------------------------------------------------------------------------------------
                          final String statoPrima = _task[index].avanzamento;
                          final String statoDopo = avanzamentoselezionato;

                          //Se NON era completata e ORA lo diventa -> +2
                          if (statoPrima != 'Completato' &&
                              statoDopo == 'Completato') {
                            _counter += 2;

                            _addLog(
                              "+2_CREDITI_TASK_COMPLETATA_(index=$index),",
                            );
                          }

                          //------------------------------------------------------------------------------------------------
                          // LOG CAMBIO DI STATO
                          //------------------------------------------------------------------------------------------------
                          if (statoPrima != statoDopo) {
                            _addLog(
                              "CAMBIO_STATO_TASK_index=$index:_'$statoPrima'_->_'$statoDopo',",
                            );
                          }

                          //----------------------------------------------------
                          // AGGIORNA LA TASK
                          //----------------------------------------------------

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

  // -----------------------------------------------------------------
  // WIDGET RIUTILIZZABILE PER UNA COLONNA
  // -----------------------------------------------------------------
  Widget buildColonnaKanban({
    required String titolo,
    required List<int> indici,

    //PARAMETRI COLORE
    required Color ColoreTitolo,
  }) {
    return Container(
      margin: const EdgeInsets.all(12),

      // SFONDO BIANCO TRASPARENTE + BORDI ARROTONDATI
      decoration: BoxDecoration(
        color: const Color.fromARGB(136, 0, 0, 0), // trasparenza
        borderRadius: BorderRadius.circular(20),

        // ombra leggera
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(95, 38, 0, 255), blurRadius: 10),
        ],
      ),

      child: Column(
        children: [
          // -------------------------------
          // TITOLO DELLA COLONNA
          // -------------------------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              titolo,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColoreTitolo,
              ),
            ),
          ),

          const Divider(height: 1),

          // -------------------------------
          // LISTA TASK
          // -------------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: indici.length,
              itemBuilder: (context, i) {
                final indexReale = indici[i];

                return InkWell(
                  onTap: () => _openTaskDetail(indexReale),
                  child: widget_taskBox(indexReale, ColoreTitolo),
                );
              },
            ),
          ),
        ],
      ),
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
      _addLog("ERRORE:_CREDITI_FINITI");

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
                      _addLog(
                        "CREATA task:_'${titoloController.text}'_|_priorità=$prioritaselezionata\_|_avanzamento=$avanzamentoselezionato\_|_crediti=$_counter,",
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

        //----------------------------------------------------------------------
        // PULSANTE PER VEDERE IL LOG
        //----------------------------------------------------------------------
        actions: [
          IconButton(icon: const Icon(Icons.article), onPressed: _showLog),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/SfondoToDoList.png', fit: BoxFit.cover),
          ),

          //Crediti in alto
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
          // --------------------------------------------------
          //  BOTTONE LARGO TUTTO LO SCHERMO
          // --------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 100, 12, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),

                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 255, 255, 255), // colore ombra
                    blurRadius: 20, // quanto è morbida
                    spreadRadius: 2, // quanto si espande
                  ),
                ],
              ),

              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _creditnumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(136, 17, 139, 238),
                    foregroundColor: const Color.fromARGB(255, 253, 243, 243),
                  ),
                  child: const Text(
                    'AGGIUNGI NUOVA TASK',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
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
                    // Lista "DA INIZIARE"
                    Positioned.fill(
                      top: 160,
                      child: buildColonnaKanban(
                        titolo: 'DA INIZIARE',
                        indici: daIniziare,
                        ColoreTitolo: Color.fromARGB(255, 206, 206, 206),
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
                      child:
                          // Lista "INIZIATO"
                          Positioned.fill(
                            top: 160,
                            child: buildColonnaKanban(
                              titolo: 'INIZIATO',
                              indici: iniziato,
                              ColoreTitolo: Color.fromARGB(255, 206, 206, 206),
                            ),
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
                      child:
                          // Lista "COMPLETATO"
                          Positioned.fill(
                            top: 160,
                            child: buildColonnaKanban(
                              titolo: 'COMPLETATO',
                              indici: completato,
                              ColoreTitolo: const Color.fromARGB(
                                255,
                                206,
                                206,
                                206,
                              ),
                            ),
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

  //------------------------------------------------------------------------------
  // SCHEDA TEMPORANEA PER LA VISUALIZZAZIONE DEI LOG
  //------------------------------------------------------------------------------

  void _showLog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("LOG"),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(child: Text(_log.join("\n"))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Chiudi"),
          ),
        ],
      ),
    );
  }
}
