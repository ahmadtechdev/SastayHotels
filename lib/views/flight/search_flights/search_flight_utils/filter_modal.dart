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
  final int? legElapsedTime;  // Total elapsed time from the leg
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
  final List<Flight>? connectedFlights; // For storing related flights in multi-city
  final int? tripSequence; // To track order in multi-city trips
  final String? tripType; // "oneWay", "return", "multiCity"




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

  });

  // Add helper method to combine flights
  static Flight combineFlights(List<Flight> flights, String type) {
    if (flights.isEmpty) return flights.first;

    final firstFlight = flights.first;
    final lastFlight = flights.last;

    return Flight(
      imgPath: firstFlight.imgPath,
      airline: flights.map((f) => f.airline).toSet().join(' + '),
      flightNumber: flights.map((f) => f.flightNumber).join(', '),
      departureTime: firstFlight.departureTime,
      arrivalTime: lastFlight.arrivalTime,
      duration: _calculateTotalDuration(flights),
      price: flights.fold(0.0, (sum, f) => sum + f.price),
      from: firstFlight.from,
      to: lastFlight.to,
      type: type,
      isRefundable: flights.every((f) => f.isRefundable),
      isNonStop: false,
      departureTerminal: firstFlight.departureTerminal,
      arrivalTerminal: lastFlight.arrivalTerminal,
      departureCity: firstFlight.departureCity,
      arrivalCity: lastFlight.arrivalCity,
      aircraftType: flights.map((f) => f.aircraftType).join(', '),
      taxes: _combineTaxes(flights),
      baggageAllowance: firstFlight.baggageAllowance,
      packages: firstFlight.packages,
      connectedFlights: flights,
      tripType: type,
      stops: _getAllStops(flights),
      cabinClass: firstFlight.cabinClass,
      mealCode: firstFlight.mealCode,
    );
  }

  static String _calculateTotalDuration(List<Flight> flights) {
    int totalMinutes = flights.fold(0, (sum, flight) {
      final parts = flight.duration.split('h ');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1].replaceAll('m', ''));
      return sum + (hours * 60 + minutes);
    });

    return '${totalMinutes ~/ 60}h ${totalMinutes % 60}m';
  }

  static List<String> _getAllStops(List<Flight> flights) {
    List<String> allStops = [];
    for (var flight in flights) {
      allStops.addAll(flight.stops);
    }
    return allStops;
  }

  static List<TaxDesc> _combineTaxes(List<Flight> flights) {
    final Map<String, TaxDesc> combinedTaxes = {};
    for (var flight in flights) {
      for (var tax in flight.taxes) {
        if (combinedTaxes.containsKey(tax.code)) {
          combinedTaxes[tax.code] = TaxDesc(
            code: tax.code,
            amount: combinedTaxes[tax.code]!.amount + tax.amount,
            currency: tax.currency,
            description: tax.description,
          );
        } else {
          combinedTaxes[tax.code] = tax;
        }
      }
    }
    return combinedTaxes.values.toList();
  }

  static List<String> _combineStops(List<Flight> flights) {
    List<String> allStops = [];
    for (var flight in flights) {
      allStops.addAll(flight.stops);
    }
    return allStops;
  }

  factory Flight.fromApiResponse( Map<String, dynamic> schedule,
  Map<String, dynamic> fareInfo,
  List<dynamic> pkgInfo, {
  Flight? returnFlight,
  bool isReturn = false,
  String? groupId,
  List<Flight>? connectedFlights,
  int? tripSequence,
  String? tripType,}) {
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
        cabinClass: fareInfo['passengerInfoList'][0]['passengerInfo']['fareComponents'][0]['segments'][0]['segment']['cabinCode'] ?? 'Y',
        mealCode: fareInfo['passengerInfoList'][0]['passengerInfo']['fareComponents'][0]['segments'][0]['segment']['mealCode'] ?? 'N',
        returnFlight: returnFlight,
        isReturn: isReturn,
        groupId: groupId,
        connectedFlights: connectedFlights,
        tripSequence: tripSequence,
  tripType: tripType,
      );

    } catch (e, stackTrace) {
      print('Error creating Flight object: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}




// extension FlightExtension on Flight {
//   String get classOfService => 'Y'; // Default to economy, modify based on your data
//   String get flightNumber => '123'; // Get from your flight data
//   String get departureDateTime => '$departureTime:00'; // Format properly
//   String get arrivalDateTime => '$arrivalTime:00'; // Format properly
//   String get operatingCarrier => airline.substring(0, 2); // First 2 chars of airline code
//   String get marketingCarrier => airline.substring(0, 2); // First 2 chars of airline code
// }

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
      return BaggageAllowance(
          pieces: 0,
          weight: 0,
          unit: '',
          type: 'Check airline policy'
      );
    }

    // Check if we have weight-based allowance
    if (baggageInfo[0]?['allowance']?['weight'] != null) {
      return BaggageAllowance(
          pieces: 0,
          weight: (baggageInfo[0]['allowance']['weight'] as num).toDouble(),
          unit: baggageInfo[0]['allowance']['unit'] ?? 'KG',
          type: '${baggageInfo[0]['allowance']['weight']} ${baggageInfo[0]['allowance']['unit'] ?? 'KG'}'
      );
    }

    // Check if we have piece-based allowance
    if (baggageInfo[0]?['allowance']?['pieceCount'] != null) {
      return BaggageAllowance(
          pieces: baggageInfo[0]['allowance']['pieceCount'] as int,
          weight: 0,
          unit: 'PC',
          type: '${baggageInfo[0]['allowance']['pieceCount']} PC'
      );
    }

    // Default case
    return BaggageAllowance(
        pieces: 0,
        weight: 0,
        unit: '',
        type: 'Check airline policy'
    );
  } catch (e) {
    print('Error parsing baggage allowance: $e');
    return BaggageAllowance(
        pieces: 0,
        weight: 0,
        unit: '',
        type: 'Check airline policy'
    );
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