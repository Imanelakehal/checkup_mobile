// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show cos, sqrt, asin;

class HomePage extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const HomePage({
    super.key,
    this.latitude,
    this.longitude,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Updated ParaMap brand colors
  static const Color primaryGreen = Color(0xFF3A5A40);
  static const Color beigeColor = Color(0xFFDAD7CD);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _userName = 'Halal'; // Default fallback
  int _selectedNavIndex = 0;

  final List<String> _categories = [
    'All',
    'Skin Care',
    'Hair Care',
    'Wellness & supplements',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists && userDoc.data()?['name'] != null) {
          setState(() {
            _userName = userDoc.data()!['name'];
          });
        }
      }
    } catch (e) {
      // Keep default name if error
      // ignore: avoid_print
      print('Error loading user name: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi/180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // ignore: unused_element
  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            // Category Chips
            _buildCategoryChips(),

            // Parapharmacies List
            Expanded(
              child: _buildParapharmaciesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu and Deliver To
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DELIVER TO',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        'Halal Lab office',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Greeting with actual user name
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Hey $_userName, ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: _getGreeting(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products , parapharmacies',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Searching for: $value'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: primaryGreen,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: beigeColor,
              selectedColor: primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParapharmaciesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parapharmacies')
          .where('verified', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading parapharmacies',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primaryGreen),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No parapharmacies found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back soon!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        final parapharmacies = snapshot.data!.docs;

        // Sort by distance if location available
        if (widget.latitude != null && widget.longitude != null) {
          parapharmacies.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            if (aData['location'] == null || bData['location'] == null) {
              return 0;
            }

            final aLocation = aData['location'] as GeoPoint;
            final bLocation = bData['location'] as GeoPoint;

            final aDist = _calculateDistance(
              widget.latitude!,
              widget.longitude!,
              aLocation.latitude,
              aLocation.longitude,
            );

            final bDist = _calculateDistance(
              widget.latitude!,
              widget.longitude!,
              bLocation.latitude,
              bLocation.longitude,
            );

            return aDist.compareTo(bDist);
          });
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          itemCount: parapharmacies.length,
          itemBuilder: (context, index) {
            final doc = parapharmacies[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildParapharmacyCard(
              id: doc.id,
              name: data['name'] ?? 'Unnamed Parapharmacy',
              categories: data['categories'] != null
                  ? List<String>.from(data['categories'])
                  : [],
              rating: (data['rating'] ?? 0.0).toDouble(),
              isFreeDelivery: data['isFreeDelivery'] ?? false,
              deliveryTime: data['deliveryTime'] ?? '24h-48h',
              image: data['image'],
              location: data['location'] as GeoPoint?,
            );
          },
        );
      },
    );
  }

  Widget _buildParapharmacyCard({
    required String id,
    required String name,
    required List<String> categories,
    required double rating,
    required bool isFreeDelivery,
    required String deliveryTime,
    String? image,
    GeoPoint? location,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to parapharmacy details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening $name...'),
                duration: const Duration(seconds: 1),
                backgroundColor: primaryGreen,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: image != null
                    ? Image.network(
                        image,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Categories
                    if (categories.isNotEmpty)
                      Text(
                        categories.join(' - '),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 12),

                    // Rating, Free Delivery, Delivery Time
                    Row(
                      children: [
                        // Rating
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // Free Delivery
                        if (isFreeDelivery)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 16,
                                color: primaryGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Free',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(width: 12),

                        // Delivery Time
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              deliveryTime,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: beigeColor,
      ),
      child: Icon(
        Icons.store_rounded,
        size: 60,
        color: primaryGreen.withOpacity(0.3),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.grid_view_rounded,
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.format_list_bulleted_rounded,
            index: 1,
          ),
          _buildNavCenterButton(),
          _buildNavItem(
            icon: Icons.notifications_none_rounded,
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
  }) {
    final isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        // TODO: Navigate to corresponding page
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? primaryGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? primaryGreen : Colors.grey[400],
          size: 26,
        ),
      ),
    );
  }

  Widget _buildNavCenterButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: beigeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: beigeColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            // TODO: AI Camera Search
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('AI Camera Search - Coming Soon!'),
                backgroundColor: primaryGreen,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Icon(
            Icons.add_rounded,
            color: primaryGreen,
            size: 28,
          ),
        ),
      ),
    );
  }
}