import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParapharmacyDashboardPage extends StatefulWidget {
  const ParapharmacyDashboardPage({Key? key}) : super(key: key);

  @override
  State<ParapharmacyDashboardPage> createState() => _ParapharmacyDashboardPageState();
}

class _ParapharmacyDashboardPageState extends State<ParapharmacyDashboardPage> {
  // ParaMap brand colors
  static const Color primaryGreen = Color(0xFF344E41);
  static const Color secondaryGreen = Color(0xFF588157);
  static const Color lightGreen = Color(0xFFA3B18A);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  bool _isLoading = true;
  bool _isRegistered = false;
  Map<String, dynamic>? _parapharmacyData;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check if parapharmacy profile exists
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists && userData.data()?['parapharmacyId'] != null) {
        final parapharmacyId = userData.data()!['parapharmacyId'];

        // Get parapharmacy data
        final parapharmacyDoc = await FirebaseFirestore.instance
            .collection('parapharmacies')
            .doc(parapharmacyId)
            .get();

        if (parapharmacyDoc.exists) {
          setState(() {
            _isRegistered = true;
            _parapharmacyData = parapharmacyDoc.data();
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _isRegistered = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryGreen),
        ),
      );
    }

    return _isRegistered
        ? _buildDashboard()
        : _buildRegistrationForm();
  }

  // REGISTRATION FORM (First-time setup)
  Widget _buildRegistrationForm() {
    return const ParapharmacyRegistrationForm();
  }

  // DASHBOARD (For registered parapharmacies)
  Widget _buildDashboard() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: Text(
          _parapharmacyData?['name'] ?? 'My Parapharmacy',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Settings page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Overview
            _buildStatsCards(),

            const SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(),

            const SizedBox(height: 20),

            // Recent Orders (placeholder)
            _buildRecentOrders(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              value: '0',
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.shopping_bag_outlined,
              title: 'Orders',
              value: '0',
              color: secondaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.attach_money,
              title: 'Revenue',
              value: '0 DH',
              color: lightGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_box_outlined,
                  label: 'Add Product',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Product - Coming Soon!')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.list_alt,
                  label: 'Inventory',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inventory - Coming Soon!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: primaryGreen),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// REGISTRATION FORM COMPONENT
class ParapharmacyRegistrationForm extends StatefulWidget {
  const ParapharmacyRegistrationForm({Key? key}) : super(key: key);

  @override
  State<ParapharmacyRegistrationForm> createState() =>
      _ParapharmacyRegistrationFormState();
}

class _ParapharmacyRegistrationFormState
    extends State<ParapharmacyRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isSubmitting = false;

  static const Color primaryGreen = Color(0xFF344E41);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Create parapharmacy document
      final parapharmacyRef =
          FirebaseFirestore.instance.collection('parapharmacies').doc();

      await parapharmacyRef.set({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'owner': user.phoneNumber,
        'ownerId': user.uid,
        'verified': false, // Admin will verify
        'rating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user document with parapharmacy reference
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'parapharmacyId': parapharmacyRef.id,
      });

      if (!mounted) return;

      // Show success and reload
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted! Awaiting verification.'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ParapharmacyDashboardPage(),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
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
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          'Register Your Parapharmacy',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isSubmitting
          ? const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tell us about your parapharmacy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide accurate information. Your parapharmacy will be verified before going live.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Parapharmacy Name *',
                        hintText: 'e.g., Pharmacie Al Amal',
                        prefixIcon: const Icon(Icons.store, color: primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryGreen, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter parapharmacy name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address *',
                        hintText: 'Full street address',
                        prefixIcon: const Icon(Icons.location_on, color: primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryGreen, width: 2),
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // City
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City *',
                        hintText: 'e.g., Casablanca, Rabat',
                        prefixIcon: const Icon(Icons.location_city, color: primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryGreen, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        hintText: '+212 6XX XX XX XX',
                        prefixIcon: const Icon(Icons.phone, color: primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryGreen, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit Registration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your registration will be reviewed by our team. You\'ll be notified once approved.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[900],
                              ),
                            ),
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
}