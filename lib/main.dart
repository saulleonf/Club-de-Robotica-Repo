import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase con tus credenciales de la nube
  await Supabase.initialize(
    url: 'https://qtsfsvxsmneiqchonojp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0c2ZzdnhzbW5laXFjaG9ub2pwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkxNTg5MDAsImV4cCI6MjEwNDczNDkwMH0.Kearpk6gxff6gdS2GcNQ0huvJcZW7-rDaXFRklCjPyk',
  );

  runApp(const ClubRoboticaApp());
}

class ClubRoboticaApp extends StatelessWidget {
  const ClubRoboticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repositorio Club de Robótica\nbySaulLF',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instancia de Supabase para hacer peticiones
  final supabase = Supabase.instance.client;

  // Método futuro para obtener los proyectos
  Future<List<Map<String, dynamic>>> _obtenerProyectos() async {
    final response = await supabase.from('proyectos').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos del Club de Robótica'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _obtenerProyectos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final proyectos = snapshot.data ?? [];
          if (proyectos.isEmpty) {
            return const Center(child: Text('No hay proyectos registrados aún.'));
          }
          return ListView.builder(
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = proyectos[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(proyecto['titulo'] ?? 'Sin título'),
                  subtitle: Text('Autor: ${proyecto['autor']} - ${proyecto['categoria']}'),
                  trailing: const Icon(Icons.code),
                ),
              );
            },
          );
        },
      ),
    );
  }
}