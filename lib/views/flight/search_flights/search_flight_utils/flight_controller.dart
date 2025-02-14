import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

import '../flight_package/flight_package.dart';
import '../search_flights.dart';
import 'filter_modal.dart';

class FilterState {
  final RangeValues priceRange;
  final Set<String> selectedAirlines;
  final bool isRefundable;
  final bool isNonStop;
  final Set<String> departureTimeRanges;
  final Set<String> arrivalTimeRanges;

  FilterState({
    required this.priceRange,
    required this.selectedAirlines,
    this.isRefundable = false,
    this.isNonStop = false,
    required this.departureTimeRanges,
    required this.arrivalTimeRanges,
  });

  FilterState copyWith({
    RangeValues? priceRange,
    Set<String>? selectedAirlines,
    bool? isRefundable,
    bool? isNonStop,
    Set<String>? departureTimeRanges,
    Set<String>? arrivalTimeRanges,
  }) {
    return FilterState(
      priceRange: priceRange ?? this.priceRange,
      selectedAirlines: selectedAirlines ?? this.selectedAirlines,
      isRefundable: isRefundable ?? this.isRefundable,
      isNonStop: isNonStop ?? this.isNonStop,
      departureTimeRanges: departureTimeRanges ?? this.departureTimeRanges,
      arrivalTimeRanges: arrivalTimeRanges ?? this.arrivalTimeRanges,
    );
  }
}

class FlightController extends GetxController {
  var selectedCurrency = 'PKR'.obs;
  var flights = <Flight>[].obs;
  var filteredFlights = <Flight>[].obs;
  var filterState = Rx<FilterState>(FilterState(
    priceRange: const RangeValues(0, 100000),
    selectedAirlines: {},
    isRefundable: false,
    isNonStop: false,
    departureTimeRanges: {},
    arrivalTimeRanges: {},
  ));

  // Scenario tracking
  final Rx<FlightScenario> currentScenario = FlightScenario.oneWay.obs;

  // Flight selection tracking
  final Rx<bool> isSelectingFirstFlight = true.obs;
  final Rx<Flight?> selectedFirstFlight = Rx<Flight?>(null);
  final Rx<Flight?> selectedSecondFlight = Rx<Flight?>(null);

  void resetFlightSelection() {
    isSelectingFirstFlight.value = true;
    selectedFirstFlight.value = null;
    selectedSecondFlight.value = null;
  }

  void setScenario(FlightScenario scenario) {
    currentScenario.value = scenario;
    resetFlightSelection();
  }

  void handleFlightSelection(Flight flight) {
    if (currentScenario.value == FlightScenario.oneWay) {
      // Directly proceed to package selection for one-way trips
      Get.to(() => PackageSelectionDialog(flight: flight, isAnyFlightRemaining: false,));
    } else {
      // For return trips
      if (isSelectingFirstFlight.value) {
        // Select the first flight
        selectedFirstFlight.value = flight;
        isSelectingFirstFlight.value = false;
        Get.to(() =>
            PackageSelectionDialog(flight: flight, isAnyFlightRemaining: true));
      } else {
        // Select the second flight and move to the review page
        selectedSecondFlight.value = flight;
        Get.to(() => PackageSelectionDialog(
            flight: flight, isAnyFlightRemaining: false));
      }
    }
  }

  // New: Sorting type
  var sortType = 'Suggested'.obs;


  void loadFlights(Map<String, dynamic> apiResponse) {
    parseApiResponse(apiResponse);
  }



  void changeCurrency(String currency) {
    selectedCurrency.value = currency;
    Get.back();
  }

  @override
  void onInit() {
    super.onInit();
    // loadDummyFlights();
    initializeFilterRanges();
    ever(filterState, (_) => applyFilters());
    ever(sortType,
            (_) => sortFlights()); // Sort flights when sorting type changes
  }

  void initializeFilterRanges() {
    if (flights.isEmpty) return;

    double minPrice = flights.map((f) => f.price).reduce(min);
    double maxPrice = flights.map((f) => f.price).reduce(max);

    filterState.value = filterState.value.copyWith(
      priceRange: RangeValues(minPrice, maxPrice),
    );
  }

