import 'package:flight_bocking/widgets/colors.dart';
import 'package:get/get.dart';

import '../../../../widgets/snackbar.dart';

class TravelersController extends GetxController {
  var adultCount = 1.obs;
  var childrenCount = 1.obs;
  var infantCount = 1.obs;
  var travelClass = 'Economy'.obs;

  void incrementAdults() {
    adultCount.value++;
    if (infantCount.value > adultCount.value) {
      infantCount.value = adultCount.value; // Ensure infants ≤ adults
    }
  }

  void decrementAdults() {
    if (adultCount.value > 0) {
      adultCount.value--;
      if (infantCount.value > adultCount.value) {
        infantCount.value = adultCount.value; // Ensure infants ≤ adults
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
      CustomSnackBar(message: "Infants cannot exceed the number of adults.", backgroundColor: TColors.third).show();
    }
  }

  void decrementInfants() {
    if (infantCount.value > 0) infantCount.value--;
  }

  void updateTravelClass(String newClass) => travelClass.value = newClass;
}
