import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'Widgets/FormCard.dart';
import 'Widgets/SocialIcons.dart';
import 'CustomIcons.dart';
import 'dart:convert';
import 'dart:async';
import 'package:laundry_delivery/bottomNavigationBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laundry_delivery/HttpAddress.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xff57d7ca),
      ),
      routes: <String, WidgetBuilder>{
        "HomeScreen": (BuildContext context) => new bottomNavigationBar(),
        "LoginScreen": (BuildContext context) => new MyApp(),
      },
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isSelected = true;
  var httpAddr = HttpAddress();
  void _radio() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  Map mapValue;
  void createCustomer() {
    var httpAddr = HttpAddress();
    if (nameController.text == '') {
      SnackBar snackBar = new SnackBar(
        content: new Text('Email Address is Required'),
        backgroundColor: Color.fromARGB(255, 255, 0, 0),
        duration: Duration(seconds: 5),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else if (passwordController.text == '') {
      SnackBar snackBar = new SnackBar(
        content: new Text('Password is Required'),
        backgroundColor: Color.fromARGB(255, 255, 0, 0),
        duration: Duration(seconds: 5),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else {
      http
          .post(
        "${httpAddr.url}api/agent-login",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': nameController.text,
          'password': passwordController.text,
        }),
      )
          .then((response) {
        mapValue = json.decode(response.body);
        if (response.statusCode == 200) {
          print("Successfully Login");

          _loginStore(mapValue['driver_name'], mapValue['agent_id'],
              mapValue['message']);
        } else {
          SnackBar snackBar = new SnackBar(
            content: new Text(mapValue['message']),
            backgroundColor: Color.fromARGB(255, 255, 0, 0),
            duration: Duration(seconds: 5),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
        // print(mapValue['message']);
        // mapValue.forEach((key, value) {
        //   print(value);
        //   print(key);
        // });
      });
    }
  }

  Future<void> _loginStore(String name, int id, String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setInt('_id', id);
    SnackBar snackBar = new SnackBar(
      content: new Text(message),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 5),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('HomeScreen', (Route<dynamic> route) => false);
  }

  Widget radioButton(bool isSelected) => Container(
        width: 16.0,
        height: 16.0,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2.0, color: Colors.black)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              )
            : Container(),
      );

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Do you want to exit an App'),
        actions: <Widget>[
          FlatButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text("Yes"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  _loginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final startupNumber = prefs.getInt('_id');
    if (startupNumber != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          'HomeScreen', (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loginCheck();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: new Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Image.asset("assets/images/image_01.png"),
                ),
                Expanded(
                  child: Container(),
                ),
                Expanded(child: Image.asset("assets/images/image_02.png")),
              ],
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 150.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(180),
                    ),
                    Container(
                      width: double.infinity,
                      height: ScreenUtil.getInstance().setHeight(500),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0.0, 15.0),
                                blurRadius: 15.0),
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0.0, -10.0),
                                blurRadius: 10.0),
                          ]),
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Login",
                                style: TextStyle(
                                    fontSize:
                                        ScreenUtil.getInstance().setSp(45),
                                    fontFamily: "Poppins-Bold",
                                    letterSpacing: .6)),
                            SizedBox(
                              height: ScreenUtil.getInstance().setHeight(30),
                            ),
                            Text("Username",
                                style: TextStyle(
                                    fontFamily: "Poppins-Medium",
                                    fontSize:
                                        ScreenUtil.getInstance().setSp(26))),
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                  hintText: "username",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12.0)),
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().setHeight(30),
                            ),
                            Text("PassWord",
                                style: TextStyle(
                                    fontFamily: "Poppins-Medium",
                                    fontSize:
                                        ScreenUtil.getInstance().setSp(26))),
                            TextField(
                              obscureText: true,
                              controller: passwordController,
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12.0)),
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().setHeight(65),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 12.0,
                            ),
                            GestureDetector(
                              onTap: _radio,
                              child: radioButton(_isSelected),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text("Remember me",
                                style: TextStyle(
                                    fontSize: 12, fontFamily: "Poppins-Medium"))
                          ],
                        ),
                        InkWell(
                          child: Container(
                            width: ScreenUtil.getInstance().setWidth(330),
                            height: ScreenUtil.getInstance().setHeight(100),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Color(0xFF17ead9),
                                  Color(0xFF6078ea)
                                ]),
                                borderRadius: BorderRadius.circular(6.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color(0xFF6078ea).withOpacity(.3),
                                      offset: Offset(0.0, 8.0),
                                      blurRadius: 8.0)
                                ]),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  createCustomer();
                                  // Navigator.of(context).push(PageRouteBuilder(
                                  //     pageBuilder: (_, __, ___) =>
                                  //         new bottomNavigationBar()));
                                },
                                child: Center(
                                  child: Text("SIGNIN",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Poppins-Bold",
                                          fontSize: 18,
                                          letterSpacing: 1.0)),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(40),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(30),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
