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

class Task {
  final String titolo;
  Task(this.titolo);
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 10;
  final List<Task> _task = [];

  void _creditnumber() {
    setState(() {
      if (_counter >= 1) {
        final controller = TextEditingController();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Scegli un titolo per la tua task'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Inserisci titolo'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.isEmpty) return;
                    setState(() {
                      _counter--;
                      _task.add(Task(controller.text));
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Non hai più crediti disponibili!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

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
                          return Container(
                            height: 150,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(104, 255, 255, 255),
                              border: Border.all(
                                color: const Color.fromARGB(55, 255, 255, 255),
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
                        color: const Color.fromARGB(255, 0, 0, 0),
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
