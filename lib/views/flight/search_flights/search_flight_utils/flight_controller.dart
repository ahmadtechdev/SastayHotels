import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

import '../../../../services/api_service_flight.dart';
import '../flight_package/flight_package.dart';
import '../flight_package/package_modal.dart';
import '../search_flights.dart';
import 'filter_modal.dart';

class FilterState {
  final RangeValues priceRange;
  final Set<String> selectedAirlines;
  final bool isRefundable; // This will represent "Refundable"
  final bool isNonRefundable; // This will represent "Non-Refundable"
  final bool isRefundableAll; // This will represent "All"
  final bool isNonStop;
  final Set<String> departureTimeRanges;
  final Set<String> arrivalTimeRanges;
  final Set<String> selectedStops;

  FilterState({
    required this.priceRange,
    required this.selectedAirlines,
    this.isRefundable = false,
    this.isNonRefundable = false,
    this.isRefundableAll = true, // Default to true to include all
    this.isNonStop = false,
    required this.departureTimeRanges,
    required this.arrivalTimeRanges,
    required this.selectedStops,
  });

  // Factory constructor for default values with "All" options selected
  factory FilterState.defaultState(RangeValues priceRange) {
    return FilterState(
      priceRange: priceRange,
      selectedAirlines: {"All Airlines"},
      isRefundable: false,
      isNonRefundable: false,
      isRefundableAll: true,
      isNonStop: false,
      departureTimeRanges: {"All Times"},
      arrivalTimeRanges: {"All Times"},
      selectedStops: {"All"},
    );
  }

  FilterState copyWith({
    RangeValues? priceRange,
    Set<String>? selectedAirlines,
    bool? isRefundable,
    bool? isNonRefundable,
    bool? isRefundableAll,
    bool? isNonStop,
    Set<String>? departureTimeRanges,
    Set<String>? arrivalTimeRanges,
    Set<String>? selectedStops,
  }) {
    return FilterState(
      priceRange: priceRange ?? this.priceRange,
      selectedAirlines: selectedAirlines ?? this.selectedAirlines,
      isRefundable: isRefundable ?? this.isRefundable,
      isNonRefundable: isNonRefundable ?? this.isNonRefundable,
      isRefundableAll: isRefundableAll ?? this.isRefundableAll,
      isNonStop: isNonStop ?? this.isNonStop,
      departureTimeRanges: departureTimeRanges ?? this.departureTimeRanges,
      arrivalTimeRanges: arrivalTimeRanges ?? this.arrivalTimeRanges,
      selectedStops: selectedStops ?? this.selectedStops,
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
    selectedStops: {},
  ));

  void toggleRefundableAll(bool value) {
    filterState.value = filterState.value.copyWith(
      isRefundableAll: value,
      isRefundable:
          !value, // Ensure that if "All" is selected, other options are deselected
      isNonRefundable: !value,
    );
  }

  void toggleRefundable(bool value) {
    filterState.value = filterState.value.copyWith(
      isRefundable: value,
      isRefundableAll: false, // Deselect "All" if "Refundable" is selected
      isNonRefundable: false,
    );
  }

  void toggleNonRefundable(bool value) {
    filterState.value = filterState.value.copyWith(
      isNonRefundable: value,
      isRefundableAll: false, // Deselect "All" if "Non-Refundable" is selected
      isRefundable: false,
    );
  }

//  / For Stops filter
  void toggleStopOption(String option, bool isSelected) {
    var stops = Set<String>.from(filterState.value.selectedStops);

    // If selecting a new option
    if (isSelected) {
      // Clear all other options if selecting a specific option
      stops.clear();
      stops.add(option);

      // If "All" is being selected, make sure it's the only option
      if (option == 'All') {
        stops = {'All'};
      }
    } else {
      // If deselecting an option
      stops.remove(option);

      // If no options remain, select "All"
      if (stops.isEmpty) {
        stops.add('All');
      }
    }

    filterState.value = filterState.value.copyWith(selectedStops: stops);
  }

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
      Get.to(() => PackageSelectionDialog(
            flight: flight,
            isAnyFlightRemaining: false,
          ));
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
    // loadDummyFlights();
    initializeFilterRanges();

