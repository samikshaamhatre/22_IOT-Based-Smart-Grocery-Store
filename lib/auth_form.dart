import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.userEmail, this.userName, this.userPassword, this.submitFn,
      this.signUpFn, this.isLoading, this.isLogin, this.isAdmin, this.admin,
      {Key key})
      : super(key: key);
  final bool isLoading;
  var userEmail, userName, userPassword;
  final void Function(
    String email,
    String password,
    String username,
  ) submitFn;
  final void Function() signUpFn;
  final void Function() isAdmin;
  final bool isLogin;
  final bool admin;
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  bool _obscureText = true;
  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        widget.userEmail.trim(),
        widget.userPassword.trim(),
        widget.userName.trim(),
      );
    }
  }

  bool setReset = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 900
            ? MediaQuery.of(context).size.width * 0.4
            : double.maxFinite,
        child: Card(
          elevation: 20,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (!widget.isLogin)
                      TextFormField(
                        initialValue: widget.userName,
                        key: const ValueKey('name'),
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a valid name.';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                        onSaved: (value) {
                          widget.userName = value;
                        },
                      ),
                    TextFormField(
                      initialValue: widget.userEmail,
                      key: const ValueKey('email'),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: false,
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                      ),
                      onSaved: (value) {
                        widget.userEmail = value;
                      },
                    ),
                    TextFormField(
                      initialValue: widget.userPassword,
                      key: const ValueKey('password'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 7) {
                          return 'Password must be at least 7 characters long.';
                        }
                        return null;
                      },
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                              padding: EdgeInsets.zero,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () {
                                _toggle();
                              })),
                      onSaved: (value) {
                        widget.userPassword = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    if (widget.isLoading) const CircularProgressIndicator(),
                    if (!widget.isLoading)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          primary: Colors.blue[900],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.isLogin ? 'Login' : 'Sign Up',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white)),
                        ),
                        onPressed: _trySubmit,
                      ),
                    const SizedBox(height: 2),
                    if (!widget.isLoading)
                      if (!widget.admin)
                        TextButton(
                          child: Text(
                              widget.isLogin ? 'User Sign Up' : 'User Login',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blue[900])),
                          onPressed: widget.signUpFn,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
