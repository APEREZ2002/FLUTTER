import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'evolution_service.dart';
import 'package:audioplayers/audioplayers.dart';

class PokemonDetailsScreen extends StatefulWidget {
  final Pokemon pokemon;

  PokemonDetailsScreen({required this.pokemon});

  @override
  _PokemonDetailsScreenState createState() => _PokemonDetailsScreenState();
}

class _PokemonDetailsScreenState extends State<PokemonDetailsScreen> {
  final EvolutionService _evolutionService = EvolutionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;

  String? _height;
  String? _weight;
  List<String> _abilities = [];
  List<String> _types = [];
  List<String> _moves = [];
  String? _cryUrl;
  List<String> _gameAppearances = [];
  String? _gifUrl; // URL del GIF animado

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(widget.pokemon.url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _height = (data['height'] / 10).toStringAsFixed(1);
          _weight = (data['weight'] / 10).toStringAsFixed(1);
          _abilities = List<String>.from(data['abilities'].map((a) => a['ability']['name']));
          _types = List<String>.from(data['types'].map((t) => t['type']['name']));
          _moves = List<String>.from(data['moves'].map((m) => m['move']['name']));
          _cryUrl = data['cries']['latest']; // URL del sonido del Pokémon
          _gameAppearances = List<String>.from(data['game_indices'].map((g) => g['version']['name']));

          // Obtener el ID del Pokémon y generar la URL del GIF
          int pokemonId = data['id'];
          _gifUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$pokemonId.gif";
        });
      } else {
        throw Exception("Error al obtener los detalles del Pokémon");
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _playCry() {
    if (_cryUrl != null) {
      _audioPlayer.play(UrlSource(_cryUrl!));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pokemon.name.toUpperCase())),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),

              // Mostrar el GIF animado del Pokémon (más grande)
              if (_gifUrl != null)
                Image.network(
                  _gifUrl!,
                  width: double.infinity, // Ajusta el tamaño al ancho del contenedor
                  height: 150, // Fija la altura, ajustando el ancho proporcionalmente
                  fit: BoxFit.contain, // Asegura que el GIF se vea completo sin recortes
                ),

              SizedBox(height: 20),

              // Nombre del Pokémon
              Text(
                widget.pokemon.name.toUpperCase(),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Altura y Peso
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDetailCard('Altura', '$_height m'),
                  SizedBox(width: 20),
                  _buildDetailCard('Peso', '$_weight kg'),
                ],
              ),
              SizedBox(height: 20),

              // Tipos como chips
              Wrap(
                spacing: 8,
                children: _types.map((type) => _buildChip(type)).toList(),
              ),
              SizedBox(height: 20),

              // Habilidades
              _buildExpandableSection("Habilidades", _abilities),

              // Movimientos (Desplegable)
              _buildExpandableSection("Movimientos", _moves),

              // Juegos en los que aparece (Desplegable)
              _buildExpandableSection("Aparece en estos juegos", _gameAppearances),

              // Grito del Pokémon
              if (_cryUrl != null)
                ElevatedButton.icon(
                  onPressed: _playCry,
                  icon: Icon(Icons.volume_up),
                  label: Text("Reproducir Grito"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      backgroundColor: Colors.blueAccent,
    );
  }

  Widget _buildExpandableSection(String title, List<String> items) {
    return ExpansionTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.take(30).map((item) => _buildChip(item)).toList(),
          ),
        ),
      ],
    );
  }
}
