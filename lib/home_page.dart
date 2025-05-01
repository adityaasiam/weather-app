import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import for JSON decoding

import 'weather_display_section.dart';
import 'weather_map_widget.dart';
import 'hourly_forecast_section.dart';
import 'daily_forecast_section.dart';
import 'login_page.dart';
import 'profile_page.dart'; // Import the new ProfilePage

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> with SingleTickerProviderStateMixin {
  List<String> cities = ['Ghaziabad', 'New York', 'London'];
  String selectedCity = 'Ghaziabad';
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;
  String? windTileUrl;
  String? precipitationTileUrl;
  String? temperatureTileUrl;
  final Map<String, LatLng> cityCoordinates = {
    'Ghaziabad': LatLng(28.67, 77.22),
    'New York': LatLng(40.71, -74.01),
    'London': LatLng(51.51, -0.13),
  };
  final TextEditingController _cityController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<String> _filteredSuggestions = [];
  bool _isFetchingSuggestions = false; // To show loading for suggestions

  // Replace with your actual OpenWeatherMap API Key
  final String _openWeatherMapApiKey = "c9872d428cb4b8c2433597b9e1bfc09d";

  // Get the currently logged-in user
  User? get currentUser => FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    if (!cities.contains(selectedCity)) {
      selectedCity = cities.isNotEmpty ? cities.first : '';
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    fetchWeather();
    fetchMapTileUrls();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchMapTileUrls() async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable('getMapTileUrls');
      final results = await callable.call();
      final responseData = Map<String, dynamic>.from(results.data as Map);
      setState(() {
        windTileUrl = responseData['wind'] as String?;
        precipitationTileUrl = responseData['precipitation'] as String?;
        temperatureTileUrl = responseData['temperature'] as String?;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching map tile URLs: $e';
      });
    }
  }

  Future<void> fetchWeather() async {
    if (selectedCity.isEmpty) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
      weatherData = null;
    });

    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable('getWeather');
      final results = await callable.call(<String, dynamic>{'city': selectedCity});
      final responseData = Map<String, dynamic>.from(results.data as Map);

      if (responseData['error'] != null) {
        setState(() {
          errorMessage = responseData['error'].toString();
          weatherData = null;
          isLoading = false;
        });
        return;
      }

      if (!cityCoordinates.containsKey(selectedCity)) {
        final lat = responseData['data']['lat'] as double?;
        final lon = responseData['data']['lon'] as double?;
        if (lat != null && lon != null) {
          cityCoordinates[selectedCity] = LatLng(lat, lon);
        }
      }

      setState(() {
        weatherData = responseData['data'] != null ? Map<String, dynamic>.from(responseData['data'] as Map) : null;
        errorMessage = null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load weather data: $e';
        weatherData = null;
        isLoading = false;
      });
    }
  }

  // Function to fetch city suggestions from OpenWeatherMap Geocoding API
  Future<void> _fetchCitySuggestions(String query, StateSetter setDialogState) async {
    if (query.isEmpty) {
      setDialogState(() {
        _filteredSuggestions = [];
      });
      return;
    }

    setDialogState(() {
      _isFetchingSuggestions = true;
    });

    final url = Uri.parse('http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$_openWeatherMapApiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setDialogState(() {
          _filteredSuggestions = data.map((city) {
            String name = city['name'];
            String country = city['country'];
            // Optionally add state if available
            String state = city['state'] != null ? ', ${city['state']}' : '';
            return '$name$state, $country';
          }).toList();
          _isFetchingSuggestions = false;
        });
      } else {
        setDialogState(() {
          _filteredSuggestions = ['Error fetching suggestions'];
          _isFetchingSuggestions = false;
        });
        print('Failed to fetch city suggestions: ${response.statusCode}');
      }
    } catch (e) {
      setDialogState(() {
        _filteredSuggestions = ['Error fetching suggestions'];
        _isFetchingSuggestions = false;
      });
      print('Error fetching city suggestions: $e');
    }
  }


  void onCityChanged(String newCity) {
    setState(() {
      selectedCity = newCity;
      _animationController.reset();
      _animationController.forward();
      fetchWeather();
    });
  }

  void addNewCity(String newCity) {
    final newCityLower = newCity.toLowerCase();
    if (newCity.isNotEmpty && !cities.any((city) => city.toLowerCase() == newCityLower)) {
      setState(() {
        cities.add(newCity);
        selectedCity = newCity;
        _cityController.clear();
        _filteredSuggestions.clear();
      });
      fetchWeather();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City already exists or is empty!')),
      );
    }
  }

  void _showAddCityDialog() {
    _cityController.clear();
    _filteredSuggestions = []; // Clear previous suggestions
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.blue[900]!.withOpacity(0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text(
                'Add New City',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: _isFetchingSuggestions
                            ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white70,
                          ),
                        )
                            : null,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        _fetchCitySuggestions(value, setDialogState); // Call API on text change
                      },
                    ),
                    if (_filteredSuggestions.isNotEmpty)
                      Container(
                        height: 150,
                        margin: const EdgeInsets.only(top: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[800]!.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredSuggestions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                _filteredSuggestions[index],
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                setDialogState(() {
                                  _cityController.text = _filteredSuggestions[index];
                                  _filteredSuggestions = []; // Clear suggestions after selection
                                });
                                // Do NOT close the dialog here. User needs to tap "Add".
                                // Navigator.of(context).pop();
                                // addNewCity(_cityController.text.trim());
                              },
                              tileColor: Colors.transparent,
                              hoverColor: Colors.white.withOpacity(0.1),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _cityController.clear();
                    _filteredSuggestions = [];
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () {
                    if (_cityController.text.isNotEmpty) {
                      addNewCity(_cityController.text.trim());
                      Navigator.of(context).pop(); // Close dialog after adding city
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a city name')),
                      );
                    }
                  },
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    // Optionally sign out from Google Sign-In as well if you used it
    // await GoogleSignIn().signOut(); // Requires google_sign_in import
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  List<Color> _getBackgroundColors() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return [Colors.blue[600]!.withOpacity(0.8), Colors.cyan[200]!.withOpacity(0.8)];
    } else if (hour >= 12 && hour < 17) {
      return [Colors.orange[600]!.withOpacity(0.8), Colors.yellow[200]!.withOpacity(0.8)];
    } else if (hour >= 17 && hour < 21) {
      return [Colors.purple[600]!.withOpacity(0.8), Colors.pink[200]!.withOpacity(0.8)];
    } else {
      return [Colors.blueGrey[900]!.withOpacity(0.8), Colors.black.withOpacity(0.8)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        backgroundColor: Colors.blueGrey[900]!.withOpacity(0.7),
        width: 250,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Menu', // Changed title to be more general
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero, // Remove default padding
                children: [
                  // Add Profile ListTile if user is logged in
                  if (currentUser != null)
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text(
                        'Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(); // Close the drawer
                        Navigator.push( // Navigate to ProfilePage
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                      },
                    ),
                  // Existing City Selection ListTiles
                  ...cities.map((city) => ListTile(
                    title: Text(
                      city,
                      style: TextStyle(
                        color: city == selectedCity ? Colors.yellow : Colors.white,
                        fontWeight: city == selectedCity ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      onCityChanged(city);
                      Navigator.of(context).pop();
                    },
                  )),
                  ListTile(
                    title: const Text(
                      'Add City',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: const Icon(Icons.add, color: Colors.white),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAddCityDialog();
                    },
                  ),
                ],
              ),
            ),
            // Logout button remains at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _logout,
                child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getBackgroundColors(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // City selector section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        color: Colors.blue[900]!.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    selectedCity.isEmpty ? 'Select a city' : selectedCity,
                                    key: ValueKey(selectedCity),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Builder(
                                builder: (context) => IconButton(
                                  icon: const Icon(Icons.menu, color: Colors.white),
                                  onPressed: () {
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Current Weather and Details section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: WeatherDisplaySection(
                        weatherData: weatherData,
                        isLoading: isLoading,
                        errorMessage: errorMessage,
                        selectedCity: selectedCity,
                        cities: cities,
                        onCityChanged: onCityChanged,
                      ),
                    ),
                  ),
                  // Hourly Forecast section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        color: Colors.teal[700]!.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: HourlyForecastSection(
                          weatherData: weatherData,
                          errorMessage: errorMessage,
                          isLoading: isLoading,
                        ),
                      ),
                    ),
                  ),
                  // Daily Forecast section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        color: Colors.teal[700]!.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DailyForecastSection(
                          weatherData: weatherData,
                          errorMessage: errorMessage,
                          isLoading: isLoading,
                        ),
                      ),
                    ),
                  ),
                  // Map section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        color: Colors.purple[700]!.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 300,
                          child: WeatherMapWidget(
                            windTileUrl: windTileUrl ?? '',
                            precipitationTileUrl: precipitationTileUrl ?? '',
                            temperatureTileUrl: temperatureTileUrl ?? '',
                            center: cityCoordinates[selectedCity] ?? LatLng(28.67, 77.22),
                            showWind: true,
                            showPrecipitation: true,
                            showTemperature: true,
                            weatherData: weatherData,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
