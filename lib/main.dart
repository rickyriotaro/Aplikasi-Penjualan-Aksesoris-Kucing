import 'package:apk_petshop/error_page.dart';
import 'package:flutter/material.dart';
import 'package:apk_petshop/order_page.dart';
import 'package:apk_petshop/registrasi_page.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => RegisterPage(),
        '/order': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments;
          print('Received arguments: $arguments'); // Debugging
          if (arguments is int) {
            return OrderPage(orderId: arguments);
          } else {
            return ErrorPage(); // Tangani kesalahan jika argumen tidak valid
          }
        },
      },
    );
  }
}
