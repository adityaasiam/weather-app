import 'package:flutter/material.dart';

class DailyForecastSection extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? errorMessage;
  final bool isLoading;

  const DailyForecastSection({
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
              const Icon(Icons.calendar_today, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Text(
                'DAILY FORECAST',
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
                : weatherData != null && weatherData!['daily'] != null
                ? Column(
              key: ValueKey(weatherData!['daily']),
              children: weatherData!['daily'].take(5).map<Widget>((day) {
                return _buildForecastDay(
                  _getWeekday(DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000).weekday),
                  _getWeatherIcon(day['weather'][0]['main']),
                  day['temp']['min'],
                  day['temp']['max'],
                );
              }).toList(),
            )
                : const Text(
              'No daily data available',
              key: ValueKey('no_daily'),
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

  Widget _buildForecastDay(String day, IconData icon, num? low, num? high) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.left,
            ),
          ),
          Icon(icon, color: Colors.yellow, size: 30),
          const SizedBox(width: 20),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${low?.toStringAsFixed(0) ?? '--'}°',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '${high?.toStringAsFixed(0) ?? '--'}°',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
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