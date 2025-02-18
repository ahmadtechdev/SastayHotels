
import '../search_flight_utils/filter_modal.dart';

class FlightPackageInfo {
  final String cabinCode;
  final String mealCode;
  final int seatsAvailable;
  final double totalPrice;
  final double taxAmount;
  final String currency;
  final bool isNonRefundable;
  final BaggageAllowance baggageAllowance;

  FlightPackageInfo({
    required this.cabinCode,
    required this.mealCode,
    required this.seatsAvailable,
    required this.totalPrice,
    required this.taxAmount,
    required this.currency,
    required this.isNonRefundable,
    required this.baggageAllowance,
  });

  factory FlightPackageInfo.fromApiResponse(Map<String, dynamic> fareInfo) {
    final passengerInfo = fareInfo['passengerInfoList'][0]['passengerInfo'];
    final segments = passengerInfo['fareComponents'][0]['segments'][0]['segment'];
    final totalFare = fareInfo['totalFare'];

    return FlightPackageInfo(
      cabinCode: segments['cabinCode'] ?? 'Y',
      mealCode: segments['mealCode'] ?? 'M',
      seatsAvailable: segments['seatsAvailable'] ?? 0,
      totalPrice: totalFare['totalPrice']?.toDouble() ?? 0.0,
      taxAmount: totalFare['totalTaxAmount']?.toDouble() ?? 0.0,
      currency: totalFare['currency'] ?? 'PKR',
      isNonRefundable: passengerInfo['nonRefundable'] ?? true,
      baggageAllowance: parseBaggageAllowance(passengerInfo['baggageInformation'] ?? []),
    );


  }


  String get cabinName {
    switch (cabinCode) {
      case 'F':
        return 'First Class';
      case 'C':
        return 'Business Class';
      case 'Y':
      default:
        return 'Economy Class';
    }
  }
}

