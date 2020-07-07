import 'package:flutter/material.dart';
import 'package:laundry_delivery/ItemsPage.dart';

import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:laundry_delivery/HttpAddress.dart';
import 'package:laundry_delivery/AddCart.dart';

class PickupDetails extends StatefulWidget {
  int _id;
  PickupDetails(this._id);
  @override
  _PickupDetailsState createState() => _PickupDetailsState(_id);
}

var _txtCustomSub = TextStyle(
  color: Colors.black38,
  fontSize: 13.5,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

var httpAddr = HttpAddress();

class _PickupDetailsState extends State<PickupDetails> {
  // int _id;
  _PickupDetailsState(_id);

  String name;
  String addr_type;
  String addr_title;
  String address1;
  String map_title;
  String mobile;
  String lat;
  String lng;
  String pickup_date;
  String pickup_time;
  String delivery_option;
  double totalValue = 0;
  double sub = 0;
  List<Carts> cartItems = new List();
  Future<void> _fetchData() async {
    final response =
        await http.get("${httpAddr.url}api/order-by-item/${widget._id}");
    if (response.statusCode == 200) {
      setState(() {
        cartItems = (json.decode(response.body) as List)
            .map((data) => new Carts.fromJson(data))
            .toList();
      });
      (json.decode(response.body) as List).map((data) {
        sub = double.parse(data['total']) + sub;
        print(sub);
      }).toList();
      setState(() {
        totalValue = sub;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future orderDetailPage() async {
    http.Response response = await http
        .get("${httpAddr.url}api/get-pickup-order-details/${widget._id}");
    Map orderDetails = json.decode(response.body);
    setState(() {
      name = orderDetails['name'].toString();
      addr_type = orderDetails['addr_type'].toString();
      addr_title = orderDetails['addr_title'].toString();
      address1 = orderDetails['address1'].toString();
      map_title = orderDetails['map_title'].toString();
      mobile = orderDetails['mobile'].toString();
      lat = orderDetails['lat'].toString();
      lng = orderDetails['lng'].toString();
      pickup_date = orderDetails['pickup_date'].toString();
      pickup_time = orderDetails['pickup_time'].toString();
      delivery_option = orderDetails['delivery_option'].toString();
    });
  }

  Future<void> _initCall() async {
    print('mobile : ${mobile}');
    final phone = mobile;
    final url = "tel:$phone";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _initMap() async {
    final lats = lat;
    final lngs = lng;
    print('Lat : ${lat}');
    final url = 'https://www.google.com/maps/search/?api=1&query=$lats,$lngs';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _itemPickup() async {
    final response =
        await http.get("${httpAddr.url}api/item-pickup/${widget._id}");
    if (response.statusCode == 200) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          'HomeScreen', (Route<dynamic> route) => false);
    }
  }

  void initState() {
    super.initState();
    _fetchData();
    orderDetailPage();
  }

  static var _txtCustom = TextStyle(
    color: Colors.black54,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "${name}  (#${widget._id})",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
                color: Colors.black54,
                fontFamily: "Poppins-Bold"),
          ),
          centerTitle: true,
          elevation: 0.0,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => new AddCart(
                          value: ItemInfo(
                              ids: widget._id,
                              delivery_options: delivery_option),
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.add_shopping_cart),
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: 800.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            size: 24.0,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "${pickup_date}",
                          style: _txtCustom,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 120.0),
                        child: InkWell(
                          onTap: () {
                            _initCall();
                            // Navigator.of(context).push(PageRouteBuilder(
                            //     pageBuilder: (_, __, ___) => new chatItem()));
                          },
                          child: Icon(
                            Icons.contact_phone,
                            size: 34.0,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: InkWell(
                          onTap: () {
                            _initMap();
                            // Navigator.of(context).push(PageRouteBuilder(
                            //     pageBuilder: (_, __, ___) => new chatItem()));
                          },
                          child: Icon(
                            Icons.map,
                            size: 34.0,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0, left: 45.5),
                    child: Text(
                      "${pickup_time}",
                      style: _txtCustom,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Center(
                    child: Text(
                      "(${delivery_option} Delivery)",
                      style: _txtCustom.copyWith(
                          color: Colors.lightGreen,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, bottom: 30.0, left: 0.0, right: 10.0),
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
                          Image.asset("assets/images/house.png"),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "PickUp Address",
                                style: _txtCustom.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              Padding(padding: EdgeInsets.only(top: 5.0)),
                              Text(
                                "${addr_type} (${addr_title})",
                                style: _txtCustom.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.0,
                                    color: Colors.black38),
                              ),
                              Padding(padding: EdgeInsets.only(top: 2.0)),
                              Text(
                                "${address1}",
                                style: _txtCustom.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                    color: Colors.black38),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(padding: EdgeInsets.only(top: 2.0)),
                              Container(
                                width: 200.0,
                                child: Text(
                                  " ${map_title}",
                                  textAlign: TextAlign.justify,
                                  style: _txtCustom.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      color: Colors.black38),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Orders",
                    style: _txtCustom.copyWith(
                        color: Colors.black54,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  // Container(
                  //     margin: EdgeInsets.only(right: 20.0),
                  //     child: Table(border: TableBorder.all(), children: [
                  //       TableRow(children: [
                  //         Column(children: [
                  //           Padding(
                  //             padding: const EdgeInsets.all(3.0),
                  //             child: Text('Item'),
                  //           )
                  //         ]),
                  //         Column(children: [
                  //           Padding(
                  //             padding: const EdgeInsets.all(3.0),
                  //             child: Text('Services'),
                  //           )
                  //         ]),
                  //         Column(children: [
                  //           Padding(
                  //             padding: const EdgeInsets.all(3.0),
                  //             child: Text('qty'),
                  //           )
                  //         ]),
                  //         Column(children: [
                  //           Padding(
                  //             padding: const EdgeInsets.all(3.0),
                  //             child: Text('Price'),
                  //           )
                  //         ]),
                  //       ])
                  //     ])),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 0.0, right: 15.0, bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4.5,
                            spreadRadius: 1.0,
                          )
                        ],
                      ),
                      child: Column(
                        children: cartItems.map((data) {
                          return dataTransaction(
                            item: '${data.item_name}',
                            dry: '${data.dry_price} x ${data.dry_qty}',
                            wash: '${data.wash_price} x ${data.wash_qty}',
                            iron: '${data.iorn_price} x ${data.iron_qty}',
                            total: " ${data.total} AED",
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Column(
                      children: [
                        SizedBox(
                            width: double.infinity,
                            // height: double.infinity,
                            child: RaisedButton(
                              onPressed: () {
                                _itemPickup();
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('AED ${totalValue}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.lightGreen)),
                                  Text('Item Pickup',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xff57d7ca))),
                                ],
                              ),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class dataTransaction extends StatelessWidget {
  @override
  String item, dry, wash, iron, total;

  dataTransaction({this.item, this.dry, this.wash, this.iron, this.total});

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 50.0,
                child: Text(
                  item,
                  style: _txtCustomSub.copyWith(color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 1.0),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 1.0),
                child: Text(
                  dry,
                  style: _txtCustomSub.copyWith(
                      color: Colors.black38,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  wash,
                  style: _txtCustomSub.copyWith(
                      color: Colors.black38,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  iron,
                  style: _txtCustomSub.copyWith(
                      color: Colors.black38,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Text(total,
                  style: _txtCustomSub.copyWith(
                    color: Colors.redAccent,
                    fontSize: 16.0,
                  )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            height: 0.5,
            color: Colors.black12,
          ),
        ),
      ],
    );
  }
}

class ItemInfo {
  final int ids;
  final String delivery_options;
  const ItemInfo({this.ids, this.delivery_options});
}

class Carts {
  String id;
  String item_name;
  String wash_price;
  String wash_qty;
  String dry_price;
  String dry_qty;
  String iorn_price;
  String iron_qty;
  String total;
  Carts._(
      {this.id,
      this.item_name,
      this.wash_price,
      this.wash_qty,
      this.dry_price,
      this.dry_qty,
      this.iorn_price,
      this.iron_qty,
      this.total});
  factory Carts.fromJson(Map<String, dynamic> json) {
    return Carts._(
      item_name: json['name'],
      wash_price: json['laundry_price'],
      dry_price: json['dry_clean_price'],
      iorn_price: json['iron_price'],
      wash_qty: json['laundry_qty'],
      dry_qty: json['dry_clean_qty'],
      iron_qty: json['iron_qty'],
      total: json['total'],
    );
  }
}
