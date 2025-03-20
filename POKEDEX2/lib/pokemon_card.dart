import 'package:flutter/material.dart';
import 'package:pokedex/PokemonTypeColors.dart';
import 'pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool isGridView;

  const PokemonCard({Key? key, required this.pokemon, this.isGridView = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asignar los colores según los tipos del Pokémon
    String primaryType = pokemon.types.isNotEmpty ? pokemon.types[0] : 'normal';
    String secondaryType = pokemon.types.length > 1 ? pokemon.types[1] : 'normal';

    Color primaryColor = PokemonTypeColors.typeColors[primaryType] ?? Colors.grey;
    Color secondaryColor = PokemonTypeColors.typeColors[secondaryType] ?? Colors.grey;

    // Si el Pokémon tiene dos tipos, aplicamos el gradiente
    Widget cardContent = Padding(
      padding: const EdgeInsets.all(12.0),
      child: isGridView
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(pokemon.imageUrl, width: 90, height: 90),
          ),
          const SizedBox(height: 8),
          Text(
            pokemon.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
        ],
      )
          : Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(pokemon.imageUrl, width: 80, height: 80),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              pokemon.name.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );

    // Si tiene solo un tipo, mostramos solo el color primario
    if (pokemon.types.length > 1) {
      // Crear el gradiente dividido al 50% entre el color primario y el color secundario
      List<Color> gradientColors = [
        primaryColor,
        secondaryColor,
      ];

      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: cardContent,
        ),
      );
    } else {
      // Si tiene solo un tipo, se aplica solo el color primario
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: primaryColor, // Solo un color
        child: cardContent,
      );
    }
  }
}
