class RecyclingBin {
  final String id;
  final String type; // Azul (Papel), Amarelo (Plástico), Verde (Vidro)
  final double latitude;
  final double longitude;
  final String address;
  final bool isFull;

  const RecyclingBin({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isFull = false,
  });
}