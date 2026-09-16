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
      title: 'Repositorio Club de Robótica bySaulLF',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 7, 84, 218)),
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
  final supabase = Supabase.instance.client;


  Future<List<Map<String, dynamic>>> _obtenerProyectos() async {
    final response = await supabase.from('proyectos').select().order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  void _mostrarFormularioNuevoProyecto(BuildContext context) {
    final _tituloController = TextEditingController();
    final _descripcionController = TextEditingController();
    final _categoriaController = TextEditingController();
    final _autorController = TextEditingController();
    final _enlaceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Nuevo Proyecto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _tituloController, decoration: const InputDecoration(labelText: 'Título del Proyecto')),
                TextField(controller: _categoriaController, decoration: const InputDecoration(labelText: 'Categoría (Ej: Mini-Sumo, IoT)')),
                TextField(controller: _autorController, decoration: const InputDecoration(labelText: 'Autor o Equipo')),
                TextField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción / Componentes')),
                TextField(controller: _enlaceController, decoration: const InputDecoration(labelText: 'Enlace de GitHub')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Enviar datos a Supabase
                try {
                  await supabase.from('proyectos').insert({
                    'titulo': _tituloController.text,
                    'categoria': _categoriaController.text,
                    'autor': _autorController.text,
                    'descripcion': _descripcionController.text,
                    'enlace_github': _enlaceController.text,
                  });

                  Navigator.pop(context); // Cerrar ventana
                  setState(() {}); // Recargar la lista de la pantalla principal
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Proyecto agregado con éxito!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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
            return const Center(child: Text('No hay proyectos registrados aún. ¡Agrega el primero!'));
          }
          return ListView.builder(
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = proyectos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(proyecto['titulo'] ?? 'Sin título', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Autor: ${proyecto['autor'] ?? 'Desconocido'} | Categoría: ${proyecto['categoria'] ?? 'General'}'),
                      Text('${proyecto['descripcion'] ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: const Icon(Icons.code, color: Colors.deepOrange),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioNuevoProyecto(context),
        tooltip: 'Agregar Proyecto',
        child: const Icon(Icons.add),
      ),
    );
  }
}