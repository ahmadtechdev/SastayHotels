// 1. First, let's update the Flight model to match the API response

import '../flight_package/package_modal.dart';

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
  final List<String> stops;  // New field
  final List<Map<String, dynamic>> stopSchedules;
  final int legElapsedTime;  // Total elapsed time from the leg



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
    this.stops = const [],  // New field with default value
    this.stopSchedules = const [],
    this.legElapsedTime = 0,
    
  });

  factory Flight.fromApiResponse(Map<String, dynamic> schedule, Map<String, dynamic> fareInfo, List<dynamic> pkgInfo) {
    try {
      final departure = schedule['departure'] as Map<String, dynamic>;
      final arrival = schedule['arrival'] as Map<String, dynamic>;
      final carrier = schedule['carrier'] as Map<String, dynamic>;

      // Get airline code and map to airline name and image
      final airlineCode = carrier['marketing'] as String? ?? 'Unknown';
      final airlineInfo = getAirlineInfo(airlineCode);

      // Safe conversion of time strings
      final departureTime = departure['time'] as String? ?? '00:00';
      final arrivalTime = arrival['time'] as String? ?? '00:00';

      // Format the times to remove timezone information
      final formattedDepartureTime = departureTime.split('+')[0];
      final formattedArrivalTime = arrivalTime.split('+')[0];

      // Safe access to nested properties
      final totalFare = (fareInfo['totalFare'] as Map<String, dynamic>?)?.cast<String, dynamic>();
      final totalPrice = totalFare?['totalPrice'] ?? 0.0;

      // Parse packages from pricingInformation array
      List<FlightPackageInfo> packages = [];
      print(pkgInfo);
      for (var pricing in pkgInfo) {
        if (pricing['fare'] != null) {
          packages.add(FlightPackageInfo.fromApiResponse(pricing['fare']));
        }
      }


      return Flight(
        imgPath: airlineInfo.logoPath,
        airline: airlineInfo.name,
        flightNumber: '${carrier['marketing'] ?? 'XX'}-${carrier['marketingFlightNumber'] ?? '000'}',
        departureTime: formattedDepartureTime,
        arrivalTime: formattedArrivalTime,
        duration: '${schedule['elapsedTime'] ~/ 60}h ${schedule['elapsedTime'] % 60}m',
        price: (totalPrice is int) ? totalPrice.toDouble() : (totalPrice as double),
        from: '${departure['city'] ?? 'Unknown'} (${departure['airport'] ?? 'XXX'})',
        to: '${arrival['city'] ?? 'Unknown'} (${arrival['airport'] ?? 'XXX'})',
        type: getFareType(fareInfo),
        isRefundable: !((fareInfo['passengerInfoList'] as List?)?.first?['passengerInfo']?['nonRefundable'] ?? true),
        isNonStop: schedule['stopCount'] == 0,
        departureTerminal: departure['terminal']?.toString() ?? 'Main',
        arrivalTerminal: arrival['terminal']?.toString() ?? 'Main',
        departureCity: departure['city']?.toString() ?? 'Unknown',
        arrivalCity: arrival['city']?.toString() ?? 'Unknown',
        aircraftType: (carrier['equipment'] as Map<String, dynamic>?)?.cast<String, dynamic>()['code']?.toString() ?? 'Unknown',
        taxes: parseTaxes(fareInfo['passengerInfoList']?[0]?['passengerInfo']?['taxes'] ?? []),
        baggageAllowance: parseBaggageAllowance(fareInfo['passengerInfoList']?[0]?['passengerInfo']?['baggageInformation'] ?? []),
        packages: packages,
      );
    } catch (e, stackTrace) {
      print('Error creating Flight object: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
extension FlightExtension on Flight {
  String get classOfService => 'Y'; // Default to economy, modify based on your data
  String get flightNumber => '123'; // Get from your flight data
  String get departureDateTime => '${departureTime}:00'; // Format properly
  String get arrivalDateTime => '${arrivalTime}:00'; // Format properly
  String get operatingCarrier => airline.substring(0, 2); // First 2 chars of airline code
  String get marketingCarrier => airline.substring(0, 2); // First 2 chars of airline code
}

String getFareType(Map<String, dynamic> fareInfo) {
  try {
    final cabinCode = fareInfo['passengerInfoList']?[0]?['passengerInfo']?['fareComponents']?[0]?['segments']?[0]?['segment']?['cabinCode'] as String?;
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
    return taxes.map((tax) => TaxDesc(
      code: tax['code']?.toString() ?? 'Unknown',
      amount: (tax['amount'] is int) ? tax['amount'].toDouble() : (tax['amount'] as double? ?? 0.0),
      currency: tax['currency']?.toString() ?? 'PKR',
      description: tax['description']?.toString() ?? 'No description',
    )).toList();
  } catch (e) {
    print('Error parsing taxes: $e');
    return [];
  }
}

BaggageAllowance parseBaggageAllowance(List<dynamic> baggageInfo) {
  try {
    if (baggageInfo.isEmpty) {
      return BaggageAllowance(pieces: 0, type: 'None');
    }

    return BaggageAllowance(
      pieces: baggageInfo[0]?['allowance']?['pieceCount'] as int? ?? 0,
      type: baggageInfo[0]?['provisionType']?.toString() ?? 'None',
    );
  } catch (e) {
    print('Error parsing baggage allowance: $e');
    return BaggageAllowance(pieces: 0, type: 'None');
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

class BaggageAllowance  {
  final int pieces;
  final String type;

  BaggageAllowance({
    required this.pieces,
    required this.type,
  });
}

// Helper functions
class AirlineInfo {
  final String name;
  final String logoPath;

  AirlineInfo(this.name, this.logoPath);
}

AirlineInfo getAirlineInfo(String code) {
  final airlineMap = {
    'SV': AirlineInfo('Saudi Airlines', 'assets/img/logos/air-arabia.png'),
    'PK': AirlineInfo('Pakistan Airlines', 'assets/img/logos/pia.png'),
    // Add more airlines as needed
  };
  return airlineMap[code] ?? AirlineInfo('Unknown Airline', 'assets/img/logos/pia.png');
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

//
// // Update FlightController to parse API response
// extension FlightControllerExtension on FlightController {
//   void parseApiResponse(Map<String, dynamic> response) {
//     final scheduleDescs = response['scheduleDescs'] as List;
//     final itineraryGroups = response['itineraryGroups'] as List;
//
//     final List<Flight> parsedFlights = [];
//
//     for (var group in itineraryGroups) {
//       for (var itinerary in group['itineraries']) {
//         for (var leg in itinerary['legs']) {
//           final scheduleRef = leg['ref'];
//           final schedule = scheduleDescs[scheduleRef - 1];
//           final fareInfo = itinerary['pricingInformation'][0]['fare'];
//
//           parsedFlights.add(Flight.fromApiResponse(schedule, fareInfo));
//         }
//       }
//     }
//
//     // Update the flights in the controller
//     flights.value = parsedFlights;
//     filteredFlights.value = parsedFlights;
//
//     // Initialize price range based on new data
//     initializeFilterRanges();
//   }
// }