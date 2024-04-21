import 'package:flutter/material.dart';
import '../../controller/ride_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/nearest_rides_cards.dart';

class NearestRidePage extends StatelessWidget {
  final RideController rideController;

  const NearestRidePage({
    Key? key,
    required this.rideController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 26, 162, 230),
          title: Text('Search Ride List'),
          centerTitle: true,
        ),
        body: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: const [
                SizedBox(height: 30),
                Expanded(
                  child: NearestRidesCards(),
                )
              ])),
        ));
  }
}
