import 'package:flutter/material.dart';

class Hourlyupdate extends StatelessWidget {
  final IconData iconn;
  final String time;
  final String temperature;
  const Hourlyupdate({super.key,
    required this.time,
    required this.iconn,
    required this.temperature,
    });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        elevation: 6,
        surfaceTintColor: const Color.fromARGB(255, 154, 152, 152),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Icon(iconn, size: 32),
              SizedBox(height: 8),
              Text(temperature),
            ],
          ),
        ),
      ),
    );
  }
}
