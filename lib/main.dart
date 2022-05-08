import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); //initailizing firebase
  SystemChrome.setPreferredOrientations([
    // adjusting device in portrait mode only
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp()); // main function which run our app
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, //disbaling debug mode banner ,by default true
      title: 'Grocery Store', // name of application
      theme: ThemeData(
        primarySwatch: Colors.blue, //default color of app
      ),
      home: StreamBuilder<User>(
          stream: FirebaseAuth.instance
              .authStateChanges(), //  it will call when we signup,sigin or signout
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(
                      child:
                          CircularProgressIndicator())); //showing loding while we fetch data
            } else if (!snapshot.hasData) {
              return const AuthScreen(); //render when we don't have data
            } else {
              return FirebaseAuth.instance.currentUser.email ==
                      'admin@ga.com' //check whether the email is of admin or not
                  ? const AdminPage()
                  : const MyHomePage();
            }
          }),
    );
  }
}
