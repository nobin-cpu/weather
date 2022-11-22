import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // var list = const [
  //   'images/morningbg.jpg',
  //   'images/noonbg.jpg',
  //   'images/evening.jpg',
  //   'images/night.jpg'
  // ];
  // final daysSinceEpoch = DateTime.now().second / 1;

  Position? position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
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
    
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 29, 44),
      body: SafeArea(top: true,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(),
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .60,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            bottomRight: Radius.circular(22)),
                        gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 78, 146, 255),
                              Color.fromARGB(255, 238, 2, 255)
                            ],
                            stops: [
                              0.3,
                              0.86
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                    child: Column(children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                                height: MediaQuery.of(context).size.height * .1,
                                weatherMap!["weather"][0]["main"] == "Clear"
                                    ? "images/sun2.png"
                                    : weatherMap!["weather"][0]["main"] == "rainy"
                                        ? "images/rainy.png"
                                        : "images/cloudy.png"),
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 20.0, right: 10.0),
                              height: 40,
                              width: 2,
                              color: Colors.black,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "${Jiffy(DateTime.now()).format("MMM do yyyy,   h:mm: a")} ",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "${weatherMap!["name"]}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        heightFactor: MediaQuery.of(context).size.height * .003,
                        alignment: Alignment.center,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Temp:${weatherMap!["main"]["temp"]}.",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Feels like:${weatherMap!["main"]["feels_like"]}.",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Sky:${weatherMap!["weather"][0]["main"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                  "Humidity:${forecastMap!["list"][0]["main"]["humidity"]} ,pressure:${forecastMap!["list"][0]["main"]["pressure"]}",
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                  "Sunrise ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm:a")} ,Sunset:${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm:a")} ",
                                  style: TextStyle(color: Colors.white)),
                            ]),
                      ),
                    ]),
                  ),
                  Align(
                    heightFactor: MediaQuery.of(context).size.height * .002,
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 150,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: forecastMap!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                margin: EdgeInsets.only(right: 2),
                                color: Color.fromARGB(255, 46, 0, 17),
                                width: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE h:mm")}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                        "${forecastMap!["list"][index]["main"]["temp_min"]}",
                                        style: TextStyle(color: Colors.white)),
                                    Text(
                                        "${forecastMap!["list"][index]["main"]["temp_max"]}",
                                        style: TextStyle(color: Colors.white)),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                            "${forecastMap!["list"][index]["weather"][0]["description"]}",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
