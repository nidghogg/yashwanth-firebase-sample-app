

import 'package:flutter/material.dart';
import 'package:sample_app/provider/auth.dart';
import 'package:sample_app/screens/home.dart';
import 'package:sample_app/screens/login_register.dart';

class Tree extends StatefulWidget {
  const Tree({Key? key}) : super(key: key);

  @override
  State<Tree> createState() => _TreeState();
}

class _TreeState extends State<Tree> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().userStateChange,
        builder: (context, data) {
            if(data.hasData){
              return HomeScreen();
            } else {
              return const LoginRegisterUser();
            }
        }
    );
  }
}
