// 1. First, let's update the Flight model to match the API response

import '../../../../widgets/colors.dart';
import '../../../../widgets/snackbar.dart';
import '../flight_package/package_modal.dart';
import 'flight_controller.dart';

class Flight {
  final String imgPath;
  final String airline;
  final String flightNumber;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double price;
  final String from;
  final String to;
  final String type;
  final bool isRefundable;
  final bool isNonStop;
  final String departureTerminal;
  final String arrivalTerminal;
  final String departureCity;
  final String arrivalCity;
  final String aircraftType;
  final List<TaxDesc> taxes;
  final BaggageAllowance baggageAllowance;
  final List<FlightPackageInfo> packages;
  final List<String> stops; // New field
  final List<Map<String, dynamic>> stopSchedules;
  final int? legElapsedTime; // Total elapsed time from the leg
  final String cabinClass;
  final String mealCode;
  final Flight? returnFlight; // For storing return flight information
  final bool isReturn; // To identify if this is a return flight
  final String? groupId; // To group related flights together
  // New Fields for Round-Trip Support
  final String? returnDepartureTime;
  final String? returnArrivalTime;
  final String? returnFrom;
  final String? returnTo;
  final bool isRoundTrip;
  final List<Flight>?
      connectedFlights; // For storing related flights in multi-city
  final int? tripSequence; // To track order in multi-city trips
  final String? tripType; // "oneWay", "return", "multiCity"
  final List<Map<String, dynamic>> legSchedules;
  final List<FlightSegmentInfo> segmentInfo;
  final List<Map<String, dynamic>> pricingInforArray;
  // Add this new property

  Flight({
    required this.imgPath,
    required this.airline,
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.from,
    required this.to,
    required this.type,
    required this.isRefundable,
    required this.isNonStop,
    required this.departureTerminal,
    required this.arrivalTerminal,
    required this.departureCity,
    required this.arrivalCity,
    required this.aircraftType,
    required this.taxes,
    required this.baggageAllowance,
    required this.packages,
    required this.legSchedules,
    required this.segmentInfo,
    required this.stopSchedules,
    this.stops = const [],
    this.legElapsedTime = 0,
    required this.cabinClass,
    required this.mealCode,
    this.returnFlight,
    this.isReturn = false,
    this.groupId,
    // Initialize new fields
    this.returnDepartureTime,
    this.returnArrivalTime,
    this.returnFrom,
    this.returnTo,
    this.isRoundTrip = false,
    this.connectedFlights,
    this.tripSequence,
    this.tripType,
    required this.pricingInforArray
  });
}

String getFareType(Map<String, dynamic> fareInfo) {
  try {
    final cabinCode = fareInfo['passengerInfoList']?[0]?['passengerInfo']
            ?['fareComponents']?[0]?['segments']?[0]?['segment']?['cabinCode']
        as String?;
    switch (cabinCode) {
      case 'C':
        return 'Business';
      case 'F':
        return 'First';
      default:
        return 'Economy';
    }
  } catch (e) {
    return 'Economy'; // Default to Economy if there's any error
  }
}

List<TaxDesc> parseTaxes(List<dynamic> taxes) {
  try {
    return taxes
        .map((tax) => TaxDesc(
              code: tax['code']?.toString() ?? 'Unknown',
              amount: (tax['amount'] is int)
                  ? tax['amount'].toDouble()
                  : (tax['amount'] as double? ?? 0.0),
              currency: tax['currency']?.toString() ?? 'PKR',
              description: tax['description']?.toString() ?? 'No description',
            ))
        .toList();
  } catch (e) {
    print('Error parsing taxes: $e');
    return [];
  }
}

