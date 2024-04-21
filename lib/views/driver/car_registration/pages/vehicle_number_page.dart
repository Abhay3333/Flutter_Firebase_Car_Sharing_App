import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Vehicle Number Page'),
        ),
        body: VehicalNumberPage(controller: TextEditingController()),
      ),
    );
  }
}

class VehicalNumberPage extends StatefulWidget {
  const VehicalNumberPage({Key? key, required this.controller})
      : super(key: key);

  final TextEditingController controller;

  @override
  State<VehicalNumberPage> createState() => _VehicalNumberPageState();
}

class _VehicalNumberPageState extends State<VehicalNumberPage> {
  String? mobileNumber;
  String? panNumber;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Vehicle Number ?',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          SizedBox(
            height: 30,
          ),
          TextFieldWidget(
              'Enter Vehicle Number', widget.controller, (String v) {},
              readOnly: false),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              await fetchData();
              setState(() {}); // Rebuild the UI after fetching data
            },
            child: Text('Fetch Data'),
          ),
          SizedBox(
            height: 20,
          ),
          if (mobileNumber != null && panNumber != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mobile Number: $mobileNumber',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'PAN Number: $panNumber',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://rto-vehicle-information-verification-india.p.rapidapi.com/api/v1/rc/vehicleinfo'),
        headers: {
          'content-type': 'application/json',
          'X-RapidAPI-Key':
              '5ebe81c65fmsh12673e72cf313a3p1afc13jsna20d934304d9',
          'X-RapidAPI-Host':
              'rto-vehicle-information-verification-india.p.rapidapi.com'
        },
        body: jsonEncode({
          "reg_no": widget.controller.text,
          "consent": "Y",
          "consent_text":
              "I hereby declare my consent agreement for fetching my information via AITAN Labs API"
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          mobileNumber = responseData['result']['mobile_no'].toString();
          panNumber = responseData['result']['pan_no'].toString();
        });
        print('Mobile Number: $mobileNumber');
        print('PAN Number: $panNumber');
      } else {
        print('Failed to fetch data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}

class TextFieldWidget extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final Function validator;
  final Function? onTap;
  final bool readOnly;

  const TextFieldWidget(this.title, this.controller, this.validator,
      {this.onTap, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 1)
            ],
            borderRadius: BorderRadius.circular(8)),
        child: TextFormField(
          readOnly: readOnly,
          onTap: onTap != null ? () => onTap!() : null,
          validator: (input) => validator(input),
          controller: controller,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xffA7A7A7)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xff7D7D7D).withOpacity(0.5)),
            hintText: title,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
