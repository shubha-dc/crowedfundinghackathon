class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  double raisedAmount;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
  });
}
