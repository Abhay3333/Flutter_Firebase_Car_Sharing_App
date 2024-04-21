import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divide_ride/controller/ride_controller.dart';
import 'package:divide_ride/widgets/ride_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryRidesForDriver extends StatefulWidget {
  const HistoryRidesForDriver({Key? key}) : super(key: key);

  @override
  State<HistoryRidesForDriver> createState() => _HistoryRidesForDriverState();
}

class _HistoryRidesForDriverState extends State<HistoryRidesForDriver> {
  RideController rideController = Get.find<RideController>();

  @override
  void initState() {
    super.initState();

    print(
        'length of ridesICancelled = ${rideController.ridesICancelled.length}');
    print('length of ridesIEnded = ${rideController.ridesIEnded.length}');
    print('length of driverHistory = ${rideController.driverHistory.length}');
    print('length of allRides = ${rideController.allRides.length}');
    print('length of allUsers = ${rideController.allUsers.length}');
    print("driver Id = ${FirebaseAuth.instance.currentUser!.uid} ");

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      rideController.getRidesICancelled();
      rideController.getRidesIEnded();
      rideController.getRideHistoryForDriver();
      rideController.getMyDocument();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DocumentSnapshot driver = rideController.myDocument!;

            return Padding(
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 2),
                child: RideBox(
                  ride: rideController.driverHistory[index],
                  driver: driver,
                  showCarDetails: false,
                  shouldNavigate: true,
                ));
          },
          itemCount: rideController.driverHistory.length,
        ));
  }
}
