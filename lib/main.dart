import 'package:flight_bocking/home_search/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/hotel/hotel/guests/guests_controller.dart';
import 'views/hotel/hotel/hotel_date_controller.dart';
import 'views/hotel/search_hotels/search_hotel_controller.dart';
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
