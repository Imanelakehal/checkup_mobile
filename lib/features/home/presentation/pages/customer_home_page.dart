import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // ParaMap brand colors
  static const Color primaryGreen = Color(0xFF344E41);
  static const Color lightGreen = Color(0xFFA3B18A);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi/180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

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
            // Header with Search
            _buildHeader(),

            // Parapharmacies List
            Expanded(
              child: _buildParapharmaciesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ParaMap',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products or parapharmacies...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: primaryGreen),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: primaryGreen),
                  onPressed: () {
                    // TODO: Implement AI camera search
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AI Camera Search - Coming Soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (value) {
                // TODO: Implement search
                if (value.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Searching for: $value'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
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
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
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
                  color: Colors.grey[400],
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
                  'New parapharmacies will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Nearby Parapharmacies',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${parapharmacies.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: parapharmacies.length,
                itemBuilder: (context, index) {
                  final doc = parapharmacies[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return _buildParapharmacyCard(
                    id: doc.id,
                    name: data['name'] ?? 'Unnamed Parapharmacy',
                    address: data['address'] ?? 'Address not available',
                    phone: data['phone'] ?? '',
                    rating: (data['rating'] ?? 0.0).toDouble(),
                    location: data['location'] as GeoPoint?,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParapharmacyCard({
    required String id,
    required String name,
    required String address,
    required String phone,
    required double rating,
    GeoPoint? location,
  }) {
    double? distance;
    if (widget.latitude != null &&
        widget.longitude != null &&
        location != null) {
      distance = _calculateDistance(
        widget.latitude!,
        widget.longitude!,
        location.latitude,
        location.longitude,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Distance
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (distance != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: lightGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDistance(distance),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Address
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Rating and Actions
                Row(
                  children: [
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : 'New',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Call Button
                    if (phone.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement call functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling $phone...'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call'),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),

                    const SizedBox(width: 8),

                    // Directions Button
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Open maps
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening directions...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Directions'),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}