    // Initialize filter state with "All" options selected by default
    filterState.value = FilterState(
      priceRange: const RangeValues(0, 100000),
      selectedAirlines: {"All Airlines"},
      isRefundable: false,
      isNonRefundable: false,
      isRefundableAll: true,
      departureTimeRanges: {"All Times"},
      arrivalTimeRanges: {"All Times"},
      selectedStops: {"All"},
      isNonStop: false,
    );

    ever(filterState, (_) => applyFilters());
    ever(sortType, (_) => sortFlights());
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

      // Airline filter - skip if "All Airlines" is selected
      if (!filterState.value.selectedAirlines.contains("All Airlines") &&
          !filterState.value.selectedAirlines.contains(flight.airline)) {
        return false;
      }

      // Refundable filter logic
      if (!filterState.value.isRefundableAll) {
        if (filterState.value.isRefundable && !flight.isRefundable) {
          return false;
        }
        if (filterState.value.isNonRefundable && flight.isRefundable) {
          return false;
        }
      }

      // Non-stop filter
      if (filterState.value.isNonStop && !flight.isNonStop) {
        return false;
      }

      // Time range filters for departure - skip if "All Times" is selected
      if (!filterState.value.departureTimeRanges.contains("All Times") &&
          filterState.value.departureTimeRanges.isNotEmpty) {
        bool matchesDeparture = false;
        for (var range in filterState.value.departureTimeRanges) {
          if (range != "All Times" &&
              isTimeInRange(flight.departureTime, range)) {
            matchesDeparture = true;
            break;
          }
        }
        if (!matchesDeparture) return false;
      }

      // Time range filters for arrival - skip if "All Times" is selected
      if (!filterState.value.arrivalTimeRanges.contains("All Times") &&
          filterState.value.arrivalTimeRanges.isNotEmpty) {
        bool matchesArrival = false;
        for (var range in filterState.value.arrivalTimeRanges) {
          if (range != "All Times" &&
              isTimeInRange(flight.arrivalTime, range)) {
            matchesArrival = true;
            break;
          }
        }
        if (!matchesArrival) return false;
      }

      // Stop options filter
      if (!filterState.value.selectedStops.contains("All")) {
        int stopCount = flight.stopSchedules.length - 1;
        String stopOption =
            stopCount.toString() + (stopCount == 1 ? ' Stop' : ' Stops');
        if (!filterState.value.selectedStops.contains(stopOption)) {
          return false;
        }
      }

      return true;
    }).toList();

    filteredFlights.value = filtered;
  }

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

    // Check if we're toggling an "All Airlines" option
    if (airline == "All Airlines") {
      if (!airlines.contains(airline)) {
        // Clear all selected airlines and select only "All Airlines"
        airlines.clear();
        airlines.add(airline);
      } else {
        // If deselecting "All Airlines", leave empty (will be handled below)
        airlines.remove(airline);
      }
    } else {
      // If selecting a specific airline
      if (!airlines.contains(airline)) {
        // Remove "All Airlines" if it's selected
        airlines.remove("All Airlines");
        // Add the specific airline
        airlines.add(airline);
      } else {
        // If deselecting a specific airline
        airlines.remove(airline);
      }
    }

    // If no airlines are selected, select "All Airlines"
    if (airlines.isEmpty) {
      airlines.add("All Airlines");
    }

    filterState.value = filterState.value.copyWith(selectedAirlines: airlines);
  }

  void toggleTimeRange(String range, bool isDeparture) {
    var ranges = isDeparture
        ? Set<String>.from(filterState.value.departureTimeRanges)
        : Set<String>.from(filterState.value.arrivalTimeRanges);

    // Check if we're toggling an "All Times" option
    if (range == "All Times") {
      if (!ranges.contains(range)) {
        // Clear all time ranges and select only "All Times"
        ranges.clear();
        ranges.add(range);
      } else {
        // If deselecting "All Times", leave empty (will be handled below)
        ranges.remove(range);
      }
    } else {
      // If selecting a specific time range
      if (!ranges.contains(range)) {
        // Remove "All Times" if it's selected
        ranges.remove("All Times");
        // Add the specific time range
        ranges.add(range);
      } else {
        // If deselecting a specific time range
        ranges.remove(range);
      }
    }

    // If no time ranges are selected, select "All Times"
    if (ranges.isEmpty) {
      ranges.add("All Times");
    }

    filterState.value = filterState.value.copyWith(
      departureTimeRanges: isDeparture ? ranges : null,
      arrivalTimeRanges: isDeparture ? null : ranges,
    );
  }

  void toggleNonStop(bool value) {
    filterState.value = filterState.value.copyWith(isNonStop: value);
  }

  void resetFilters() {
    initializeFilterRanges();
    filterState.value = FilterState(
      priceRange: filterState.value.priceRange,
      selectedAirlines: {"All Airlines"},
      isRefundable: false,
      isNonRefundable: false,
      isRefundableAll: true,
      isNonStop: false,
      departureTimeRanges: {"All Times"},
      arrivalTimeRanges: {"All Times"},
      selectedStops: {"All"},
    );
    sortType.value = 'Suggested';
  }
}

