import 'dart:convert';
import 'package:http/http.dart' as http;

class EvolutionService {
  Future<List<Map<String, String>>> fetchEvolutionChain(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, String>> evolutionChain = [];

      var chain = data["chain"];
      while (chain != null) {
        String name = chain["species"]["name"];
        String id = chain["species"]["url"].split('/')[6]; // Extraemos el ID del Pokémon
        String imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif";

        evolutionChain.add({
          "name": name,
          "imageUrl": imageUrl,
        });

        chain = chain["evolves_to"].isNotEmpty ? chain["evolves_to"][0] : null;
      }

      return evolutionChain;
    } else {
      throw Exception("Error al obtener la cadena evolutiva");
    }
  }
}
