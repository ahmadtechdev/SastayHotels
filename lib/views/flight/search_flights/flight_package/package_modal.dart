import '../search_flight_utils/filter_modal.dart';

class FlightPackageInfo {
  final String cabinCode;
  final String cabinName;
  final String mealCode;
  final int seatsAvailable;
  final double totalPrice;
  final double taxAmount;
  final String currency;
  final bool isNonRefundable;
  final BaggageAllowance baggageAllowance;

  FlightPackageInfo({
    required this.cabinCode,
    String? cabinName,
    required this.mealCode,
    required this.seatsAvailable,
    required this.totalPrice,
    required this.taxAmount,
    required this.currency,
    required this.isNonRefundable,
    required this.baggageAllowance,
  }) : cabinName = cabinName ?? _deriveCabinName(cabinCode);

  static String _deriveCabinName(String code) {
    switch (code.toUpperCase()) {
      case 'F':
        return 'First Class';
      case 'C':
        return 'Business Class';
      case 'Y':
        return 'Economy Class';
      case 'W':
        return 'Premium Economy';
      default:
        return 'Economy Class';
    }
  }

  factory FlightPackageInfo.fromApiResponse(Map<String, dynamic> fareInfo) {
    try {
      final passengerInfo = fareInfo['passengerInfoList'][0]['passengerInfo'];
      final fareComponents = passengerInfo['fareComponents'][0];
      final segments = fareComponents['segments'][0]['segment'];
      final totalFare = fareInfo['totalFare'];
      final baggageInfo = passengerInfo['baggageInformation'] ?? [];

      return FlightPackageInfo(
        cabinCode: segments['cabinCode'] ?? 'Y',
        mealCode: segments['mealCode'] ?? 'N',
        seatsAvailable: segments['seatsAvailable'] ?? 0,
        totalPrice: (totalFare['totalPrice'] as num?)?.toDouble() ?? 0.0,
        taxAmount: (totalFare['totalTaxAmount'] as num?)?.toDouble() ?? 0.0,
        currency: totalFare['currency'] ?? 'PKR',
        isNonRefundable: passengerInfo['nonRefundable'] ?? true,
        baggageAllowance: parseBaggageAllowance(baggageInfo),
      );
    } catch (e) {
      print('Error parsing flight package: $e');
      return FlightPackageInfo(
        cabinCode: 'Y',
        mealCode: 'N',
        seatsAvailable: 0,
        totalPrice: 0.0,
        taxAmount: 0.0,
        currency: 'PKR',
        isNonRefundable: true,
        baggageAllowance: BaggageAllowance(
            pieces: 0,
            weight: 0,
            unit: '',
            type: 'Check airline policy'
        ),
      );
    }
  }
}