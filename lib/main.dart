import 'package:flight_bocking/home_search/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'home_search/booking_card/forms/hotel/guests/guests_controller.dart';
import 'home_search/booking_card/forms/hotel/hotel_date_controller.dart';
import 'home_search/search_hotels/search_hotel_controller.dart';
import 'widgets/colors.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    Get.lazyPut(() => GuestsController(), fenix: true);
    Get.lazyPut(() => HotelDateController(), fenix: true);
    Get.lazyPut(() => SearchHotelController(), fenix: true);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: TColors.primary),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
