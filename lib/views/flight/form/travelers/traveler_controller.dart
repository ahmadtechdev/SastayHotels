import 'package:get/get.dart';
import '../../../../../widgets/colors.dart';
import '../../../../../widgets/snackbar.dart';

class TravelersController extends GetxController {
  var adultCount = 1.obs;
  var childrenCount = 1.obs;
  var infantCount = 1.obs;
  var travelClass = 'Economy'.obs; // Changed default to match API enumeration

  // Available travel classes matching API requirements
  final List<String> availableTravelClasses = [
    'Economy',
    'PremiumEconomy',
    'Business',
    'First'
  ];

  void incrementAdults() {
    adultCount.value++;
    if (infantCount.value > adultCount.value) {
      infantCount.value = adultCount.value;
    }
  }

  void decrementAdults() {
    if (adultCount.value > 0) {
      adultCount.value--;
      if (infantCount.value > adultCount.value) {
        infantCount.value = adultCount.value;
      }
    }
  }

  void incrementChildren() => childrenCount.value++;

  void decrementChildren() {
    if (childrenCount.value > 0) childrenCount.value--;
  }

  void incrementInfants() {
    if (infantCount.value < adultCount.value) {
      infantCount.value++;
    } else {
      CustomSnackBar(
          message: "Infants cannot exceed the number of adults.",
          backgroundColor: TColors.third)
          .show();
    }
  }

  void decrementInfants() {
    if (infantCount.value > 0) infantCount.value--;
  }

  void updateTravelClass(String newClass) {
    if (availableTravelClasses.contains(newClass)) {
      travelClass.value = newClass;
    }
  }
}