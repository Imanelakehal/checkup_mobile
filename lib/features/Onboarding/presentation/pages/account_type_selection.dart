import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkup_mobile/features/home/presentation/pages/home_page.dart';
import 'package:checkup_mobile/features/parapharmacy/presentation/pages/parapharmacy_dashboard_page.dart';

class AccountTypeSelectionPage extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const AccountTypeSelectionPage({
    Key? key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<AccountTypeSelectionPage> createState() => _AccountTypeSelectionPageState();
}

class _AccountTypeSelectionPageState extends State<AccountTypeSelectionPage> {
  String? _selectedType;
  bool _isLoading = false;

  // ParaMap brand colors
  static const Color primaryGreen = Color(0xFF344E41);
  static const Color secondaryGreen = Color(0xFF588157);
  static const Color lightGreen = Color(0xFFA3B18A);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  Future<void> _saveUserType(String userType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Save user type to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userType': userType,
        'phone': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'location': widget.latitude != null && widget.longitude != null
            ? GeoPoint(widget.latitude!, widget.longitude!)
            : null,
      }, SetOptions(merge: true));

      // Navigate based on user type
      if (!mounted) return;

      if (userType == 'customer') {
        // Navigate to Customer Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              latitude: widget.latitude,
              longitude: widget.longitude,
            ),
          ),
        );
      } else {
        // Navigate to Parapharmacy Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ParapharmacyDashboardPage(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: primaryGreen,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo/Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_circle_outlined,
                        size: 60,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Welcome to ParaMap!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    const Text(
                      'Choose how you want to use ParaMap',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Customer Option
                    _buildAccountTypeCard(
                      type: 'customer',
                      icon: Icons.person_outline,
                      title: 'I\'m a Customer',
                      subtitle: 'Find parapharmacy products near you',
                      isSelected: _selectedType == 'customer',
                    ),

                    const SizedBox(height: 20),

                    // Parapharmacy Option
                    _buildAccountTypeCard(
                      type: 'parapharmacy',
                      icon: Icons.store_outlined,
                      title: 'I\'m a Parapharmacy',
                      subtitle: 'List your products and reach more customers',
                      isSelected: _selectedType == 'parapharmacy',
                    ),

                    const Spacer(),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedType == null
                            ? null
                            : () => _saveUserType(_selectedType!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryGreen.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? primaryGreen : Colors.grey[600],
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryGreen : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}