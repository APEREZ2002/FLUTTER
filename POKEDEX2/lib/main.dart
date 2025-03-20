import 'package:flutter/material.dart';
import 'pokemon_list_screen.dart';
import 'dart:math';
import 'pokemon.dart';
import 'pokemon_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PokemonApp());
}

class PokemonApp extends StatefulWidget {
  @override
  _PokemonAppState createState() => _PokemonAppState();
}

class _PokemonAppState extends State<PokemonApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Función para obtener un Pokémon aleatorio
  Pokemon _getRandomPokemon() {
    // Listado de Pokémon aleatorios para mostrar
    List<Pokemon> pokemonList = [
      Pokemon(
        name: 'Pikachu',
        imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
        evolutionUrl: '',
        url: 'https://pokeapi.co/api/v2/pokemon/25/',
        types: ['electric'],
      ),
      Pokemon(
        name: 'Bulbasaur',
        imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
        evolutionUrl: '',
        url: 'https://pokeapi.co/api/v2/pokemon/1/',
        types: ['grass', 'poison'],
      ),
      Pokemon(
        name: 'Charmander',
        imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png',
        evolutionUrl: '',
        url: 'https://pokeapi.co/api/v2/pokemon/4/',
        types: ['fire'],
      ),
      // Añadir más Pokémon aquí
    ];

    // Obtener un Pokémon aleatorio
    final random = Random();
    return pokemonList[random.nextInt(pokemonList.length)];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Color(0xFF4CAF50), // Verde Pokédex
        scaffoldBackgroundColor: Color(0xFFF4F4F4),
        appBarTheme: AppBarTheme(
          color: Color(0xFF4CAF50),
          elevation: 5,
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        cardColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF303030),
        primaryColor: Color(0xFF424242),
        hintColor: Color(0xFF616161),
        cardColor: Color(0xFF424242),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF424242),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: PokemonListScreen(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}
