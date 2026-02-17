import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({Key? key}) : super(key: key);

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _isLoading = false;

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    print('🔵 Requesting location permission...');

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        print('🔴 Location services disabled');
        _showError('Location services are disabled.\nPlease enable location in your phone settings.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      print('🟡 Current permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('🟡 Permission after request: $permission');
      }

      if (permission == LocationPermission.denied) {
        print('🔴 Permission denied');
        _showError('Location permission denied.\nWe need your location to show nearby parapharmacies.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        print('🔴 Permission denied forever');
        _showError(
          'Location permission permanently denied.\n\nPlease enable it in:\nSettings → Apps → ParaMap → Permissions → Location'
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Permission granted! Get location
      print('✅ Permission granted! Getting location...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('✅ Location obtained: ${position.latitude}, ${position.longitude}');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Location detected successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF344E41),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Wait a moment to show success message
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to home with location
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/home',
          arguments: {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        );
      }
    } catch (e) {
      print('🔴 Error getting location: $e');
      _showError('Could not get your location.\nPlease try again.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }

  void _skipForNow() {
    // Allow user to skip location (they can enable later)
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Location SVG Image
              SvgPicture.asset(
                'assets/images/location.svg',
                width: 280,
                height: 280,
              ),
              
              const SizedBox(height: 60),
              
              // Access Location Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestLocationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF344E41),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    disabledBackgroundColor: const Color(0xFF344E41).withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.location_on,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Access Location',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Privacy Text
              Text(
                'PARAMAP WILL ACCESS YOUR LOCATION\nONLY WHILE USING THE APP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Skip for now (optional)
              TextButton(
                onPressed: _isLoading ? null : _skipForNow,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}