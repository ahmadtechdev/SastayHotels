class FlightPackage {
  final String name;
  final String checkInBaggage;
  final String cancellation;
  final String modification;
  final String seat;
  final String meal;
  final double price;
  final double? refundPrice;

  FlightPackage({
    required this.name,
    required this.checkInBaggage,
    required this.cancellation,
    required this.modification,
    required this.seat,
    required this.meal,
    required this.price,
    this.refundPrice,
  });
}