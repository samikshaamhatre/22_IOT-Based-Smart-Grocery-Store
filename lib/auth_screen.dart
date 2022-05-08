import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_page.dart';
import 'auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'globals/globalData.dart';
import 'home_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLoading = false;
  var userEmail = '';
  var userPassword = '';
  var userName = '';
  void setSignUp() {
    setState(() {
      isAdmin = false;
      print(isLogin);
      isLogin = !isLogin;
    });
  }

  bool isAdmin = false;
  void setAdmin() {
    setState(() {
      isAdmin = !isAdmin;
    });
  }

  bool isLogin = true;
  void _submitAuthForm(
    String email,
    String password,
    String name,
  ) async {
    userEmail = email;
    userPassword = password;
    userName = name;
    try {
      setState(() {
        _isLoading = true;
      });

      if (!isLogin) {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) async {
          FirebaseFirestore.instance
              .collection('AllUsers')
              .doc(value.user.email)
              .set({
            'email': value.user.email,
            'name': name,
          });
        }).then((value) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) =>
                      FirebaseAuth.instance.currentUser.email == 'admin@ga.com'
                          ? AdminPage()
                          : MyHomePage()),
              (route) => false);
        });
      } else {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)
            .then((value) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) =>
                      FirebaseAuth.instance.currentUser.email == 'admin@ga.com'
                          ? AdminPage()
                          : MyHomePage()),
              (route) => false);
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        var message = 'An error occurred, please check your credentials!';
        if (err != null) if (err?.message != null) message = err.message;

        showSnackBar(context, Colors.red, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () => null,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12, top: 120),
                  child: Center(
                    child: Image(
                        image: AssetImage(
                          "assets/shopping-cart.png",
                        ),
                        height: 150.0),
                  ),
                ),
              ),
              AuthForm(
                userEmail,
                userName,
                userPassword,
                _submitAuthForm,
                setSignUp,
                _isLoading,
                isLogin,
                setAdmin,
                isAdmin,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
