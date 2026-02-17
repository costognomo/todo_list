import 'package:flutter/material.dart';
import 'dart:convert'; // jsonEncode/jsonDecode
import 'dart:io'; // File
import 'package:path_provider/path_provider.dart'; // cartella app
import 'package:intl/intl.dart';

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

bool _invertiOrdinamento =
    false; // false = alta-> media -> bassa / true = bassa -> media -> aòta

// Struttura dati di una task
class Task {
  String titolo;
  String descrizione;
  String avanzamento; // 'Da iniziare' | 'Iniziato' | 'Completato'
  String priorita; // 'Bassa' | 'Media' | 'Alta'
  DateTime ultimaModifica;
  final int id;

  Task(
    this.titolo,
    this.descrizione,
    this.avanzamento,
    this.priorita, {
    int? id,

    // assegnazione orario attuale
  }) : ultimaModifica = DateTime.now(),
       id = id ?? DateTime.now().microsecondsSinceEpoch;

  //----------------------------------------------------------------------------
  // SERIALIZZAZIONE JSON
  //----------------------------------------------------------------------------
  Map<String, dynamic> toJson() => {
    'titolo': titolo,
    'descrizione': descrizione,
    'avanzamento': avanzamento,
    'priorita': priorita,
    'ultimaModifica': ultimaModifica.toIso8601String(),
    'id': id,
  };

  // creazione task da mappa JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return Task(
        json['titolo'] ?? '',
        json['descrizione'] ?? '',
        json['avanzamento'] ?? 'Da iniziare',
        json['priorita'] ?? 'Bassa',
        id: rawId != null ? (rawId as num).toInt() : null,
      )
      ..ultimaModifica =
          DateTime.tryParse(
            json['ultimaModifica'] ?? DateTime.now().toIso8601String(),
          ) ??
          DateTime.now();
  }
}

//------------------------------------------------------------------------------
// MODELLO CRONOLOGIA CREDITI
//------------------------------------------------------------------------------
class EventoCrediti {
  String titoloTask; // Nome della task coinvolta
  int valore; // Quantità di crediti (+2, +1, -1)
  DateTime data; // Momento in cui è avvenuta la modifica

  // Acquisizione orario
  EventoCrediti(this.titoloTask, this.valore) : data = DateTime.now();

  //--------------------------------------------------------------------------
  // SERIALIZZAZIONE → quando si carica su file JSON
  //--------------------------------------------------------------------------
  Map<String, dynamic> toJson() => {
    'titoloTask': titoloTask,
    'valore': valore,
    'data': data.toIso8601String(),
  };

  //--------------------------------------------------------------------------
  // DESERIALIZZAZIONE → quando si recupera dal file JSON
  //--------------------------------------------------------------------------
  factory EventoCrediti.fromJson(Map<String, dynamic> json) {
    final e = EventoCrediti(json['titoloTask'] ?? '', json['valore'] ?? 0);

    // Ripristinazione della data salvata
    e.data = DateTime.tryParse(json['data'] ?? '') ?? DateTime.now();

    return e;
  }
}

//------------------------------------------------------------------------------
// PAGINA CRONOLOGIA CREDITI
//------------------------------------------------------------------------------
class CronologiaSpesePage extends StatefulWidget {
  final List<EventoCrediti> cronologia;

  const CronologiaSpesePage({super.key, required this.cronologia});

  @override
  State<CronologiaSpesePage> createState() => _CronologiaSpesePageState();
}

class _CronologiaSpesePageState extends State<CronologiaSpesePage> {
  //--------------------------------------------------------------------------
  // RICERCA STORICO CREDITI
  //--------------------------------------------------------------------------
  final TextEditingController _searchController = TextEditingController();

  // lista filtrata (mostrata a schermo)
  late List<EventoCrediti> _filteredCronologia;

  @override
  void initState() {
    super.initState();

    // invertimento per avere i più recenti sopra
    _filteredCronologia = widget.cronologia.reversed.toList();

    // ogni volta che cambia il testo ricalcolo la lista
    _searchController.addListener(_applyFilter);
  }

  //--------------------------------------------------------------------------
  // FILTRO RICERCA (titoloTask, valore, data formattata)
  //--------------------------------------------------------------------------
  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();

