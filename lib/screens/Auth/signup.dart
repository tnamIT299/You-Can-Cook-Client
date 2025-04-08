import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_can_cook/screens/Auth/login.dart';
import 'package:you_can_cook/services/AuthService.dart';
import 'package:you_can_cook/screens/Main/home.dart';
import 'package:you_can_cook/helper/validationEmail.dart';
import 'package:you_can_cook/widgets/dialog_noti.dart';
import 'package:you_can_cook/utils/color.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _obscurePassword = true;
  bool _isEmailValid = true;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _signUpWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });
    String? errorMessage = await _auth.signUpWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
      _fullNameController.text,
    );

    if (errorMessage != null) {
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = '';
        _isLoading = false;
      });
      show_Dialog(
        context,
        'Đăng ký thành công',
        'Tài khoản của bạn đã được tạo thành công!',
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        () {
          Navigator.pop(context); // Đóng moda
        }, // Provide an empty callback function as the fifth argument
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Center(
          child: Text(
            'Tạo Tài Khoản',
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
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
                'Vui lòng nhập tên, địa chỉ email và mật khẩu để tạo tài khoản. Bạn đã có tài khoản chưa?',
                style: TextStyle(fontSize: 14, color: AppColors.primary),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              SizedBox(height: 20),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'HỌ TÊN',
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
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon:
                      _emailController.text.isNotEmpty &&
                              isValidEmail(_emailController.text)
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _isEmailValid = isValidEmail(value);
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'MẬT KHẨU',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUpWithEmailAndPassword, // Gọi hàm đăng ký
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : Text(
                          'ĐĂNG KÝ',
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
                  'Bằng cách đăng ký, bạn đồng ý với Điều khoản Điều kiện & Chính sách bảo mật của chúng tôi.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Bạn đã có tài khoản? Đăng nhập ngay!',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Hoặc',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  UserCredential? userCredential =
                      await _auth.signInWithGoogle();
                  if (userCredential != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đăng nhập thất bại')),
                    );
                  }
                },
                icon: Icon(Icons.email, color: Colors.white),
                label: Text(
                  'TIẾP TỤC VỚI GOOGLE',
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
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
