import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'additional_infoitem.dart';
import 'hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Weatherscreen extends StatefulWidget {
  const Weatherscreen({super.key});

  @override
  State<Weatherscreen> createState() => _WeatherscreenState();
}

class _WeatherscreenState extends State<Weatherscreen> {
  String selectedCity = 'Bangalore';

  final Map<String, String> cityMap = {
    'Bangalore': 'Bangalore,in',
    'Mysore': 'Mysore,in',
    'Mangalore': 'Mangalore,in',
    'Hubli': 'Hubli,in',
  };

  Future<Map<String, dynamic>> getWeather() async {
    try {
      final city = cityMap[selectedCity];
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=0d861c97cd12467be1e029b0697c0fbc',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'Unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App \nCity: $selectedCity",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {}); // Refresh data
            },
            icon: Icon(Icons.refresh_outlined),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: selectedCity,
              items: cityMap.keys.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Select City",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getWeather(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final data = snapshot.data!;
                final temper = data['list'][0]['main']['temp'];
                final sky = data['list'][0]['weather'][0]['main'];
                final humid = data['list'][0]['main']['humidity'];
                final pressure = data['list'][0]['main']['pressure'];
                final windspeed = data['list'][0]['wind']['speed'];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Weather Card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          surfaceTintColor:
                              const Color.fromARGB(255, 154, 152, 152),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      '$temper K',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Icon(
                                      sky == 'Clouds' || sky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 64,
                                    ),
                                    SizedBox(height: 20),
                                    Text(sky, style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Hourly Forecast
                      SizedBox(height: 20),
                      const Text("Hourly Forecast",
                          style: TextStyle(fontSize: 28)),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            final time = DateFormat("yyyy-MM-dd HH:mm:ss")
                                .parse(data['list'][index + 1]['dt_txt']);
                            return Hourlyupdate(
                              time: DateFormat('hh:mm a').format(time),
                              iconn: data['list'][index + 1]['weather'][0]
                                              ['main'] ==
                                          'Clouds' ||
                                      data['list'][index + 1]['weather'][0]
                                              ['main'] ==
                                          'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              temperature: data['list'][index + 1]['main']
                                      ['temp']
                                  .toString(),
                            );
                          },
                        ),
                      ),

                      // Additional Info
                      SizedBox(height: 20),
                      Text("More Information",
                          style: TextStyle(fontSize: 28)),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfoitem(
                            icon: Icons.water_drop,
                            label: "Humidity",
                            value: humid.toString(),
                          ),
                          AdditionalInfoitem(
                            icon: Icons.air,
                            label: "Wind Speed",
                            value: windspeed.toString(),
                          ),
                          AdditionalInfoitem(
                            icon: Icons.beach_access,
                            label: "Pressure",
                            value: pressure.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