BaggageAllowance parseBaggageAllowance(List<dynamic> baggageInfo) {
  try {
    if (baggageInfo.isEmpty) {
      return BaggageAllowance(
          pieces: 0, weight: 0, unit: '', type: 'Check airline policy');
    }

    // Check if we have weight-based allowance
    if (baggageInfo[0]?['allowance']?['weight'] != null) {
      return BaggageAllowance(
          pieces: 0,
          weight: (baggageInfo[0]['allowance']['weight'] as num).toDouble(),
          unit: baggageInfo[0]['allowance']['unit'] ?? 'KG',
          type:
              '${baggageInfo[0]['allowance']['weight']} ${baggageInfo[0]['allowance']['unit'] ?? 'KG'}');
    }

    // Check if we have piece-based allowance
    if (baggageInfo[0]?['allowance']?['pieceCount'] != null) {
      return BaggageAllowance(
          pieces: baggageInfo[0]['allowance']['pieceCount'] as int,
          weight: 0,
          unit: 'PC',
          type: '${baggageInfo[0]['allowance']['pieceCount']} PC');
    }

    // Default case
    return BaggageAllowance(
        pieces: 0, weight: 0, unit: '', type: 'Check airline policy');
  } catch (e) {
    print('Error parsing baggage allowance: $e');
    return BaggageAllowance(
        pieces: 0, weight: 0, unit: '', type: 'Check airline policy');
  }
}

// Supporting classes
class TaxDesc {
  final String code;
  final double amount;
  final String currency;
  final String description;

  TaxDesc({
    required this.code,
    required this.amount,
    required this.currency,
    required this.description,
  });
}

class BaggageAllowance {
  final int pieces;
  final double weight;
  final String unit;
  final String type;

  BaggageAllowance({
    required this.pieces,
    required this.weight,
    required this.unit,
    required this.type,
  });
}

// Helper functions
class AirlineInfo {
  final String name;
  final String logoPath;

  AirlineInfo(this.name, this.logoPath);  
}

AirlineInfo getAirlineInfo(String code, Map<String, AirlineInfo>? apiAirlineMap) {
  // First try to get from API data
  if (apiAirlineMap != null && apiAirlineMap.containsKey(code)) {
    return apiAirlineMap[code]!;
  }

  CustomSnackBar(message: 'Airlines name and logo could not be loaded from API', backgroundColor: TColors.third);

  return AirlineInfo(
      'Unknown Airline',
      'https://cdn-icons-png.flaticon.com/128/15700/15700374.png');
}

class PriceInfo {
  final double totalPrice;
  final double totalTaxAmount;
  final String currency;
  final double baseFareAmount;
  final String baseFareCurrency;
  final double constructionAmount;
  final String constructionCurrency;
  final double equivalentAmount;
  final String equivalentCurrency;

  PriceInfo({
    required this.totalPrice,
    required this.totalTaxAmount,
    required this.currency,
    required this.baseFareAmount,
    required this.baseFareCurrency,
    required this.constructionAmount,
    required this.constructionCurrency,
    required this.equivalentAmount,
    required this.equivalentCurrency,
  });

  factory PriceInfo.fromApiResponse(Map<String, dynamic> fareInfo) {
    final totalFare = fareInfo['totalFare'] as Map<String, dynamic>;
    return PriceInfo(
      totalPrice: (totalFare['totalPrice'] is int)
          ? totalFare['totalPrice'].toDouble()
          : totalFare['totalPrice'] as double,
      totalTaxAmount: (totalFare['totalTaxAmount'] is int)
          ? totalFare['totalTaxAmount'].toDouble()
          : totalFare['totalTaxAmount'] as double,
      currency: totalFare['currency'] as String,
      baseFareAmount: (totalFare['baseFareAmount'] is int)
          ? totalFare['baseFareAmount'].toDouble()
          : totalFare['baseFareAmount'] as double,
      baseFareCurrency: totalFare['baseFareCurrency'] as String,
      constructionAmount: (totalFare['constructionAmount'] is int)
          ? totalFare['constructionAmount'].toDouble()
          : totalFare['constructionAmount'] as double,
      constructionCurrency: totalFare['constructionCurrency'] as String,
      equivalentAmount: (totalFare['equivalentAmount'] is int)
          ? totalFare['equivalentAmount'].toDouble()
          : totalFare['equivalentAmount'] as double,
      equivalentCurrency: totalFare['equivalentCurrency'] as String,
    );
  }

  double getPriceInCurrency(String targetCurrency) {
    switch (targetCurrency) {
      case 'PKR':
        return equivalentCurrency == 'PKR' ? equivalentAmount : totalPrice;
      case 'USD':
        return baseFareCurrency == 'USD' ? baseFareAmount : totalPrice;
      default:
        return totalPrice;
    }
  }
}
