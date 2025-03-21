import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/redux/actions.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:you_can_cook/redux/middleware.dart';
import 'package:redux/redux.dart';
import 'package:you_can_cook/firebase_options.dart';
import 'screens/SplashScreen/splash.dart';
//import 'package:flutter/foundation.dart';
//import 'package:device_preview/device_preview.dart';
import 'package:you_can_cook/screens/Main/home.dart';
import 'package:you_can_cook/db/db.dart';
import 'package:you_can_cook/utils/color.dart';

// void main() {
//   runApp(DevicePreview(
//     enabled: !kReleaseMode,
//     builder: (context) => MyApp(), // Wrap your app
//   ),);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeSupabase();
  final store = Store<AppState>(
    appReducer,
    initialState: AppState(),
    middleware: [appMiddleware],
  );
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  const MyApp({super.key, required this.store});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // useInheritedMediaQuery: true,
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Đang kiểm tra trạng thái (hiển thị SplashScreen trong lúc chờ)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }
        // Nếu người dùng đã đăng nhập
        if (snapshot.hasData) {
          return HomeScreen();
        }
        // Nếu chưa đăng nhập
        return SplashScreen();
      },
    );
  }
}
