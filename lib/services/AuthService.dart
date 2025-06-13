import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:you_can_cook/helper/validationEmail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SupabaseClient _supabase = Supabase.instance.client;
  //Login with google
  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final String? email = userCredential.user?.email;
      final String? name = userCredential.user?.displayName;
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email!);
      if (response.isEmpty) {
        await _supabase.from('users').insert({
          'email': email,
          'name': name,
          'onlineStatus': 'true',
          'createAt': DateTime.now().toIso8601String(),
        });
      } else {
        await _supabase
            .from('users')
            .update({'onlineStatus': true})
            .eq('email', email);
      }
      return userCredential;
    } catch (e) {
      throw Exception('Đăng nhập thất bại');
    }
  }

  //Sign out
  Future<void> signOut() async {
    final firebase_auth.User? user = _auth.currentUser;
    if (user != null) {
      await _supabase
          .from('users')
          .update({'onlineStatus': false})
          .eq('email', user.email!);
    }
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Login with email and password
  Future<String?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Vui lòng nhập email và mật khẩu';
    }

    if (!isValidEmail(email)) {
      return 'Vui lòng nhập email hợp lệ';
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await _supabase
          .from('users')
          .update({'onlineStatus': true})
          .eq('email', email.trim());
      return null; // Đăng nhập thành công
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Có lỗi xảy ra';
    } catch (e) {
      return 'Có lỗi xảy ra';
    }
  }

  // Sign up with email and password
  Future<String?> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      return 'Vui lòng nhập đầy đủ thông tin';
    }

    if (!isValidEmail(email)) {
      return 'Vui lòng nhập địa chỉ email hợp lệ';
    }

    if (password.length < 6) {
      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
    }

    try {
      firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      await userCredential.user?.updateDisplayName(fullName.trim());
      await userCredential.user?.reload();

      await _supabase.from('users').insert({
        'email': userCredential.user?.email,
        'name': fullName.trim(),
        'createAt': DateTime.now().toIso8601String(),
      });

      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Có lỗi xảy ra';
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      throw Exception('Vui lòng nhập địa chỉ email');
    }

    if (!isValidEmail(email)) {
      throw Exception('Địa chỉ email không hợp lệ');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Không tìm thấy tài khoản với email này');
        case 'invalid-email':
          throw Exception('Địa chỉ email không hợp lệ');
        case 'too-many-requests':
          throw Exception('Bạn đã yêu cầu quá nhiều lần. Hãy thử lại sau');
        case 'network-request-failed':
          throw Exception('Lỗi kết nối mạng. Kiểm tra Internet và thử lại');
        default:
          throw Exception('Đã xảy ra lỗi. Vui lòng thử lại sau');
      }
    }
  }

  // Change password
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Kiểm tra xem người dùng đã đăng nhập chưa
      final user = _auth.currentUser;
      if (user == null) {
        return 'Vui lòng đăng nhập để đổi mật khẩu';
      }

      // Kiểm tra mật khẩu mới
      if (newPassword.length < 6) {
        return 'Mật khẩu mới phải chứa ít nhất 6 ký tự';
      }

      // Xác thực lại người dùng với mật khẩu hiện tại
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Đổi mật khẩu
      await user.updatePassword(newPassword);
      return null; // Thành công
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          return 'Mật khẩu hiện tại không đúng';
        case 'weak-password':
          return 'Mật khẩu mới quá yếu';
        case 'too-many-requests':
          return 'Bạn đã yêu cầu quá nhiều lần. Hãy thử lại sau';
        case 'user-not-found':
          return 'Không tìm thấy người dùng';
        default:
          return 'Có lỗi xảy ra: ${e.message}';
      }
    } catch (e) {
      return 'Có lỗi xảy ra';
    }
  }
}
