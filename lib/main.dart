import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  Task(this.titolo, this.descrizione);
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dettaglio task'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titoloController,
                    decoration: const InputDecoration(labelText: 'Titolo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descrizioneController,
                    minLines: 20,
                    maxLines: 50,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: 'Contenuto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _task[index].titolo = titoloController.text;
                  _task[index].descrizione = descrizioneController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Salva'),
            ),
          ],
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
                    TextField(
                      controller: titoloController,
                      decoration: const InputDecoration(labelText: 'Titolo'),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        controller: descrizioneController,
                        keyboardType: TextInputType.multiline,
                        expands: true,
                        maxLines: null,
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

                    setState(() {
                      _counter--;
                      _task.add(
                        Task(titoloController.text, descrizioneController.text),
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
                              height: 150,
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
                                    fontSize: 22,
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
