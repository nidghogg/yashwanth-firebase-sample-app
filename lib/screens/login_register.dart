import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/provider/auth.dart';

class LoginRegisterUser extends StatefulWidget {
  const LoginRegisterUser({Key? key}) : super(key: key);

  @override
  State<LoginRegisterUser> createState() => _LoginRegisterUserState();
}

class _LoginRegisterUserState extends State<LoginRegisterUser> {
  String? errorMessage = "";
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      await Auth()
          .signIn(email: _emailController.text, pass: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        _emailController.clear();_passwordController.clear();
      });
    }
  }

  Future<void> register() async {
    try {
      await Auth().register(email: _emailController.text, pass: _passwordController.text).whenComplete(() {
        setState(() {
          _passwordController.clear();
          isLogin = true;
        });
      });

    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        _emailController.clear();_passwordController.clear();
      });
    }
  }

  Widget _textField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: title),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == "" ? "" : 'Error: $errorMessage');
  }

  Widget _submit() {
    return ElevatedButton(
        onPressed: () {
          isLogin ? signIn() : register();
        },
        child: Text(isLogin ? 'Login': 'Register'));
  }

  Widget _logButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(isLogin ? 'Register instead': 'Login instead'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _textField('Email', _emailController),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Password',

                  ),
                  obscureText: true,
                ),
                _errorMessage(),
                _submit(),
                _logButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
