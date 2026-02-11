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
  String avanzamento;
  String priorita;

  Task(this.titolo, this.descrizione, this.avanzamento, this.priorita);
}

// Gestione dati + UI
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 10;
  final List<Task> _task = [];

  // apertura e modifica task
  void _openTaskDetail(int index) {
    final titoloController = TextEditingController(text: _task[index].titolo);
    final descrizioneController = TextEditingController(
      text: _task[index].descrizione,
    );
    String prioritaselezionata = _task[index].priorita;
    String avanzamentoselezionato = _task[index].avanzamento;

    final titoloOriginale = _task[index].titolo;
    final descrizioneOriginale = _task[index].descrizione;
    final prioritaoriginale = _task[index].priorita;
    final avanzamentoriginale = _task[index].avanzamento;

    showDialog(
      context: context,
      builder: (context) {
        bool isEditing = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Dettaglio task'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

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
                              onChanged: isEditing
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
                              onChanged: isEditing
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

                      TextField(
                        controller: titoloController,
                        enabled: isEditing,
                        maxLength: 40,
                        decoration: const InputDecoration(labelText: 'Titolo'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descrizioneController,
                        enabled: isEditing,
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
                // Sinistra: Elimina (sempre visibile)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _task.removeAt(index);
                      _counter++;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Elimina'),
                ),

                // Destra: in lettura -> Modifica/Chiudi; in modifica -> Annulla/Salva
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (isEditing) {
                          // annulla modifiche locali e torna in lettura
                          titoloController.text = titoloOriginale;
                          descrizioneController.text = descrizioneOriginale;
                          setDialogState(() => isEditing = false);
                          prioritaselezionata = prioritaoriginale;
                          avanzamentoselezionato = avanzamentoriginale;
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(isEditing ? 'Annulla modifiche' : 'Chiudi'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        if (!isEditing) {
                          setDialogState(() => isEditing = true);
                          return;
                        }

                        if (titoloController.text.isEmpty) return;

                        setState(() {
                          _task[index].titolo = titoloController.text;
                          _task[index].descrizione = descrizioneController.text;
                          _task[index].priorita = prioritaselezionata;
                          _task[index].avanzamento = avanzamentoselezionato;
                        });
                        Navigator.pop(context);
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

  // creazione nuove task
  void _creditnumber() {
    setState(() {
      if (_counter >= 1) {
        final titoloController = TextEditingController();
        final descrizioneController = TextEditingController();
        String prioritaselezionata = 'Priorità';
        String avanzamentoselezionato = 'Avanzamento';

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Crea una nuova task'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // creazione dei due menù a tendina per priorità e per avanzamento
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
                              setState(() => prioritaselezionata = value);
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
                              setState(() => avanzamentoselezionato = value);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: titoloController,
                      maxLength: 40,
                      decoration: const InputDecoration(labelText: 'Titolo'),
                    ),
                    const SizedBox(height: 12),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () {
                    if (titoloController.text.isEmpty) return;
                    if (prioritaselezionata == 'Priorità' ||
                        avanzamentoselezionato == 'Avanzamento')
                      return;

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

                    Navigator.pop(context);
                  },
                  child: const Text('Crea'),
                ),
              ],
            );
          },
        );
      } else {
        //gestione errore in caso di mancanza di crediti
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Non hai più crediti disponibili!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  //Gestione scaffold con AppBar + Body (stack)
  @override
  Widget build(BuildContext context) {
    Image.asset(
      'assets/SfondoToDoList.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
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
      //sfondo e row con 3 colonne
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/SfondoToDoList.png', fit: BoxFit.cover),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    // Testo crediti in alto
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

                    // Lista riquadri (sotto al testo)
                    Positioned.fill(
                      top: 160,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _task.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => _openTaskDetail(index),
                            child: Container(
                              height: 80,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color.fromARGB(230, 255, 255, 255),
                                border: Border.all(
                                  color: const Color.fromARGB(
                                    200,
                                    255,
                                    255,
                                    255,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _task[index].titolo.toString(),
                                  style: const TextStyle(
                                    fontSize: 21,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Pulsante +
                    Positioned(
                      top: 100,
                      left: 290,
                      child: FloatingActionButton(
                        onPressed: _creditnumber, // oppure _creditnumber
                        tooltip: 'Aggiungi una nuova task',
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                  color: const Color.fromARGB(255, 255, 154, 2),
                  child: ListView(
                    children: [
                      Container(
                        height: 150,
                        color: const Color.fromARGB(255, 255, 255, 0),
                      ),
                      Container(
                        height: 150,
                        color: const Color.fromARGB(255, 255, 165, 0),
                      ),
                      Container(
                        height: 150,
                        color: const Color.fromARGB(255, 255, 255, 0),
                      ),
                      Container(
                        height: 150,
                        color: const Color.fromARGB(255, 0, 128, 0),
                      ),
                      Container(
                        height: 150,
                        color: const Color.fromARGB(255, 0, 0, 255),
                      ),
                      Container(
                        height: 150,
                        color: const Color.fromARGB(255, 75, 0, 130),
                      ),
                      Container(
                        height: 150,
                        color: const Color.fromARGB(255, 148, 0, 211),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        Container(
                          height: 450,
                          color: const Color.fromARGB(0, 255, 0, 0),
                        ),
                        Container(
                          height: 150,
                          color: const Color.fromARGB(255, 255, 255, 0),
                        ),
                        Container(
                          height: 150,
                          color: const Color.fromARGB(255, 0, 128, 0),
                        ),
                        Container(
                          height: 150,
                          color: const Color.fromARGB(255, 0, 0, 255),
                        ),
                        Container(
                          height: 150,
                          color: const Color.fromARGB(255, 75, 0, 130),
                        ),
                        Container(
                          height: 150,
                          color: const Color.fromARGB(255, 148, 0, 211),
                        ),
                      ],
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
