class Pokemon {
  final String name;
  final String imageUrl;
  final String evolutionUrl;
  final String url;
  final List<String> types; // Agregar una lista de tipos

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.evolutionUrl,
    required this.url,
    required this.types, // Inicializar la lista de tipos
  });
}
