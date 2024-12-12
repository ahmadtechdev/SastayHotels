import 'package:get/get.dart';

class PriceController extends GetxController {
  // Observable variables to store selected car type and price
  RxString selectedCar = ''.obs;
  RxInt totalPrice = 0.obs;

  void updatePrice(String carType, int price) {
    selectedCar.value = carType;
    totalPrice.value = price;
  }
}
