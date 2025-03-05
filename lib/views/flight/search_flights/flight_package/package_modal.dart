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
  final String brandCode;
  final String brandDescription;
  final bool isSoldOut;


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
    this.brandCode = '',
    this.brandDescription = '',
    this.isSoldOut = false,
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
      final totalFare = fareInfo['totalFare'];
      final baggageInfo = passengerInfo['baggageInformation'] ?? [];

      // Default values
      String cabinCode = 'Y';
      String mealCode = 'N';
      int seatsAvailable = 0;
      String brandCode = '';
      String brandDescription = '';

      // Extract segment information if available
      if (passengerInfo.containsKey('fareComponents') &&
          passengerInfo['fareComponents'].isNotEmpty &&
          passengerInfo['fareComponents'][0].containsKey('segments') &&
          passengerInfo['fareComponents'][0]['segments'].isNotEmpty) {

        final segments = passengerInfo['fareComponents'][0]['segments'][0]['segment'];
        cabinCode = segments['cabinCode'] ?? 'Y';
        mealCode = segments['mealCode'] ?? 'N';
        seatsAvailable = segments['seatsAvailable'] ?? 0;
      }

      // Extract brand information if available
      if (passengerInfo.containsKey('fareComponents') &&
          passengerInfo['fareComponents'].isNotEmpty &&
          passengerInfo['fareComponents'][0].containsKey('brandFeatures')) {

        // Note: Need to implement brand resolution if needed
        // This would require access to the brandFeatures reference data
      }

      return FlightPackageInfo(
        cabinCode: cabinCode,
        mealCode: mealCode,
        seatsAvailable: seatsAvailable,
        totalPrice: (totalFare['totalPrice'] as num?)?.toDouble() ?? 0.0,
        taxAmount: (totalFare['totalTaxAmount'] as num?)?.toDouble() ?? 0.0,
        currency: totalFare['currency'] ?? 'PKR',
        isNonRefundable: passengerInfo['nonRefundable'] ?? true,
        baggageAllowance: parseBaggageAllowance(baggageInfo),
        brandCode: brandCode,
        brandDescription: brandDescription,
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

  // Create a sold-out package variant
  factory FlightPackageInfo.soldOut({
    required String brandCode,
    required String brandDescription,
    String cabinCode = 'Y',
  }) {
    return FlightPackageInfo(
      cabinCode: cabinCode,
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
          type: 'Not available'
      ),
      brandCode: brandCode,
      brandDescription: brandDescription,
      isSoldOut: true,
    );
  }
}