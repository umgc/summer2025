class PackageModel {
  final String name;
  final String description;
  final int priceCents; // Stripe uses cents
  final String id;

  PackageModel({
    required this.name,
    required this.description,
    required this.priceCents,
    required this.id,
  });
}
