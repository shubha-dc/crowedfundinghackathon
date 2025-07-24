import 'package:flutter/material.dart';

// void main() =>
//     runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));

import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crowdfund App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) =>
            HomePage(username: 'John Doe', userEmail: 'john@example.com'),
      },
    );
  }
}
