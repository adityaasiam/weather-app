import 'package:flutter/material.dart';

class HourlyForecastSection extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? errorMessage;
  final bool isLoading;

  const HourlyForecastSection({
    super.key,
    required this.weatherData,
    required this.errorMessage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Text(
                'HOURLY FORECAST',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : weatherData != null && weatherData!['hourly'] != null
                ? SingleChildScrollView(
              key: ValueKey(weatherData!['hourly']),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: weatherData!['hourly'].take(6).map<Widget>((hour) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        Text(
                          '${DateTime.fromMillisecondsSinceEpoch(hour['dt'] * 1000).hour}:00',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Icon(_getWeatherIcon(hour['weather'][0]['main']), color: Colors.white, size: 30),
                        const SizedBox(height: 8),
                        Text(
                          '${hour['temp'].toStringAsFixed(0)}°C',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
                : const Text(
              'No hourly data available',
              key: ValueKey('no_hourly'),
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.wb_cloudy;
      case 'rain':
        return Icons.umbrella;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.help;
    }
  }
}