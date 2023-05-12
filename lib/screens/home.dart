import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/provider/auth.dart';
import 'dart:ui';

import 'package:sample_app/provider/firebase_api.dart';

import '../provider/dialog.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = Auth().currentUser;

  final _messaging = FirebaseMessaging.instance;
  late final String token;

  @override
  initState() {
    initMsg();
    FirebaseMessaging.onMessage.listen((message) async {
      if (context.mounted) {
        Dialogs.showSnackbar(
          context,
          message.notification!.title,
          message.notification!.body,
        );
      }
    });
    super.initState();
  }


  Future<void> initMsg() async {
    await _messaging.requestPermission();

    await _messaging.getToken().then((t) {
      if (t != null) {
        token = t;
      } else {
        token = "";
      }
    });
    print('Token: $token');
  }

  Future<void> logOut() async {
    await Auth().signOut();
  }

  Widget _singOut() {
    return TextButton(onPressed: logOut, child: const Text('SignOut'));
  }

  // @override
  // void didChangeDependencies() {
  //   try {
  //
  //   } catch(e) {
  //     print(e);
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Sample app'),
        actions: [
          _singOut()
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user?.email ?? 'User email',style: const TextStyle(fontSize: 20), ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                      PopUpDialogBox(
                          builder: (context) => SendNotifications(token: token,)
                      )
                  );
                },
                child: const Text('Send notification')),
          ],
        ),
      ),
    );
  }
}


class SendNotifications extends StatefulWidget {
  const SendNotifications({Key? key, this.token}) : super(key: key);
  final String? token;
  @override
  State<SendNotifications> createState() => _SendNotificationsState();
}

class _SendNotificationsState extends State<SendNotifications> {

  final TextEditingController _msg = TextEditingController();
  final TextEditingController _body = TextEditingController();
  late final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: "todo.sendFcm",
        createRectTween: (b, e) {
          return CustomRectTween(begin: b!, end: e!);
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Material(
              borderRadius: BorderRadius.circular(16),
              // color: Colors.white, // const Color(0xFF1F2426),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          const SizedBox(height: 10,),
                          const Text("Send Message", style: TextStyle(fontSize: 20),),
                          const SizedBox(height: 10,),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Title"
                                ),
                                controller: _msg,
                                validator: (value) {
                                  if(value!.isEmpty){
                                    return 'Please Enter title!';
                                  }
                                  return null;
                                },
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              maxLines: 2,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Body"
                              ),
                              controller: _body,
                              validator: (value) {
                                if(value!.isEmpty){
                                  return 'Please Enter body!';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    _formKey.currentState!.save();
                                    APIs.sendPushNotification(
                                        widget.token!,
                                        _msg.text,
                                      _body.text
                                    ).whenComplete(() {
                                      Navigator.of(context).pop();
                                    });
                                  } ,
                                  child: Text('Send')
                              )
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

class CustomRectTween extends RectTween {
  CustomRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.easeOut.transform(t);
    return Rect.fromLTRB(
      lerpDouble(begin?.left, end?.left, elasticCurveValue)!,
      lerpDouble(begin?.top, end?.top, elasticCurveValue)!,
      lerpDouble(begin?.right, end?.right, elasticCurveValue)!,
      lerpDouble(begin?.bottom, end?.bottom, elasticCurveValue)!,
    );
  }
}

class PopUpDialogBox<T> extends PageRoute<T> {
  PopUpDialogBox({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  })  : _builder = builder,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}