    // base: tutto lo storico
    List<EventoCrediti> baseList = widget.cronologia;

    // Se c'è una ricerca, filtriamo
    if (query.isNotEmpty) {
      baseList = widget.cronologia.where((evento) {
        final titolo = evento.titoloTask.toLowerCase();
        final valore = evento.valore.toString(); // "+2" non serve: cerchi "2"
        final dataFormattata = DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(evento.data).toLowerCase();

        return titolo.contains(query) ||
            valore.contains(query) ||
            dataFormattata.contains(query);
      }).toList();
    }

    // inverte l'ordine (ultimi movimenti → sopra)
    setState(() {
      _filteredCronologia = baseList.reversed.toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            pinned: true,
            title: const Text(
              'STORICO CREDITI',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          //--------------------------------------------------------------------------
          // BODY: barra ricerca + lista
          //--------------------------------------------------------------------------

          //--------------------------------------------------------------------
          // BARRA DI RICERCA
          //--------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Cerca nello storico crediti...',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          if (_filteredCronologia.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Nessun risultato',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final evento = _filteredCronologia[index];

                //------------------------------------------------------------------
                // SCELTA COLORE IN BASE AL TIPO DI MOVIMENTO
                //------------------------------------------------------------------
                Color colore;
                if (evento.valore == -1) {
                  colore = Colors.red; // creazione task
                } else if (evento.valore == 1) {
                  colore = Colors.yellow; // eliminazione
                } else {
                  colore = Colors.green; // completamento
                }

                //------------------------------------------------------------------
                // FORMATTAZIONE DATA
                //------------------------------------------------------------------
                final dataFormattata = DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(evento.data);

                //------------------------------------------------------------------
                // BOX GRAFICO DEL MOVIMENTO
                //------------------------------------------------------------------
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 40, 160),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  //----------------------------------------------------------------------
                  // CONTENUTO BOX: sinistra (titolo+data) | destra (numero centrato)
                  //----------------------------------------------------------------------
                  child: IntrinsicHeight(
                    child: Row(
                      //------------------------------------------------------------------
                      // stretch = il contenitore del numero si estende in altezza
                      //------------------------------------------------------------------
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //----------------------------------------------------------------
                        // SINISTRA: titolo + data
                        //----------------------------------------------------------------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Nome della task
                              Text(
                                evento.titoloTask,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Data piccola sotto il titolo
                              Text(
                                dataFormattata,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        //----------------------------------------------------------------
                        // DESTRA: valore (+2, +1, -1) centrato e alto quanto il box
                        //----------------------------------------------------------------
                        Container(
                          width: 50, // larghezza “colonnina” del numero
                          alignment: Alignment
                              .center, // centra verticalmente e orizzontalmente
                          child: Text(
                            evento.valore > 0
                                ? '+${evento.valore}'
                                : '${evento.valore}',
                            style: TextStyle(
                              color: colore,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _filteredCronologia.length),
            ),
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _crediti = 10;
  final List<Task> _task = [];
  //------------------------------------------------------------------------------
  // ASSEGNAZIONE PESO ALLE PRIORITA
  //------------------------------------------------------------------------------
  int _pesoPriorita(String priorita) {
    switch (priorita) {
      case 'Alta':
        return 3;
      case 'Media':
        return 2;
      case 'Bassa':
        return 1;
      default:
        // Se per qualche motivo la priorità è vuota/sbagliata finisce in fondo
        return 0;
    }
  }

  //------------------------------------------------------------------------------
  // LISTA MOVIMENTI CREDITI
  //------------------------------------------------------------------------------
  final List<EventoCrediti> _cronologia = [];

  //------------------------------------------------------------------------------
  // ORDINAMENTO INDICI ALTO-> MEDIO -> BASSO |per ultima modifica
  //------------------------------------------------------------------------------
  List<int> _ordinaIndiciPerPriorita(List<int> indici) {
    // Creazione copia per non modificare la lista originale passata
    final sorted = List<int>.from(indici);

    // sort: ritorna negativo se a deve stare prima di b
    sorted.sort((a, b) {
      final pa = _pesoPriorita(_task[a].priorita);
      final pb = _pesoPriorita(_task[b].priorita);

      //confronto priorità
      final cmpPriorita = _invertiOrdinamento
          ? pa.compareTo(pb)
          : pb.compareTo(pa);
      if (cmpPriorita != 0) return cmpPriorita;

      // Se priorità uguale ordinamento per ultima modifica
      final da = _task[a].ultimaModifica;
      final db = _task[b].ultimaModifica;

      return db.compareTo(da);
    });

    return sorted;
  }

  //----------------------------------------------------------------------------
  // SALVATAGGIO / CARICAMENTO NELLO STATE
  //----------------------------------------------------------------------------

  // Nome del file dove salviamo tutto
  static const String _fileName = 'todo_data.json';

  // Ritorna il file fisico nella cartella dell’app
  Future<File> _getDataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // Salva task + counter + log +cronologia crediti
  Future<void> _saveData() async {
    final file = await _getDataFile();

    final data = {
      'counter': _crediti,
      'log': _log,
      'tasks': _task.map((t) => t.toJson()).toList(),
      'cronologia': _cronologia.map((e) => e.toJson()).toList(),
    };

    await file.writeAsString(jsonEncode(data));
  }

  @override
  void initState() {
    super.initState();
    _loadData(); // ricarica tutto appena l’app parte
  }

  @override
  void dispose() {
    // rilascio controller ricerca home
    _ricercaTaskController.dispose();
    super.dispose();
  }

  // Carica task + counter + log
  Future<void> _loadData() async {
    try {
      final file = await _getDataFile();
      if (!await file.exists()) return;

      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      //------------------------------------------------------------------------
      // CARICAMENTO CRONOLOGIA CREDITI DAL FILE
      //------------------------------------------------------------------------
      final cronologiaJson = (decoded['cronologia'] as List?) ?? [];

      final loadedCronologia = cronologiaJson
          .map((e) => EventoCrediti.fromJson(e as Map<String, dynamic>))
          .toList();

      final loadedCounter = decoded['counter'] as int? ?? 10;
      final loadedLog = (decoded['log'] as List?)?.cast<String>() ?? <String>[];

      final tasksJson = (decoded['tasks'] as List?) ?? [];
      final loadedTasks = tasksJson
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _crediti = loadedCounter;
        _log
          ..clear()
          ..addAll(loadedLog);
        _task
          ..clear()
          ..addAll(loadedTasks);
        _cronologia
          ..clear()
          ..addAll(loadedCronologia);
      });
    } catch (e) {
      // Se il file è corrotto o il json non è valido
      _schermataerrore('Impossibile caricare i dati salvati: $e');
    }
  }

  // ----------------------------------------------------
  // LOG: lista eventi + helper
  // ----------------------------------------------------
  final List<String> _log = [];

  // CREAZIONE STRINGA LOG
  void _addLog(String msg) {
    final now = DateTime.now();

    // data/ mese/ anno ore : minuti
    final dataFormattata = DateFormat('dd/MM/yyyy HH:mm').format(now);
    final riga = '[$dataFormattata] ${msg.toUpperCase()}';

    // Console (debug)
    debugPrint(riga);

    // Salva in memoria per mostrarlo in UI
    setState(() {
      _log.add(riga);
    });
    _saveData();
  }

  // ---------------------------------------------------------------------------
  //  ALERT ERRORE (riutilizzabile)
  // ---------------------------------------------------------------------------
  void _schermataerrore(String messaggio) {
    //LOG ERRORE
    _addLog('ERRORE: $messaggio');

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

  //----------------------------------------------------------------------------
  // RICERCA: controller+ testo querry
  //----------------------------------------------------------------------------
  final TextEditingController _ricercaTaskController = TextEditingController();

  // Ricalcolo liste al cambio
  String _taskQuery = '';

  // ---------------------------------------------------------------------------
  //  FILTRO: ritorna gli indici reali della lista _task per uno stato
  //  + ricerca su titolo/descrizione o ID
  // ---------------------------------------------------------------------------
  List<int> _filtrostatoavanzamento(String stato) {
    final result = <int>[];

    // pulizia query (spazi)
    final raw = _taskQuery.trim();
    final qLower = raw.toLowerCase();

    // 1) Caso: query vuota -> tutto
    if (raw.isEmpty) {
      for (int i = 0; i < _task.length; i++) {
        if (_task[i].avanzamento == stato) result.add(i);
      }
      return result;
    }

    // 2) Determina se si sta cercando per ID
    String? idCercato;

    // Se l'utente scrive solo numeri -> interpretalo come ID (equivalente a "id:123")
    if (RegExp(r'^\d+$').hasMatch(raw)) {
      idCercato = raw;
    }

    // Se l'utente scrive "id" o "id:" o "id:  " -> NON SI ATTIVA ID
    if (qLower == 'id' || qLower == 'id:' || qLower.startsWith('id:')) {
      final after = qLower.startsWith('id:') ? qLower.substring(3).trim() : '';
      if (after.isEmpty) {
        for (int i = 0; i < _task.length; i++) {
          if (_task[i].avanzamento == stato) result.add(i);
        }
        return result;
      } else {
        idCercato = after;
      }
    }

    // 3) Filtra
    for (int i = 0; i < _task.length; i++) {
      if (_task[i].avanzamento != stato) continue;

      // Ricerca per ID
      if (idCercato != null) {
        final idString = _task[i].id.toString();
        if (idString.contains(idCercato)) result.add(i);
        continue;
      }

      // Ricerca testuale (titolo/descrizione)
      final titolo = _task[i].titolo.toLowerCase();
      final descr = _task[i].descrizione.toLowerCase();
      if (titolo.contains(qLower) || descr.contains(qLower)) {
        result.add(i);
      }
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  //  BOX UI riutilizzabile per una task (
  // ---------------------------------------------------------------------------
  Widget widgetTaskBox(int index, Color coloreTask) {
    //------------------------------------------------------------------------
    // ORARIO ULTIMA MODIFICA
    //------------------------------------------------------------------------
    final ultimaModifica = _task[index].ultimaModifica;
    final formattamento = DateFormat(
      'HH:mm - dd/MM/yyyy',
    ).format(ultimaModifica);

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

          //------------------------------------------------------------------------
          // DESCRIZIONE (con fade sotto)
          //------------------------------------------------------------------------
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
                  overflow: TextOverflow.ellipsis,
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 10,
                  child: IgnorePointer(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color.fromARGB(193, 0, 11, 168),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //------------------------------------------------------------------------
          // ORARIO IN BASSO A DESTRA
          //------------------------------------------------------------------------
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // restringe la row al minimo necessario
              children: [
                // ID in piccolo, a sinistra
                Text(
                  'ID: ${_task[index].id}  ',
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),

                // ultima modifica a destra
                Text(
                  'Ultima modifica: $formattamento',
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
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

    // Copie originali per 'Annulla modifiche'
    final titoloOriginale = _task[index].titolo;
    final descrizioneOriginale = _task[index].descrizione;
    final prioritaOriginale = _task[index].priorita;
    final avanzamentoOriginale = _task[index].avanzamento;

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isEditing = false; // stato locale: editing on/off

        // Regola: se la task è completata, è 'bloccata'
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
                      final taskEliminata = _task[index];
                      // Se era completata -> NON incrementare crediti
                      final bool eraCompletata =
                          (taskEliminata.avanzamento == 'Completato');

                      _task.removeAt(index);

                      if (!eraCompletata) {
                        _addLog(
                          'ELIMINATA TASK (ID:${taskEliminata.id}): "${taskEliminata.titolo}" ',
                        );
                      } else {
                        _addLog(
                          'ELIMINATA TASK (ID:${taskEliminata.id}): "${taskEliminata.titolo}", ERA COMPLETATA',
                        );
                      }

                      if (!eraCompletata) {
                        _crediti++;
                        // crediti tornano solo se non completata

                        _cronologia.add(EventoCrediti(taskEliminata.titolo, 1));
                      }
                    });
                    _saveData();

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
                            _crediti += 2;

                            _cronologia.add(
                              EventoCrediti(titoloController.text, 2),
                            );

                            _addLog(
                              '+2 CREDITI TASK COMPLETATA (TITOLO: "${_task[index].titolo}" - ID: ${_task[index].id}) ',
                            );
                          }

                          //------------------------------------------------------------------------------------------------
                          // LOG CAMBIO DI STATO
                          //------------------------------------------------------------------------------------------------
                          if (statoPrima != statoDopo) {
                            _addLog(
                              'CAMBIO STATO TASK (TITOLO: "${_task[index].titolo}" - ID: ${_task[index].id})  : "$statoPrima" -> "$statoDopo"',
                            );
                          }
                          //------------------------------------------------------------------------------------------------
                          // LOG MODIFICA DESCRIZIONE
                          //------------------------------------------------------------------------------------------------
                          final descrizioneDopo = descrizioneController.text;

                          if (descrizioneOriginale != descrizioneDopo) {
                            _addLog(
                              'MODIFICATA DESCRIZIONE TASK (TITOLO: "${_task[index].titolo}" - ID: ${_task[index].id} ) : "$descrizioneOriginale" -> "$descrizioneDopo"',
                            );
                          }

                          //-------------------------------------------------------------------------------------------------
                          // LOG MODIFICA TITOLO
                          //-------------------------------------------------------------------------------------------------
                          final titoloDopo = titoloController.text;
                          if (titoloOriginale != titoloDopo) {
                            _addLog(
                              'MODIFICATO TITOLO TASK (ID: ${_task[index].id}) : "$titoloOriginale" -> "$titoloDopo"',
                            );
                          }

                          //---------------------------------------------------------------------------------------------------
                          // LOG MODIFICA PRIORITÀ
                          //---------------------------------------------------------------------------------------------------
                          final prioritaDopo = prioritaselezionata;
                          if (prioritaOriginale != prioritaDopo) {
                            _addLog(
                              'MODIFICATA PRIORITÀ  TASK (TITOLO: "${_task[index].titolo}" - ID: ${_task[index].id} ): "$prioritaOriginale" -> "$prioritaDopo"',
                            );
                          }

                          //----------------------------------------------------
                          // AGGIORNA LA TASK
                          //----------------------------------------------------

                          _task[index].titolo = titoloController.text;
                          _task[index].descrizione = descrizioneController.text;
                          _task[index].priorita = prioritaselezionata;
                          _task[index].avanzamento = avanzamentoselezionato;

                          _task[index].ultimaModifica =
                              DateTime.now(); // aggiornamento all'ultima modifica
                        });
                        _saveData();

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
    required Color coloreTitolo,
  }) {
    return Container(
      margin: const EdgeInsets.all(12),

      // SFONDO BIANCO TRASPARENTE + BORDI ARROTONDATI
      decoration: BoxDecoration(
        color: const Color.fromARGB(136, 0, 0, 0), // trasparenza
        borderRadius: BorderRadius.circular(20),

        // ombra leggera
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(103, 38, 0, 255), blurRadius: 10),
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
                color: coloreTitolo,
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
                  child: widgetTaskBox(indexReale, coloreTitolo),
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
  // ---------------------------------------------------------------------------

  void _creditnumber() {
    if (_crediti < 1) {
      _schermataerrore(
        'i tuoi crediti sono finiti, porta a termine le tue task per guadagnarne altri',
      );
      _addLog('ERRORE:_CREDITI_FINITI');

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
                      _crediti--;
                      final nuovaTask = Task(
                        titoloController.text,
                        descrizioneController.text,
                        avanzamentoselezionato,
                        prioritaselezionata,
                      );
                      _cronologia.add(EventoCrediti(nuovaTask.titolo, -1));

                      _task.add(nuovaTask);

                      //------------------------------------------------------------------------
                      // SE LA TASK NASCE GIÀ COMPLETATA ASSEGNARE COMUNQE I 2 CREDITI
                      //------------------------------------------------------------------------
                      if (avanzamentoselezionato == 'Completato') {
                        _crediti += 2;
                        _cronologia.add(EventoCrediti(nuovaTask.titolo, 2));

                        _addLog(
                          '+2 CREDITI: TASK CREATA GIÀ COMPLETATA (ID: ${nuovaTask.id}) ("${nuovaTask.titolo}")',
                        );
                      }

                      //--------------------------------------------------------
                      // LOG CREAZIONE TASK
                      //--------------------------------------------------------

                      _addLog(
                        'CREATA task: (ID: ${nuovaTask.id}): "TITOLO: ${nuovaTask.titolo}" | priorità=$prioritaselezionata | avanzamento=$avanzamentoselezionato | crediti=$_crediti',
                      );
                    });
                    _saveData();

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

    final daIniziareOrdinato = _ordinaIndiciPerPriorita(daIniziare);
    final iniziatoOrdinato = _ordinaIndiciPerPriorita(iniziato);
    final completatoOrdinato = _ordinaIndiciPerPriorita(completato);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 0, 255),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 33,
                color: Colors.white,
                fontWeight: FontWeight.w900,
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
        ),
        leadingWidth: 180,

        // Barra di ricerca centrale (riuso widget)
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SearchBarWidget(
              controller: _ricercaTaskController,
              hintText: 'Cerca task (titolo, descrizione, data o ID / id:123)',
              onChanged: (value) {
                setState(() {
                  _taskQuery = value;
                });
              },
            ),
          ),
        ),

        //--------------------------------------------------------------------
        // PULSANTE INVERTI ORDINAMENTO
        //--------------------------------------------------------------------
        actions: [
          IconButton(
            tooltip: _invertiOrdinamento
                ? 'Ordine priorità : Bassa -> Alta'
                : 'Ordine priorità : Alta -> Bassa',
            icon: Icon(
              _invertiOrdinamento ? Icons.south : Icons.north,
              color: Colors.white,
              shadows: const [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 3,
                  color: Colors.black,
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                _invertiOrdinamento = !_invertiOrdinamento;
              });
            },
          ),
          //----------------------------------------------------------------------
          // PULSANTE PER VEDERE IL LOG
          //----------------------------------------------------------------------
          IconButton(
            tooltip: 'Log',
            icon: const Icon(
              Icons.article,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 3,
                  color: Colors.black,
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LogPage(
                    log: _log,
                    onReset: () async {
                      await _saveData();
                    },
                  ),
                ),
              );
            },
          ),
          // -------------------------------------------------------------------------
          // PULSANTE CRONOLOGIA CREDITI
          // -------------------------------------------------------------------------
          IconButton(
            tooltip: 'Storico Crediti',
            icon: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 3,
                  color: Colors.black,
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CronologiaSpesePage(cronologia: _cronologia),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/SfondoToDoList.png', fit: BoxFit.cover),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Crediti responsive (non va in overflow)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'I tuoi crediti sono: $_crediti',
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
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      //  BOTTONE LARGO TUTTO LO SCHERMO
                      // --------------------------------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 255, 255, 255),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _creditnumber,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  55,
                                  0,
                                  255,
                                ),
                                foregroundColor: const Color.fromARGB(
                                  255,
                                  253,
                                  243,
                                  243,
                                ),
                              ),
                              child: const Text(
                                'AGGIUNGI NUOVA TASK',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ---------------------------------------------------------------------------
                      // LARGHEZZA MINIMA + SCROLL SE NECESSARIO
                      // ---------------------------------------------------------------------------
                      SizedBox(
                        height: (constraints.maxHeight * 0.70).clamp(
                          250.0,
                          900.0,
                        ),
                        child: LayoutBuilder(
                          builder: (context, innerConstraints) {
                            final larghezzaSchermo = innerConstraints.maxWidth;
                            const larghezzaMinColonne = 400.0;
                            final larghezzaIdeale = larghezzaSchermo / 3;
                            final columnWidth =
                                larghezzaIdeale < larghezzaMinColonne
                                ? larghezzaMinColonne
                                : larghezzaIdeale;

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //----------------------------------------------------------
                                  //COLONNA 1: DA INIZIARE
                                  //----------------------------------------------------------
                                  SizedBox(
                                    width: columnWidth,
                                    child: buildColonnaKanban(
                                      titolo: 'DA INIZIARE',
                                      indici: daIniziareOrdinato,
                                      coloreTitolo: const Color.fromARGB(
                                        255,
                                        206,
                                        206,
                                        206,
                                      ),
                                    ),
                                  ),

                                  //----------------------------------------------------------
                                  //COLONNA 2: INIZIATO
                                  //----------------------------------------------------------
                                  SizedBox(
                                    width: columnWidth,
                                    child: buildColonnaKanban(
                                      titolo: 'INIZIATO',
                                      indici: iniziatoOrdinato,
                                      coloreTitolo: const Color.fromARGB(
                                        255,
                                        206,
                                        206,
                                        206,
                                      ),
                                    ),
                                  ),

                                  //----------------------------------------------------------
                                  //COLONNA 3: COMPLETATO
                                  //----------------------------------------------------------
                                  SizedBox(
                                    width: columnWidth,
                                    child: buildColonnaKanban(
                                      titolo: 'COMPLETATO',
                                      indici: completatoOrdinato,
                                      coloreTitolo: const Color.fromARGB(
                                        255,
                                        206,
                                        206,
                                        206,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//------------------------------------------------------------------------------
// PAGINA SEPARATA PER MOSTRARE IL LOG CON RICERCA TESTUALE
//------------------------------------------------------------------------------
class LogPage extends StatefulWidget {
  // Ricevimento log completo
  final List<String> log;

  //callback per resettatre totalmente log
  final Future<void> Function()? onReset;

  const LogPage({super.key, required this.log, this.onReset});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  // Controller per leggere/modificare il testo della barra di ricerca
  final TextEditingController _searchController = TextEditingController();

  // Lista dei log filtrati (quelli che matchano la ricerca)
  late List<String> _filteredLog;

  @override
  void initState() {
    super.initState();

    // All'inizio mostriamo tutto il log (nessun filtro)
    _filteredLog = widget.log.reversed.toList();

    // aggiorniamo la lista filtrata
    _searchController.addListener(_applyFilter);
  }

  // Funzione che applica il filtro e ordina dal più recente al più vecchio
  void _applyFilter() {
    final query = _searchController.text.trim();

    // lista completa log
    List<String> baseList = widget.log;

    // Se c'è una ricerca, filtriamo
    if (query.isNotEmpty) {
      final qLower = query.toLowerCase();

      baseList = widget.log.where((riga) {
        return riga.toLowerCase().contains(qLower);
      }).toList();
    }

    //inverte l'ordine (ultimi log → sopra)
    setState(() {
      _filteredLog = baseList.reversed.toList();
    });
  }

  @override
  void dispose() {
    //rilascio controller poiché la pagina è stata distrutta
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            pinned: true,
            title: const Text('Log', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),

            //----------------------------------------------------------------------
            // CREAZIONE PULSANTE ELIMINAZIONE DESTRA
            //----------------------------------------------------------------------
            actions: [
              IconButton(
                tooltip: 'reset log',
                icon: const Icon(Icons.delete),
                onPressed: _resetLog,
              ),
            ],
          ),

          //--------------------------------------------------------------------
          // BARRA DI RICERCA SCORLLABILE
          //--------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Scrivi una parola o una parte della frase...',
                // aggiorno la UI per mostrare/nascondere la X
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          //------------------------------------------------------------------------
          // RISULTATI (LISTA LOG FILTRATA)
          //------------------------------------------------------------------------
          // Se non ci sono risultati (o log vuoto) appare un messaggio
          if (_filteredLog.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Nessun risultato',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 40, 160),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _filteredLog[index],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                );
              }, childCount: _filteredLog.length),
            ),
        ],
      ),
    );
  }

  //------------------------------------------------------------------------------
  // RESET LOG: chiede conferma e poi svuota il log
  //------------------------------------------------------------------------------
  Future<void> _resetLog() async {
    // 1) Chiediamo conferma PRIMA di fare qualsiasi modifica ai dati
    final bool? conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset log'),
          content: const Text('Vuoi cancellare definitivamente tutto il log?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancella'),
            ),
          ],
        );
      },
    );

    // Se l'utente annulla (false) o chiude il dialog (null), non accade nulla
    if (conferma != true) return;

    // svuotamento log in memoria
    widget.log.clear();

    // Aggiornamento UI della pagina log
    setState(() {
      _searchController.clear();
      _filteredLog.clear();
    });

    // Aggiornamento file di rimando da home
    if (widget.onReset != null) {
      await widget.onReset!();
    }
  }
}

//------------------------------------------------------------------------------
// WIDGET RIUTILIZZABILE: barra di ricerca
//------------------------------------------------------------------------------
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String) onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      //testo scritto dentro
      controller: controller,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        //colore 'scrivi una parola o una parte della frase...'
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),

        //colore icone
        prefixIcon: const Icon(Icons.search, color: Colors.white),

        // Pulsante X per cancellare velocemente il testo
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  // Cancella testo
                  controller.clear();
                  onChanged('');
                },
              ),

        border: const OutlineInputBorder(),
        filled: true,
        fillColor: const Color.fromARGB(80, 0, 0, 0),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}