  void applyFilters() {
    var filtered = flights.where((flight) {
      // Price filter
      if (flight.price < filterState.value.priceRange.start ||
          flight.price > filterState.value.priceRange.end) {
        return false;
      }

      // Airline filter
      if (filterState.value.selectedAirlines.isNotEmpty &&
          !filterState.value.selectedAirlines.contains(flight.airline)) {
        return false;
      }

      // Refundable filter
      if (filterState.value.isRefundable && !flight.isRefundable) {
        return false;
      } // Non Stop filter
      if (filterState.value.isNonStop && !flight.isNonStop) {
        return false;
      }

      // Time range filters
      if (filterState.value.departureTimeRanges.isNotEmpty) {
        bool matchesDeparture = false;
        for (var range in filterState.value.departureTimeRanges) {
          if (isTimeInRange(flight.departureTime, range)) {
            matchesDeparture = true;
            break;
          }
        }
        if (!matchesDeparture) return false;
      }

      if (filterState.value.arrivalTimeRanges.isNotEmpty) {
        bool matchesArrival = false;
        for (var range in filterState.value.arrivalTimeRanges) {
          if (isTimeInRange(flight.arrivalTime, range)) {
            matchesArrival = true;
            break;
          }
        }
        if (!matchesArrival) return false;
      }

      return true;
    }).toList();

    filteredFlights.value = filtered;
  }

  // New: Sort flights based on the selected sort type
  void sortFlights() {
    if (sortType.value == 'Cheapest') {
      filteredFlights.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType.value == 'Fastest') {
      filteredFlights.sort((a, b) {
        return parseTimeToDouble(a.duration)
            .compareTo(parseTimeToDouble(b.duration));
      });
    } else {
      filteredFlights.value =
          flights.toList(); // Default: Suggested (original order)
    }
  }

  // New: Update the sorting type
  void updateSortType(String type) {
    sortType.value = type;
  }

  bool isTimeInRange(String flightTime, String range) {
    final time = parseTimeToDouble(flightTime);

    switch (range) {
      case '00:00 - 06:00':
        return time >= 0 && time < 6;
      case '06:00 - 12:00':
        return time >= 6 && time < 12;
      case '12:00 - 18:00':
        return time >= 12 && time < 18;
      case '18:00 - 00:00':
        return time >= 18 && time < 24;
      default:
        return false;
    }
  }

  double parseTimeToDouble(String timeStr) {
    if (timeStr.contains('h')) {
      // Handle duration strings like "2h 30m"
      final parts = timeStr.split(' ');
      double hours = double.tryParse(parts[0].replaceAll('h', '').trim()) ?? 0;
      double minutes = parts.length > 1
          ? double.tryParse(parts[1].replaceAll('m', '').trim()) ?? 0
          : 0;
      return hours + (minutes / 60);
    } else if (timeStr.contains(':')) {
      // Handle time strings like "09:30 AM"
      final parts = timeStr.split(':');
      double hours = double.tryParse(parts[0]) ?? 0;
      double minutes = double.tryParse(parts[1].split(' ')[0]) ?? 0 / 60;

      if (timeStr.contains('PM') && hours != 12) {
        hours += 12;
      } else if (timeStr.contains('AM') && hours == 12) {
        hours = 0;
      }

      return hours + minutes;
    } else {
      // If the string format is unrecognized, return 0
      throw FormatException("Invalid time format: $timeStr");
    }
  }

  void updatePriceRange(RangeValues values) {
    filterState.value = filterState.value.copyWith(priceRange: values);
  }

  void toggleAirline(String airline) {
    var airlines = Set<String>.from(filterState.value.selectedAirlines);
    if (airlines.contains(airline)) {
      airlines.remove(airline);
    } else {
      airlines.add(airline);
    }
    filterState.value = filterState.value.copyWith(selectedAirlines: airlines);
  }

  void toggleTimeRange(String range, bool isDeparture) {
    var ranges = isDeparture
        ? Set<String>.from(filterState.value.departureTimeRanges)
        : Set<String>.from(filterState.value.arrivalTimeRanges);

    if (ranges.contains(range)) {
      ranges.remove(range);
    } else {
      ranges.add(range);
    }

    filterState.value = filterState.value.copyWith(
      departureTimeRanges: isDeparture ? ranges : null,
      arrivalTimeRanges: isDeparture ? null : ranges,
    );
  }

  void toggleRefundable(bool value) {
    filterState.value = filterState.value.copyWith(isRefundable: value);
  }

