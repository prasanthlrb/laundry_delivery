import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:laundry_delivery/DeliveryDetails.dart';
import 'package:laundry_delivery/main.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:laundry_delivery/HttpAddress.dart';

var _txtCustomHead = TextStyle(
  color: Color(0xff57d7ca),
  fontSize: 20.0,
  fontWeight: FontWeight.w600,
  fontFamily: "Gotik",
);

class DeliveryPage extends StatefulWidget {
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

var httpAddr = HttpAddress();

class _DeliveryPageState extends State<DeliveryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List myList;
  ScrollController _scrollController = ScrollController();
  int _currentMax = 10;
  List<Orders> list = new List();
  @override
  static var _txtCustom = TextStyle(
    color: Colors.black54,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );
  Future<void> _fetchData() async {
    final response = await http.get("${httpAddr.url}api/get-delivery-order");
    if (response.statusCode == 200) {
      // print(response.body.length);
      setState(() {
        list = (json.decode(response.body) as List)
            .map((data) => new Orders.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  void initState() {
    super.initState();
    _fetchData();
    myList = List.generate(list.length, (i) => items[i]);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // _getMoreData();
      }
    });
  }

  // _getMoreData() {
  //   if (items.length - _currentMax > 10) {
  //     print("Available${items.length - _currentMax}");
  //     for (int i = _currentMax; i < _currentMax + 10; i++) {
  //       myList.add(items[i]);
  //     }
  //   } else {
  //     print("Not Available ${items.length - _currentMax}");
  //     for (int i = _currentMax; i < items.length; i++) {
  //       myList.add(items[i]);
  //     }
  //   }
  //   _currentMax = _currentMax + 10;
  //   setState(() {});
  // }
  _gotoDetails(id) {
    Navigator.of(context).push(
        PageRouteBuilder(pageBuilder: (_, __, ___) => new DeliveryDetails(id)));
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('_id');
    prefs.remove('name');
    Navigator.of(context).pushNamedAndRemoveUntil(
        'LoginScreen', (Route<dynamic> route) => false);
  }

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

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Text(
              "Delivery Order",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.black54,
                  fontFamily: "Poppins-Bold"),
            ),
            centerTitle: true,
            actions: <Widget>[
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                      value: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            _logout();
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      )),
                ],
              )
            ],
            iconTheme: IconThemeData(color: Color(0xFF6991C7)),
            elevation: 0.0,
            automaticallyImplyLeading: false),
        body: ListView.builder(
          itemCount: list.length,
          itemExtent: 150,
          itemBuilder: (BuildContext context, int i) {
            if (i == list.length) {
              return CupertinoActivityIndicator();
            }
            return GestureDetector(
              onTap: () {
                _gotoDetails(list[i].id);
                // Navigator.of(context).push(PageRouteBuilder(
                //     pageBuilder: (_, __, ___) => new PickupDetails()));
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                child: Container(
                  height: 130.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.1),
                          blurRadius: 4.5,
                          spreadRadius: 1.0,
                        )
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset(
                        "assets/images/delivery.png",
                        height: 70.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            list[i].name,
                            style: _txtCustom.copyWith(
                                fontWeight: FontWeight.w700),
                          ),
                          Padding(padding: EdgeInsets.only(top: 5.0)),
                          Text(
                            "${list[i].addr_type} (${list[i].addr_title})",
                            style: _txtCustom.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.0,
                                color: Colors.black38),
                          ),
                          Padding(padding: EdgeInsets.only(top: 2.0)),
                          Text(
                            "${list[i].address1},",
                            textAlign: TextAlign.justify,
                            style: _txtCustom.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                                color: Colors.black38),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Padding(padding: EdgeInsets.only(top: 2.0)),
                          Container(
                            width: 150.0,
                            child: Text(
                              " ${list[i].map_title}",
                              textAlign: TextAlign.justify,
                              style: _txtCustom.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.0,
                                  color: Colors.black38),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Item {
  String orderId;
  String orderProcess;
  String orderDate;
  Item({this.orderDate, this.orderId, this.orderProcess});
}

List items = <Item>[
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#091"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#092"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#093"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#094"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#095"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#096"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#097"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#098"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#099"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#0910"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#0911"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#0912"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#0913"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#0914"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#0915"),
  Item(orderDate: "21-4-2020 4:00pm", orderProcess: "Pickup", orderId: "#0916"),
];

class Orders {
  int id;
  String name;
  String addr_type;
  String addr_title;
  String address1;
  String map_title;
  Orders._(
      {this.id,
      this.name,
      this.addr_type,
      this.addr_title,
      this.address1,
      this.map_title});
  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders._(
      id: json['id'],
      name: json['name'],
      addr_type: json['addr_type'],
      addr_title: json['addr_title'],
      address1: json['address1'],
      map_title: json['map_title'],
    );
  }
}
