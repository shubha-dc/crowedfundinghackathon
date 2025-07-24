class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  double raisedAmount;
  final int sourcePercentage;
  final String sourceDescription;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.sourcePercentage,
    required this.sourceDescription,
  });
}
