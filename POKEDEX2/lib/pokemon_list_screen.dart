import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_service.dart';
import 'pokemon_card.dart';
import 'pokemon_details_screen.dart';

class PokemonListScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  PokemonListScreen({required this.onThemeToggle, required this.isDarkMode});

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final PokemonService _pokemonService = PokemonService();
  List<Pokemon> _pokemonList = [];
  List<Pokemon> _filteredPokemonList = [];
  bool _isLoading = true;
  String _searchQuery = "";
  bool _isReversed = false;
  bool _isGridView = false;
  int _alphabeticalSortState = 0;
  List<String> _selectedTypes = [];

  // Lista completa de tipos de Pokémon
  final List<String> _allTypes = [
    'fire', 'water', 'grass', 'electric', 'bug', 'fairy', 'dragon',
    'dark', 'psychic', 'ice', 'fighting', 'normal', 'poison',
    'ground', 'flying', 'ghost', 'steel', 'rock'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPokemon();
  }

  Future<void> _fetchPokemon() async {
    setState(() => _isLoading = true);
    try {
      List<Pokemon> pokemon = await _pokemonService.fetchPokemonList();
      setState(() {
        _pokemonList = pokemon;
        _filteredPokemonList = List.from(pokemon);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredPokemonList = _pokemonList.where((pokemon) {
        bool matchesName = pokemon.name.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesType = _selectedTypes.isEmpty ||
            pokemon.types.any((type) => _selectedTypes.contains(type.toLowerCase()));

        return matchesName && matchesType;
      }).toList();

      if (_alphabeticalSortState == 1) {
        _filteredPokemonList.sort((a, b) => a.name.compareTo(b.name));
      } else if (_alphabeticalSortState == 2) {
        _filteredPokemonList.sort((a, b) => b.name.compareTo(a.name));
      }

      if (_isReversed) {
        _filteredPokemonList = _filteredPokemonList.reversed.toList();
      }
    });
  }

  void _toggleOrder() {
    setState(() {
      _isReversed = !_isReversed;
      _applyFilters();
    });
  }

  void _toggleAlphabeticalSort() {
    setState(() {
      _alphabeticalSortState = (_alphabeticalSortState + 1) % 3;
      _applyFilters();
    });
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
    _applyFilters();
  }

  void _toggleTypeFilter(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
      _applyFilters();
    });
  }

  // Función para mostrar un Pokémon aleatorio
  void _showRandomPokemon() {
    if (_pokemonList.isNotEmpty) {
      final randomPokemon = _pokemonList[(DateTime.now().millisecondsSinceEpoch % _pokemonList.length)];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDetailsScreen(pokemon: randomPokemon),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pokédex"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode
                ? "Cambiar a modo claro"
                : "Cambiar a modo oscuro",
          ),
          IconButton(
            icon: Icon(
              _alphabeticalSortState == 1
                  ? Icons.sort_by_alpha
                  : _alphabeticalSortState == 2
                  ? Icons.sort
                  : Icons.swap_horiz,
            ),
            onPressed: _toggleAlphabeticalSort,
            tooltip: _alphabeticalSortState == 1
                ? "Ordenar de Z a A"
                : _alphabeticalSortState == 2
                ? "Quitar orden alfabético"
                : "Ordenar de A a Z",
          ),
          IconButton(
            icon: Icon(_isReversed ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _toggleOrder,
            tooltip: _isReversed
                ? "Ordenar por número de Pokédex (ascendente)"
                : "Ordenar por número de Pokédex (descendente)",
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: _isGridView ? "Ver en lista" : "Ver en cuadrícula",
          ),
          IconButton(
            icon: Icon(Icons.autorenew),
            onPressed: _showRandomPokemon,  // Botón para mostrar un Pokémon aleatorio
            tooltip: "Mostrar Pokémon aleatorio",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Buscar Pokémon",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: widget.isDarkMode
                    ? Colors.blueGrey.shade800
                    : Colors.blue.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          // Filtro por tipos con imágenes
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
              spacing: 8, // Espacio horizontal entre los chips
              runSpacing: 8, // Espacio vertical entre las filas
              children: _allTypes.map((type) {
                return FilterChip(
                  label: Image.asset(
                    'assets/types/${type[0].toUpperCase()}${type.substring(1)}.png', // PNG
                    width: 24,
                    height: 24,
                  ),
                  selected: _selectedTypes.contains(type),
                  onSelected: (isSelected) {
                    _toggleTypeFilter(type);
                  },
                  tooltip: '$type',
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _isGridView
                ? GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _filteredPokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = _filteredPokemonList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PokemonDetailsScreen(pokemon: pokemon),
                      ),
                    );
                  },
                  child: PokemonCard(pokemon: pokemon, isGridView: true),
                );
              },
            )
                : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _filteredPokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = _filteredPokemonList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PokemonDetailsScreen(pokemon: pokemon),
                      ),
                    );
                  },
                  child: PokemonCard(pokemon: pokemon),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
