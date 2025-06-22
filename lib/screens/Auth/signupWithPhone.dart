import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'package:you_can_cook/utils/color.dart';

class SignUpWithPhoneScreen extends StatefulWidget {
  const SignUpWithPhoneScreen({super.key});

  @override
  _SignUpWithPhoneScreenState createState() => _SignUpWithPhoneScreenState();
}

class _SignUpWithPhoneScreenState extends State<SignUpWithPhoneScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  // final bool _obscurePassword = true;
  String _errorMessage = '';
  String? _verificationId;
  bool _isCodeSent = false;

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Up Successful'),
          content: Text('Your account has been created successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('OK', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  bool _isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(
      r'^\+[1-9]\d{1,14}$',
    ); // Định dạng quốc tế: + mã quốc gia + số điện thoại
    return phoneRegex.hasMatch(phone);
  }

  Future<void> _sendOTP() async {
    String phoneNumber = _phoneController.text.trim();

    if (!_isValidPhoneNumber(phoneNumber)) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number (e.g., +1234567890)';
      });
      return;
    }

    if (_fullNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your full name';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Tự động hoàn tất xác minh (thường trên Android nếu mã OTP được tự động phát hiện)
        await FirebaseAuth.instance.signInWithCredential(credential);
        await FirebaseAuth.instance.currentUser?.updateDisplayName(
          _fullNameController.text.trim(),
        );
        _showSuccessDialog(context);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _errorMessage = e.message ?? 'Failed to verify phone number';
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isCodeSent = true; // Hiển thị ô nhập OTP
          _verificationId = verificationId;
          _errorMessage = 'OTP sent to $phoneNumber';
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseAuth.instance.currentUser?.updateDisplayName(
        _fullNameController.text.trim(),
      );
      _showSuccessDialog(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Create Account',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 0,
            bottom: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Enter your Phone Number for sign up. Already have account?',
                style: TextStyle(fontSize: 14, color: AppColors.primary),
              ),
              if (_errorMessage.isNotEmpty) // Hiển thị thông báo lỗi
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color:
                          _errorMessage.contains('OTP sent')
                              ? Colors.green
                              : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              SizedBox(height: 20),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'FULL NAME',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon:
                      _fullNameController.text.isNotEmpty
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              // Ô nhập Phone Number
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'PHONE NUMBER',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon:
                      _phoneController.text.isNotEmpty &&
                              _isValidPhoneNumber(_phoneController.text)
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              if (_isCodeSent) ...[
                SizedBox(height: 10),
                // Ô nhập OTP
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ENTER OTP',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
              SizedBox(height: 20),
              // Nút SIGN UP
              ElevatedButton(
                onPressed:
                    _isCodeSent
                        ? _verifyOTP
                        : _sendOTP, // Gửi OTP hoặc xác minh OTP
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  _isCodeSent ? 'VERIFY OTP' : 'SIGN UP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'By Signing up you agree to our Terms Conditions & Privacy Policy.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              // Text "Or"
              Center(
                child: Text(
                  'Or',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              // Nút CONNECT WITH FACEBOOK
              ElevatedButton.icon(
                onPressed: () {
                  // Xử lý khi nhấn CONNECT WITH FACEBOOK
                },
                icon: Icon(Icons.facebook, color: Colors.white),
                label: Text(
                  'CONNECT WITH FACEBOOK',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff395998),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Nút CONNECT WITH GOOGLE
              ElevatedButton.icon(
                onPressed: () {
                  // Xử lý khi nhấn CONNECT WITH GOOGLE
                },
                icon: Icon(Icons.email, color: Colors.white),
                label: Text(
                  'CONNECT WITH GOOGLE',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff4285F4),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
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
