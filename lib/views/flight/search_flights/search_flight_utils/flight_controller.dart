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

// Update FlightController to parse API response with better error handling
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
        final isRoundTrip = legDescriptions.length > 1;

        // Process each itinerary within the group
        for (var itinerary in group['itineraries'] as List) {
          final legs = itinerary['legs'] as List;
          final pricingInfo = itinerary['pricingInformation'] as List;

          if (pricingInfo.isEmpty) continue;
          final fareInfo = pricingInfo[0]['fare'];

          // For return flights, collect both outbound and inbound schedules
          if (isRoundTrip && legs.length == 2) {
            final outboundLegId = legs[0]['ref'] as int;
            final inboundLegId = legs[1]['ref'] as int;

            final outboundLegDesc = legDescsMap[outboundLegId];
            final inboundLegDesc = legDescsMap[inboundLegId];

            if (outboundLegDesc != null && inboundLegDesc != null) {
              final outboundSchedules = outboundLegDesc['schedules'] as List;
              final inboundSchedules = inboundLegDesc['schedules'] as List;

              if (outboundSchedules.isNotEmpty && inboundSchedules.isNotEmpty) {
                final outboundScheduleRef = outboundSchedules[0]['ref'] as int;
                final inboundScheduleRef = inboundSchedules[0]['ref'] as int;

                final outboundSchedule = scheduleDescsMap[outboundScheduleRef];
                final inboundSchedule = scheduleDescsMap[inboundScheduleRef];

                if (outboundSchedule != null && inboundSchedule != null) {
                  try {
                    // Create a single flight object containing both legs
                    final flight = Flight.fromApiResponse(
                        outboundSchedule,
                        fareInfo,
                        pricingInfo
                    );
                    parsedFlights.add(flight);
                  } catch (e) {
                    print('Error parsing return flight: $e');
                    continue;
                  }
                }
              }
            }
          } else {
            // Handle one-way flights as before
            final legId = legs[0]['ref'] as int;
            final legDesc = legDescsMap[legId];

            if (legDesc != null) {
              final schedules = legDesc['schedules'] as List;
              if (schedules.isNotEmpty) {
                final scheduleRef = schedules[0]['ref'] as int;
                final schedule = scheduleDescsMap[scheduleRef];

                if (schedule != null) {
                  try {
                    final flight = Flight.fromApiResponse(
                        schedule,
                        fareInfo,
                        pricingInfo
                    );
                    parsedFlights.add(flight);
                  } catch (e) {
                    print('Error parsing one-way flight: $e');
                    continue;
                  }
                }
              }
            }
          }
        }
      }

      print('Successfully parsed ${parsedFlights.length} unique flights');

      // Update the flights in the controller
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
}