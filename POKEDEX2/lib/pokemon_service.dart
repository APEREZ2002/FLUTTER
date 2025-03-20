import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pokemon.dart';

class PokemonService {
  final String _baseUrl = "https://pokeapi.co/api/v2";

  Future<String> getEvolutionChainUrl(String pokemonName) async {
    final response = await http.get(Uri.parse("$_baseUrl/pokemon-species/$pokemonName"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["evolution_chain"]["url"];
    } else {
      throw Exception("Error al obtener la evolución de $pokemonName");
    }
  }

  Future<Map<String, dynamic>> fetchPokemonDetails(String pokemonName) async {
    final response = await http.get(Uri.parse("$_baseUrl/pokemon/$pokemonName"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Obtenemos detalles del Pokémon (número, tipos, habilidades, etc.)
      return {
        "id": data["id"],
        "types": List<String>.from(data["types"].map((t) => t["type"]["name"])),
        "abilities": List<String>.from(data["abilities"].map((a) => a["ability"]["name"])),
      };
    } else {
      throw Exception("Error al obtener los detalles del Pokémon $pokemonName");
    }
  }

  Future<List<Pokemon>> fetchPokemonList() async {
    final response = await http.get(Uri.parse("https://pokeapi.co/api/v2/pokemon?limit=151"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Pokemon> pokemonList = [];

      for (var item in data['results']) {
        String pokemonName = item['name'];
        String evolutionUrl = await getEvolutionChainUrl(pokemonName);
        String pokemonUrl = item['url'];

        // Obtener los detalles del Pokémon para extraer los tipos
        final detailsResponse = await http.get(Uri.parse(pokemonUrl));
        final detailsData = json.decode(detailsResponse.body);

        List<String> types = List<String>.from(detailsData['types'].map((t) => t['type']['name']));

        pokemonList.add(Pokemon(
          name: pokemonName,
          imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/${item['url'].split('/')[6]}.gif",
          evolutionUrl: evolutionUrl,
          url: pokemonUrl,
          types: types, // Ahora se incluyen los tipos
        ));
      }
      return pokemonList;
    } else {
      throw Exception("Error al cargar los Pokémon");
    }
  }


}