extension FlightDateTimeExtension on FlightController {
  // Add this method to parse segment information
  List<FlightSegmentInfo> parseSegmentInfo(
      Map<String, dynamic> fareInfo, List<dynamic> legs) {
    List<FlightSegmentInfo> segmentInfoList = [];

    try {
      // Get fare components which correspond to each leg
      final fareComponents = fareInfo['passengerInfoList'][0]['passengerInfo']
          ['fareComponents'] as List;

      // Iterate through each leg
      for (var i = 0; i < legs.length; i++) {
        if (i < fareComponents.length) {
          final fareComponent = fareComponents[i];
          final segments = fareComponent['segments'] as List;

          // Add segment info for each segment in the fare component
          for (var segment in segments) {
            segmentInfoList.add(FlightSegmentInfo(
              bookingCode: segment['segment']['bookingCode'] ?? '',
              cabinCode: segment['segment']['cabinCode'] ?? '',
              mealCode: segment['segment']['mealCode'] ?? '',
              seatsAvailable: segment['segment']['seatsAvailable'] ?? 'N',
            ));
          }
        }
      }
    } catch (e) {
      print('Error parsing segment info: $e');
    }

    return segmentInfoList;
  }

  // Add this utility function to format DateTime without milliseconds
  String _formatDateTimeWithoutMillis(DateTime dateTime) {
    // Format: YYYY-MM-DDTHH:mm:ss
    return "${dateTime.year.toString().padLeft(4, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.day.toString().padLeft(2, '0')}T"
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}:"
        "${dateTime.second.toString().padLeft(2, '0')}";
  }

  DateTime _calculateFlightDateTime(
      String baseDate, String timeString, int? dateAdjustment) {
    DateTime date = DateTime.parse(baseDate);
    final timeParts = timeString.split('+')[0].split(':');
    final hours = int.parse(timeParts[0]);
    final minutes = int.parse(timeParts[1]);
    final seconds = int.parse(timeParts[2]);

    DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hours,
      minutes,
      seconds,
    );

    if (dateAdjustment != null) {
      dateTime = dateTime.add(Duration(days: dateAdjustment));
    }

    return dateTime;
  }

  void parseApiResponse(Map<String, dynamic>? response) {
    try {
      if (response == null || response['groupedItineraryResponse'] == null) {
        print('Error: Invalid API response structure');
        flights.value = [];
        filteredFlights.value = [];
        return;
      }

      final groupedResponse = response['groupedItineraryResponse'];
      final baggageAllowanceDescsMap = <int, Map<String, dynamic>>{};
      if (groupedResponse['baggageAllowanceDescs'] != null) {
        for (var baggage in groupedResponse['baggageAllowanceDescs'] as List) {
          baggageAllowanceDescsMap[baggage['id'] as int] = baggage;
        }
      }

      final scheduleDescsMap = <int, Map<String, dynamic>>{};
      if (groupedResponse['scheduleDescs'] != null) {
        for (var schedule in groupedResponse['scheduleDescs'] as List) {
          scheduleDescsMap[schedule['id'] as int] = schedule;
        }
      }

      final legDescsMap = <int, Map<String, dynamic>>{};
      if (groupedResponse['legDescs'] != null) {
        for (var leg in groupedResponse['legDescs'] as List) {
          legDescsMap[leg['id'] as int] = leg;
        }
      }

      final List<Flight> parsedFlights = [];
      final itineraryGroups = groupedResponse['itineraryGroups'] as List?;
      if (itineraryGroups == null) {
        print('Error: No itinerary groups found');
        flights.value = [];
        filteredFlights.value = [];
        return;
      }

      for (var group in itineraryGroups) {
        final legDescriptions =
            group['groupDescription']['legDescriptions'] as List?;
        if (legDescriptions == null) continue;

        final itineraries = group['itineraries'] as List?;
        if (itineraries == null) continue;

        for (var itinerary in itineraries) {
          final legs = itinerary['legs'] as List?;
          if (legs == null) continue;

          final pricingInfo = itinerary['pricingInformation'] as List?;
          if (pricingInfo == null || pricingInfo.isEmpty) continue;

          final List<FlightPackageInfo> packages = [];
          for (var pricing in pricingInfo) {
            try {
              final fareInfo = pricing['fare'];
              if (fareInfo != null) {
                packages.add(FlightPackageInfo.fromApiResponse(fareInfo));
              }
            } catch (e) {
              print('Error parsing package: $e');
            }
          }

          final mainFareInfo = pricingInfo[0]['fare'];

          // Parse segment information for this itinerary
          final segmentInfoList = parseSegmentInfo(mainFareInfo, legs);

          List<Map<String, dynamic>> allStopSchedules = [];
          List<String> allStops = [];
          int totalDuration = 0;
          List<Map<String, dynamic>> legSchedules = [];

          for (var legIndex = 0; legIndex < legs.length; legIndex++) {
            final leg = legs[legIndex];
            final legId = leg['ref'] as int;
            final legDesc = legDescsMap[legId];
            if (legDesc == null) continue;

            final baseDate =
                legDescriptions[legIndex]['departureDate'] as String;
            final schedules = legDesc['schedules'] as List?;
            if (schedules == null) continue;

            List<Map<String, dynamic>> currentLegSchedules = [];
            List<String> currentLegStops = [];

            for (var scheduleRef in schedules) {
              final schedule = scheduleDescsMap[scheduleRef['ref']];
              if (schedule == null) continue;

              final departureDateAdjustment =
                  scheduleRef['departureDateAdjustment'] as int?;
              final arrivalDateAdjustment =
                  schedule['arrival']['dateAdjustment'] as int?;

              final departureDateTime = _calculateFlightDateTime(baseDate,
                  schedule['departure']['time'], departureDateAdjustment);

              final arrivalDateTime = _calculateFlightDateTime(
                  baseDate, schedule['arrival']['time'], arrivalDateAdjustment);

              final scheduleWithDateTime = Map<String, dynamic>.from(schedule);
              scheduleWithDateTime['departure'] =
                  Map<String, dynamic>.from(schedule['departure']);
              scheduleWithDateTime['arrival'] =
                  Map<String, dynamic>.from(schedule['arrival']);

              scheduleWithDateTime['departure']['dateTime'] =
                  _formatDateTimeWithoutMillis(departureDateTime);
              scheduleWithDateTime['arrival']['dateTime'] =
                  _formatDateTimeWithoutMillis(arrivalDateTime);

              currentLegSchedules.add(scheduleWithDateTime);
              allStopSchedules.add(scheduleWithDateTime);

              // Only add intermediate stops
              if (currentLegSchedules.length > 1) {
                for (int i = 0; i < currentLegSchedules.length - 1; i++) {
                  currentLegStops.add(currentLegSchedules[i]['arrival']
                          ['city'] ??
                      "Unknown City");
                }
              }
            }

            if (currentLegSchedules.isNotEmpty) {
              legSchedules.add({
                'departure': currentLegSchedules.first['departure'],
                'arrival': currentLegSchedules.last['arrival'],
                'schedules': currentLegSchedules,
                'stops': currentLegStops,
                'elapsedTime': legDesc['elapsedTime'],
              });
            }

            totalDuration += legDesc['elapsedTime'] as int;
          }

          if (allStopSchedules.isEmpty) continue;

          try {
            final firstSchedule = allStopSchedules.first;
            final lastSchedule = allStopSchedules.last;
            final carrier = firstSchedule['carrier'];
            final airlineCode = carrier['marketing'] as String? ?? 'Unknown';
            final ApiServiceFlight apiService = Get.put(ApiServiceFlight());
            final airlineMap = apiService.getAirlineMap();
            final airlineInfo = getAirlineInfo(airlineCode, airlineMap);

            final flight = Flight(
              imgPath: airlineInfo.logoPath,
              airline: airlineInfo.name,
              flightNumber:
                  '${carrier['marketing'] ?? 'XX'}-${carrier['marketingFlightNumber'] ?? '000'}',
              departureTime: firstSchedule['departure']['dateTime'],
              arrivalTime: lastSchedule['arrival']['dateTime'],
              duration: '${totalDuration ~/ 60}h ${totalDuration % 60}m',
              price:
                  (mainFareInfo['totalFare']['totalPrice'] as num).toDouble(),
              from:
                  '${firstSchedule['departure']['city'] ?? 'Unknown'} (${firstSchedule['departure']['airport'] ?? 'Unknown'})',
              to: '${lastSchedule['arrival']['city'] ?? 'Unknown'} (${lastSchedule['arrival']['airport'] ?? 'Unknown'})',
              legSchedules: legSchedules,
              stopSchedules: allStopSchedules,
              type: getFareType(mainFareInfo),
              isRefundable: !(mainFareInfo['passengerInfoList'][0]
                      ['passengerInfo']['nonRefundable'] ??
                  true),
              isNonStop: allStopSchedules.length == 1,
              departureTerminal:
                  firstSchedule['departure']['terminal']?.toString() ?? 'Main',
              arrivalTerminal:
                  lastSchedule['arrival']['terminal']?.toString() ?? 'Main',
              departureCity:
                  firstSchedule['departure']['city']?.toString() ?? 'Unknown',
              arrivalCity:
                  lastSchedule['arrival']['city']?.toString() ?? 'Unknown',
              aircraftType:
                  carrier['equipment']['code']?.toString() ?? 'Unknown',
              taxes: parseTaxes(mainFareInfo['passengerInfoList'][0]
                      ['passengerInfo']['taxes'] ??
                  []),
              baggageAllowance: _parseBaggageAllowance(
                  mainFareInfo['passengerInfoList'][0]['passengerInfo']
                          ['baggageInformation'] as List? ??
                      [],
                  baggageAllowanceDescsMap),
              packages: packages,
              stops: allStops
                  .where((stop) =>
                      stop != firstSchedule['departure']['city'] &&
                      stop != lastSchedule['arrival']['city'])
                  .toList(),
              legElapsedTime: totalDuration,
              cabinClass: mainFareInfo['passengerInfoList'][0]['passengerInfo']
                          ['fareComponents'][0]['segments'][0]['segment']
                      ['cabinCode'] ??
                  'Y',
              mealCode: mainFareInfo['passengerInfoList'][0]['passengerInfo']
                          ['fareComponents'][0]['segments'][0]['segment']
                      ['mealCode'] ??
                  'N',
              groupId: itinerary['id'].toString(),
              segmentInfo: segmentInfoList,
            );
            parsedFlights.add(flight);
          } catch (e) {
            print('Error creating flight: $e');
          }
        }
      }

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

  BaggageAllowance _parseBaggageAllowance(List baggageInformation,
      Map<int, Map<String, dynamic>> baggageAllowanceDescsMap) {
    try {
      for (var baggageInfo in baggageInformation) {
        final allowance = baggageInfo['allowance'];
        if (allowance == null) continue;

        final baggageRef = allowance['ref'] as int?;
        if (baggageRef == null) continue;

        final baggageDesc = baggageAllowanceDescsMap[baggageRef];
        if (baggageDesc == null) continue;

        if (baggageDesc.containsKey('weight')) {
          return BaggageAllowance(
              pieces: 0,
              weight: (baggageDesc['weight'] as num).toDouble(),
              unit: baggageDesc['unit'] as String? ?? '',
              type: '${baggageDesc['weight']} ${baggageDesc['unit'] ?? ''}');
        } else if (baggageDesc.containsKey('pieceCount')) {
          return BaggageAllowance(
              pieces: baggageDesc['pieceCount'] as int? ?? 0,
              weight: 0,
              unit: 'PC',
              type: '${baggageDesc['pieceCount']} PC');
        }
      }
    } catch (e) {
      print('Error parsing baggage allowance: $e');
    }

    return BaggageAllowance(
        pieces: 0, weight: 0, unit: '', type: 'Check airline policy');
  }
}

class FlightSegmentInfo {
  final String bookingCode;
  final String cabinCode;
  final String mealCode;
  final String seatsAvailable;

  FlightSegmentInfo({
    required this.bookingCode,
    required this.cabinCode,
    required this.mealCode,
    required this.seatsAvailable,
  });
}