  void toggleNonStop(bool value) {
    filterState.value = filterState.value.copyWith(isNonStop: value);
  }

  void resetFilters() {
    initializeFilterRanges();
    filterState.value = FilterState(
      priceRange: filterState.value.priceRange,
      selectedAirlines: {},
      isRefundable: false,
      isNonStop: false,
      departureTimeRanges: {},
      arrivalTimeRanges: {},
    );
    sortType.value = 'Suggested'; // Reset sorting type as well
  }
}


extension FlightControllerExtension on FlightController {
  void parseApiResponse(Map<String, dynamic>? response) {
    try {
      if (response == null || response['groupedItineraryResponse'] == null) {
        print('Error: Invalid API response structure');
        flights.value = [];
        filteredFlights.value = [];
        return;
      }

      final groupedResponse = response['groupedItineraryResponse'];

      // Create a map of baggage allowance descriptions for quick lookup
      final baggageAllowanceDescsMap = <int, Map<String, dynamic>>{};
      if (groupedResponse['baggageAllowanceDescs'] != null) {
        for (var baggage in groupedResponse['baggageAllowanceDescs'] as List) {
          baggageAllowanceDescsMap[baggage['id'] as int] = baggage;
        }
      }

      // Cache all schedule descriptions for quick lookup
      final scheduleDescsMap = <int, Map<String, dynamic>>{};
      if (groupedResponse['scheduleDescs'] != null) {
        for (var schedule in groupedResponse['scheduleDescs'] as List) {
          scheduleDescsMap[schedule['id'] as int] = schedule as Map<String, dynamic>;
        }
      }

      // Cache all leg descriptions for quick lookup
      final legDescsMap = <int, Map<String, dynamic>>{};
      if (groupedResponse['legDescs'] != null) {
        for (var leg in groupedResponse['legDescs'] as List) {
          legDescsMap[leg['id'] as int] = leg as Map<String, dynamic>;
        }
      }

      final List<Flight> parsedFlights = [];

      // Process each itinerary group
      for (var group in groupedResponse['itineraryGroups'] as List) {
        final groupDesc = group['groupDescription'];
        final legDescriptions = groupDesc['legDescriptions'] as List;

        // Process each itinerary within the group
        for (var itinerary in group['itineraries'] as List) {
          final legs = itinerary['legs'] as List;
          final pricingInfo = itinerary['pricingInformation'] as List;

          if (pricingInfo.isEmpty) continue;
          final fareInfo = pricingInfo[0]['fare'];

          // Parse baggage information with the new logic
          BaggageAllowance baggageAllowance = _parseBaggageAllowance(
              fareInfo['passengerInfoList'][0]['passengerInfo']['baggageInformation'] as List,
              baggageAllowanceDescsMap
          );

          for (var leg in legs) {
            final legId = leg['ref'] as int;
            final legDesc = legDescsMap[legId];

            if (legDesc != null) {
              final schedules = legDesc['schedules'] as List;
              if (schedules.isEmpty) continue;

              // Get all schedules for this leg to track stops
              List<Map<String, dynamic>> stopSchedules = [];
              for (var scheduleRef in schedules) {
                final schedule = scheduleDescsMap[scheduleRef['ref']];
                if (schedule != null) {
                  stopSchedules.add(schedule);
                }
              }

              if (stopSchedules.isEmpty) continue;

              // Get first and last schedule for origin and destination
              final firstSchedule = stopSchedules.first;
              final lastSchedule = stopSchedules.last;

              // Calculate stops
              List<String> stops = [];
              if (stopSchedules.length > 1) {
                for (int i = 0; i < stopSchedules.length - 1; i++) {
                  stops.add(stopSchedules[i]['arrival']['city'] ?? "Unknown City");
                }
              }

              // Calculate total duration from first departure to last arrival
              final totalDuration = legDesc['elapsedTime'];

              // Get carrier info from first schedule
              final carrier = firstSchedule['carrier'];
              final airlineCode = carrier['marketing'] as String? ?? 'Unknown';
              final airlineInfo = getAirlineInfo(airlineCode);

              try {
                final flight = Flight(
                  // ... (previous flight properties remain the same)
                  imgPath: airlineInfo.logoPath,
                  airline: airlineInfo.name,
                  flightNumber: '${carrier['marketing'] ?? 'XX'}-${carrier['marketingFlightNumber'] ?? '000'}',
                  departureTime: firstSchedule['departure']['time'].split('+')[0],
                  arrivalTime: lastSchedule['arrival']['time'].split('+')[0],
                  duration: '${totalDuration ~/ 60}h ${totalDuration % 60}m',
                  price: fareInfo['totalFare']['totalPrice'].toDouble(),
                  from: '${firstSchedule['departure']['city']} (${firstSchedule['departure']['airport']})',
                  to: '${lastSchedule['arrival']['city']} (${lastSchedule['arrival']['airport']})',
                  type: getFareType(fareInfo),
                  isRefundable: !((fareInfo['passengerInfoList'] as List?)?.first?['passengerInfo']?['nonRefundable'] ?? true),
                  isNonStop: stopSchedules.length == 1,
                  departureTerminal: firstSchedule['departure']['terminal']?.toString() ?? 'Main',
                  arrivalTerminal: lastSchedule['arrival']['terminal']?.toString() ?? 'Main',
                  departureCity: firstSchedule['departure']['city']?.toString() ?? 'Unknown',
                  arrivalCity: lastSchedule['arrival']['city']?.toString() ?? 'Unknown',
                  aircraftType: carrier['equipment']['code'].toString(),
                  taxes: parseTaxes(fareInfo['passengerInfoList']?[0]?['passengerInfo']?['taxes'] ?? []),
                  baggageAllowance: baggageAllowance,
                  packages: [],
                  stops: stops,
                  legElapsedTime: legDesc['elapsedTime'] as int?,
                  stopSchedules: stopSchedules.map((schedule) => {
                    'departure': {
                      'city': schedule['departure']['city'],
                      'airport': schedule['departure']['airport'],
                      'time': schedule['departure']['time'],
                      'terminal': schedule['departure']['terminal'],
                    },
                    'arrival': {
                      'city': schedule['arrival']['city'],
                      'airport': schedule['arrival']['airport'],
                      'time': schedule['arrival']['time'],
                      'terminal': schedule['arrival']['terminal'],
                    },
                    'elapsedTime': schedule['elapsedTime'] as int?,
                  }).toList(),
                  cabinClass: fareInfo['passengerInfoList'][0]['passengerInfo']['fareComponents'][0]['segments'][0]['segment']['cabinCode'] ?? 'Y',
                  mealCode: fareInfo['passengerInfoList'][0]['passengerInfo']['fareComponents'][0]['segments'][0]['segment']['mealCode'] ?? 'N',
                );
                parsedFlights.add(flight);
              } catch (e) {
                print('Error parsing flight: $e');
                continue;
              }
            }
          }
        }
      }
      print('Successfully parsed ${parsedFlights.length} unique flights');
      flights.value = parsedFlights;
      filteredFlights.value = parsedFlights;

      if (parsedFlights.isNotEmpty) {
        initializeFilterRanges();
      }

    } catch (e, stackTrace) {
      print('Error parsing API response: $e');
      print('Stack trace: $stackTrace');
      flights.value = [];
      filteredFlights.value = [];
    }
  }

