// weather_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WeatherMapWidget extends StatefulWidget {
  final String windTileUrl;
  final String precipitationTileUrl;
  final String temperatureTileUrl;
  final bool showWind;
  final bool showPrecipitation;
  final bool showTemperature;
  final Map<String, dynamic>? weatherData;
  final LatLng center;

  const WeatherMapWidget({
    super.key,
    required this.windTileUrl,
    required this.precipitationTileUrl,
    required this.temperatureTileUrl,
    required this.center,
    this.showWind = true,
    this.showPrecipitation = true,
    this.showTemperature = true,
    this.weatherData,
  });

  @override
  _WeatherMapWidgetState createState() => _WeatherMapWidgetState();
}

class _WeatherMapWidgetState extends State<WeatherMapWidget> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _animationController;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 8.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(WeatherMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.center != oldWidget.center) {
      _mapController.move(widget.center, _zoomAnimation.value);
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _zoomAnimation,
            builder: (context, child) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.center,
                  initialZoom: _zoomAnimation.value,
                  minZoom: 6.0,
                  maxZoom: 12.0,
                  onTap: (tapPosition, point) {
                    if (widget.weatherData != null && widget.weatherData!['current'] != null) {
                      final feelsLike = widget.weatherData!['current']['feels_like']?.toStringAsFixed(0) ?? 'N/A';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Feels Like: $feelsLike°C at ${point.latitude.toStringAsFixed(2)}, ${point.longitude.toStringAsFixed(2)}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    tileBuilder: (context, widget, tile) => Opacity(
                      opacity: 1.0,
                      child: widget,
                    ),
                    errorTileCallback: (tile, error, stackTrace) {
                      debugPrint('Base map tile error: $error');
                    },
                  ),
                  if (widget.showWind && widget.windTileUrl.isNotEmpty)
                    TileLayer(
                      urlTemplate: widget.windTileUrl,
                      tileBuilder: (context, widget, tile) => Opacity(
                        opacity: 0.7,
                        child: widget,
                      ),
                      errorTileCallback: (tile, error, stackTrace) {
                        debugPrint('Wind tile error: $error');
                      },
                    ),
                  if (widget.showPrecipitation && widget.precipitationTileUrl.isNotEmpty)
                    TileLayer(
                      urlTemplate: widget.precipitationTileUrl,
                      tileBuilder: (context, widget, tile) => Opacity(
                        opacity: 0.7,
                        child: widget,
                      ),
                      errorTileCallback: (tile, error, stackTrace) {
                        debugPrint('Precipitation tile error: $error');
                      },
                    ),
                  if (widget.showTemperature && widget.temperatureTileUrl.isNotEmpty)
                    TileLayer(
                      urlTemplate: widget.temperatureTileUrl,
                      tileBuilder: (context, widget, tile) => Opacity(
                        opacity: 0.7,
                        child: widget,
                      ),
                      errorTileCallback: (tile, error, stackTrace) {
                        debugPrint('Temperature tile error: $error');
                      },
                    ),
                ],
              );
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: const Text(
                'Weather Map',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              color: Colors.black54,
              child: const Text(
                '© OpenStreetMap, OpenWeatherMap',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}