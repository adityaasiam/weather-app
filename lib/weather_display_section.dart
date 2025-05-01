import 'package:flutter/material.dart';

class WeatherDisplaySection extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCity;
  final List<String> cities;
  final Function(String) onCityChanged;

  const WeatherDisplaySection({
    super.key,
    required this.weatherData,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedCity,
    required this.cities,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Current Weather Section (Rectangular Card)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: isLoading
              ? Card(
            key: const ValueKey('loading'),
            color: Colors.blue[800]!.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          )
              : weatherData != null
              ? Card(
            key: ValueKey(weatherData),
            color: Colors.blue[800]!.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Current Weather in $selectedCity',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getWeatherIcon(weatherData!['current']['weather']?[0]?['main']),
                        color: Colors.white,
                        size: 50,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${weatherData!['current']['temp']?.toStringAsFixed(0) ?? 'N/A'}°C',
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    weatherData!['current']['weather']?[0]?['description']?.toString() ?? 'N/A',
                    style: const TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'High: ${weatherData!['daily']?[0]?['temp']?['max']?.toStringAsFixed(0) ?? 'N/A'}°C',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Low: ${weatherData!['daily']?[0]?['temp']?['min']?.toStringAsFixed(0) ?? 'N/A'}°C',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              : errorMessage != null
              ? Card(
            key: ValueKey(errorMessage),
            color: Colors.blue[800]!.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
              : Card(
            key: const ValueKey('no_data'),
            color: Colors.blue[800]!.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // Weather Details (2x2 Grid of Square Cards)
        if (!isLoading && weatherData != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: WrapAlignment.center,
              children: [
                // Feels Like Card
                Card(
                  color: Colors.blue[200]!.withOpacity(0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Feels Like',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${weatherData!['current']['feels_like']?.toStringAsFixed(0) ?? 'N/A'}°C',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Wind Card
                Card(
                  color: Colors.blue[200]!.withOpacity(0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Wind',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${weatherData!['current']['wind_speed']?.toString() ?? 'N/A'} m/s',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${weatherData!['current']['wind_deg']?.toString() ?? 'N/A'}°',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Humidity Card
                Card(
                  color: Colors.blue[200]!.withOpacity(0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Humidity',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${weatherData!['current']['humidity']?.toString() ?? 'N/A'}%',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pressure Card
                Card(
                  color: Colors.blue[200]!.withOpacity(0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pressure',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${weatherData!['current']['pressure']?.toString() ?? 'N/A'} hPa',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getWeatherIcon(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
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