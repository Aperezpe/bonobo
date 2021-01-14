import 'package:bonobo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/screens/landing/landing_page.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      create: (context) => Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Bonobo",
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: LandingPage(),
      ),
    );
  }
}
