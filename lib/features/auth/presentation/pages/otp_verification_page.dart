import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'success_page.dart'; 

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String userName;

  const OTPVerificationPage({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    required this.userName,
  }) : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    print('🔵 OTP Page loaded');
    print('🔵 Verification ID: ${widget.verificationId}');
    print('🔵 Phone: ${widget.phoneNumber}');
    print('🔵 User: ${widget.userName}');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    print('🟡 Verify button clicked');
    print('🟡 OTP entered: ${_otpController.text}');
    
    if (_otpController.text.length != 6) {
      _showError('Please enter 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🟢 Creating credential...');
      
      // Create credential with verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text,
      );

      print('🟢 Signing in with credential...');
      
      // Sign in with credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      print('🟢 Sign in successful!');
      print('🟢 User ID: ${userCredential.user?.uid}');

      // Save user data to Firestore
      if (userCredential.user != null) {
        print('🟢 Saving user to Firestore...');
        await _saveUserToFirestore(userCredential.user!);
        print('🟢 User saved successfully!');
        
        // Navigate to success page
        print('🟢 Navigating to Success page...');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                print('🟢 Building SuccessPage...');
                return SuccessPage(userName: widget.userName);
              },
            ),
          );
        } else {
          print('🔴 Widget not mounted - cannot navigate');
        }
      } else {
        print('🔴 User is null after sign in');
      }
    } on FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Error: ${e.code}');
      print('🔴 Error message: ${e.message}');
      
      String message = 'Verification failed';
      
      if (e.code == 'invalid-verification-code') {
        message = 'Invalid code. Please try again.';
      } else if (e.code == 'session-expired') {
        message = 'Code expired. Please request a new one.';
      } else {
        message = e.message ?? 'Unknown error';
      }
      
      _showError(message);
    } catch (e) {
      print('🔴 Unknown error: $e');
      _showError('Something went wrong: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    final firestore = FirebaseFirestore.instance;
    
    try {
      await firestore.collection('users').doc(user.uid).set({
        'name': widget.userName,
        'phoneNumber': widget.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      }, SetOptions(merge: true));
      
      print('✅ Firestore save complete');
    } catch (e) {
      print('🔴 Firestore error: $e');
      // Don't block navigation even if Firestore fails
    }
  }

  Future<void> _resendCode() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError('Failed to resend code: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _showSuccess('Code sent successfully!');
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showError('Failed to resend code');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF344E41),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom OTP pin theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF344E41), width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: const Color(0xFF344E41)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Back button
              GestureDetector(
                onTap: () {
                  print('🔵 Back button pressed');
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Illustration/Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF344E41).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    size: 60,
                    color: Color(0xFF344E41),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Center(
                child: Text(
                  'Verification Code',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Center(
                child: Text(
                  'We sent a code to\n${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input
              Center(
                child: Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  onCompleted: (pin) {
                    print('🟡 PIN completed: $pin');
                    // Auto-verify when 6 digits entered
                    _verifyOTP();
                  },
                  pinAnimationType: PinAnimationType.scale,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Resend code text
              Center(
                child: _resendTimer > 0
                    ? Text(
                        'Resend code in $_resendTimer seconds',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      )
                    : GestureDetector(
                        onTap: _isResending ? null : _resendCode,
                        child: Text(
                          _isResending ? 'Sending...' : 'Resend Code',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF344E41),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
              ),
              
              const SizedBox(height: 48),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF344E41),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Edit phone number
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Change Phone Number',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}