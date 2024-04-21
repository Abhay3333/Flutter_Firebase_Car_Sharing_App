import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divide_ride/shared%20preferences/shared_pref.dart';
import 'package:divide_ride/utils/app_colors.dart';
import 'package:divide_ride/utils/app_constants.dart';
import 'package:divide_ride/views/Feedbackdialog.dart';
import 'package:divide_ride/views/user/payment_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/ride_controller.dart';
import 'package:feedback/feedback.dart';
import '../widgets/ride_box.dart';

import '../widgets/text_widget.dart';

class RideDetailsView extends StatefulWidget {
  DocumentSnapshot ride;
  DocumentSnapshot driver;
  RideDetailsView(this.ride, this.driver);

  @override
  State<RideDetailsView> createState() => _RideDetailsViewState();
}

class _RideDetailsViewState extends State<RideDetailsView> {
  Future<void>? _launched;
  RideController rideController = Get.find<RideController>();

  bool isDriver = false;

  @override
  void initState() {
    super.initState();
    rideController.isRidesLoading(true);

    isDriver = CacheHelper.getData(key: AppConstants.decisionKey) ?? false;

    print(isDriver.toString());
    rideController.getAcceptedUserForRide(widget.ride.id);
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    RideController rideController = Get.find<RideController>();
    final Uri toLaunch = Uri(
        scheme: 'https',
        host: 'www.stripe-payment-mern.vercel.app',
        path: '/${widget.ride.get('price_per_seat')}');
    String userId = FirebaseAuth.instance.currentUser!.uid;
    List pendingUsers = [];
    List joinedUsers = [];
    List rejectedUsers = [];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 26, 162, 230),
        title: Text('Ride Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rides')
                  .doc(widget.ride.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                DocumentSnapshot ride = snapshot.data!;

                String userId = FirebaseAuth.instance.currentUser!.uid;

                //String rideId = ride.id;

                String maxSeats = ride.get('max_seats');

                String status = ride.get('status');

                try {
                  pendingUsers = ride.get('pending');
                } catch (e) {
                  pendingUsers = [];
                }

                try {
                  joinedUsers = ride.get('joined');
                } catch (e) {
                  joinedUsers = [];
                }

                try {
                  rejectedUsers = ride.get('rejected');
                } catch (e) {
                  rejectedUsers = [];
                }
                return Column(
                  children: [
                    RideBox(
                        ride: ride,
                        driver: widget.driver,
                        showCarDetails: true),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              width: Get.width * 0.6,
                              height: 50,
                              child: Row(
                                children: List<Widget>.generate(
                                  joinedUsers.length,
                                  (index) {
                                    DocumentSnapshot user =
                                        rideController.allUsers.firstWhere(
                                            (e) => e.id == joinedUsers[index]);
                                    String image = '';

                                    try {
                                      image = user.get('image');
                                    } catch (e) {
                                      image = '';
                                    }
                                    return Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(image),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.ride.get('price_per_seat')} RS',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '${widget.ride.get('max_seats')} left',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _launched = _launchInBrowser(toLaunch);
                      }),
                      child: const Text('Pay Now'),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => FeedbackDialog(),
                        );
                      },
                      child: Icon(Icons.feedback_sharp),
                    ),

                    // Spacer(),
                    if (isDriver) ...[
                      if (widget.ride.get('status') == 'Ended' ||
                          widget.ride.get('status') == 'Cancelled')
                        ...[]
                      else if (widget.ride.get('status') == 'Upcoming') ...[
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  rideController.cancelRide(widget.ride.id);
                                  rideController.updateHistoryDriverRide();
                                  rideController.updateHistoryUserRide();
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13),
                                      color: Colors.red.withOpacity(0.9)),
                                  child: Center(
                                    child: Text(
                                      "Cancel Ride",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                                onTap: () {
                                  if (pendingUsers.contains(userId)) {
                                  } else if (joinedUsers.contains(userId)) {
                                  } else if (rejectedUsers.contains(userId)) {
                                  } else if (ride.get('max_seats') ==
                                      "0 seats") {
                                  } else {
                                    Get.defaultDialog(
                                      title: "Are you sure to join this ride ?",
                                      content: Container(),
                                      //barrierDismissible: false,
                                      actions: [
                                        MaterialButton(
                                          onPressed: () {
                                            Get.back();

                                            //rideController.isRequestLoading(true);
                                            rideController.requestToJoinRide(
                                                ride, userId);

                                            //Get.back();
                                          },
                                          child: textWidget(
                                            text: 'Confirm',
                                            color: Colors.white,
                                          ),
                                          color:
                                              Color.fromARGB(255, 26, 162, 230),
                                          shape: StadiumBorder(),
                                        ),
                                        SizedBox(width: 7),
                                        MaterialButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: textWidget(
                                            text: 'Cancel',
                                            color: Colors.white,
                                          ),
                                          color: Colors.red,
                                          shape: StadiumBorder(),
                                        ),
                                      ],
                                    );
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13),
                                      color: pendingUsers.contains(userId)
                                          ? AppColors.yellow.withOpacity(0.9)
                                          : rejectedUsers.contains(userId)
                                              ? Colors.red.shade700
                                              : joinedUsers.contains(userId)
                                                  ? Color.fromARGB(
                                                          255, 26, 162, 230)
                                                      .withOpacity(0.9)
                                                  : Color.fromARGB(
                                                          255, 26, 162, 230)
                                                      .withOpacity(0.9)),
                                  child: Center(
                                      child: Text(
                                    pendingUsers.contains(userId)
                                        ? "Pending"
                                        : rejectedUsers.contains(userId)
                                            ? "Rejected"
                                            : joinedUsers.contains(userId)
                                                ? "Joined"
                                                : ride.get('max_seats') ==
                                                        "0 seats"
                                                    ? "No seats Available"
                                                    : "Send Request",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  )),
                                )),
                          ),
                          if (ride.get('status') == "Ended") ...[
                            Column(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => PaymentView(
                                          widget.ride, widget.driver));
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              spreadRadius: 0.1,
                                              blurRadius: 60,
                                              offset: Offset(0,
                                                  1), // changes position of shadow
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(13)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Center(
                                        child: Text(
                                          'Pay',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ],
                    SizedBox(
                      height: 10,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}

Widget _buildFeedbackForm() {
  TextEditingController feedbackController = TextEditingController();
  double rating = 0;

  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Provide Feedback'),
        SizedBox(height: 20),
        TextField(
          controller: feedbackController,
          decoration: InputDecoration(
            labelText: 'Feedback',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        SizedBox(height: 20),
        Text('Rating: $rating'),
        Slider(
          value: rating,
          onChanged: (newRating) {
            rating = newRating;
          },
          min: 0,
          max: 5,
          divisions: 5,
          label: rating.toString(),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Handle feedback submission here
            _submitFeedback(feedbackController.text, rating);
            // Close the modal
          },
          child: Text('Submit'),
        ),
      ],
    ),
  );
}

void _submitFeedback(String feedbackText, double rating) {
  // Handle submission of feedback here
  print('Feedback: $feedbackText');
  print('Rating: $rating');
  // You can perform any action with the feedback data (e.g., send it to a server)
}

Widget myText({text, style, textAlign}) {
  return Text(
    text,
    style: style,
    textAlign: textAlign,
  );
}