  // New helper method to parse baggage allowance
  BaggageAllowance _parseBaggageAllowance(
      List baggageInformation,
      Map<int, Map<String, dynamic>> baggageAllowanceDescsMap
      ) {
    try {
      for (var baggageInfo in baggageInformation) {
        if (baggageInfo['allowance'] != null && baggageInfo['allowance']['ref'] != null) {
          final baggageRef = baggageInfo['allowance']['ref'] as int;
          final baggageDesc = baggageAllowanceDescsMap[baggageRef];

          if (baggageDesc != null) {
            if (baggageDesc.containsKey('weight')) {
              return BaggageAllowance(
                  pieces: 0,
                  weight: (baggageDesc['weight'] as num).toDouble(),
                  unit: baggageDesc['unit'] as String,
                  type: '${baggageDesc['weight']} ${baggageDesc['unit']}'
              );
            } else if (baggageDesc.containsKey('pieceCount')) {
              return BaggageAllowance(
                  pieces: baggageDesc['pieceCount'] as int,
                  weight: 0,
                  unit: 'PC',
                  type: '${baggageDesc['pieceCount']} PC'
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing baggage allowance: $e');
    }

    // Default return if no valid baggage information is found
    return BaggageAllowance(
        pieces: 0,
        weight: 0,
        unit: '',
        type: 'Check airline policy'
    );
  }
}