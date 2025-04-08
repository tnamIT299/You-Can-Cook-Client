import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_can_cook/screens/SplashScreen/splash.dart';
import 'signup.dart';
import 'forget_pass.dart';
import 'package:you_can_cook/screens/Main/home.dart';
import 'signupWithPhone.dart';
import 'package:you_can_cook/services/AuthService.dart';
import 'package:you_can_cook/helper/validationEmail.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/services/UserService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailValid = true;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _loginWithFirebase() async {
    setState(() {
      _isLoading = true;
    });
    String? errorMessage = await _auth.loginWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
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
            'Đăng Nhập',
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
              Text(
                'Chào mừng bạn đến với You Can Cook! Hãy thưởng thức các món ăn ngon cùng chúng tôi.',
                style: TextStyle(fontSize: 16, color: AppColors.primary),
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon:
                      _emailController.text.isNotEmpty &&
                              isValidEmail(
                                _emailController.text,
                              ) // Sử dụng hàm từ helper
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
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _loginWithFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 10),
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
                          'ĐĂNG NHẬP',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text(
                    'Bạn chưa có tài khoản? Đăng ký ngay!',
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
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpWithPhoneScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.phone, color: Colors.white),
                label: Text(
                  'TIẾP TỤC VỚI SỐ ĐIỆN THOẠI',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
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
