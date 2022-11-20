import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:weather/clippath.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var list = const [
    'images/morningbg.jpg',
    'images/noonbg.jpg',
    'images/evening.jpg',
    'images/night.jpg'
  ];
  final daysSinceEpoch = DateTime.now().second / 1;

  Position? position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;
    print("latitude is $lat");
    print("longitute is  $lon");
    getWeatherData();
  }

  getWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&units=metric&appid=1aa527d921f3d9c7706f1972f4b11bf0";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&units=metric&appid=1aa527d921f3d9c7706f1972f4b11bf0";

    var weatherresponse = await http.get(Uri.parse(weatherApi));
    var forecastresponse = await http.get(Uri.parse(forecastApi));
    print("rresult is${weatherresponse.body}");
    print("rresult is${forecastresponse.body}");

    setState(() {
      weatherMap = Map<String, dynamic>.from(json.decode(weatherresponse.body));
      forecastMap =
          Map<String, dynamic>.from(json.decode(forecastresponse.body));
    });
  }

  var lat;
  var lon;
  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(),
        child: SingleChildScrollView(
          child: Column(children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  child: Image.network(
                      height: MediaQuery.of(context).size.height * .1,
                      weatherMap!["weather"][0]["main"] == "Clear"
                          ? "images/sun2.png"
                          : weatherMap!["weather"][0]["main"] == "rainy"
                              ? "images/rainy.png"
                              : "images/cloudy.png"),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                  height: 40,
                  width: 2,
                  color: Colors.black,
                ),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                            "${Jiffy(DateTime.now()).format("MMM do yyyy,   h:mm: a")} "),
                        Text("${weatherMap!["name"]}"),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Text("Temp:${weatherMap!["main"]["temp"]}."),
                Text("Feels like:${weatherMap!["main"]["feels_like"]}."),
                Text("${weatherMap!["weather"][0]["main"]}"),
                Text("Humidity: ,pressure:"),
                Text(
                    "Sunrise ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm:a")} ,Sunset:${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm:a")} "),
                Align(
                  heightFactor: MediaQuery.of(context).size.height / 210,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 150,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: forecastMap!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(right: 8),
                            color: Colors.grey,
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE h:mm")}"),
                                Text(
                                    "${forecastMap!["list"][index]["main"]["temp_min"]}"),
                                Text(
                                    "${forecastMap!["list"][index]["main"]["temp_max"]}"),
                                Text(
                                    "${forecastMap!["list"][index]["weather"][0]["descriptipn"]}")
                              ],
                            ),
                          );
                        }),
                  ),
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
