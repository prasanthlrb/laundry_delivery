import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laundry_delivery/HttpAddress.dart';
import 'package:flutter/cupertino.dart';
import 'package:laundry_delivery/PickupDetails.dart';

class AddCart extends StatefulWidget {
  final ItemInfo value;
  AddCart({Key key, this.value}) : super(key: key);
  @override
  _AddCartState createState() => _AddCartState();
}

class _AddCartState extends State<AddCart> {
  var httpAddr = HttpAddress();
  @override
  String dryClean;
  String washIron;
  String ironing;
  String item_name;
  int item_id;

  int wash = 0;
  int dry = 0;
  int ironn = 0;
  double totalValue = 0;
  bool isSwitched = false;
  List<Items> list = new List();
  String types;
  Future<void> _getItems() async {
    if (isSwitched == true) {
      types = 'express';
    } else {
      types = 'standard';
    }
    final response =
        await http.get("${httpAddr.url}api/item-price-list/${types}");
    if (response.statusCode == 200) {
      setState(() {
        list = (json.decode(response.body) as List)
            .map((data) => new Items.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  void initState() {
    super.initState();

    _getItems();
  }

  static var _txtCustomHead = TextStyle(
    color: Colors.black54,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    fontFamily: "Gotik",
  );

  static var _txtCustomSub = TextStyle(
    color: Colors.black38,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );
  static var _txtCustom = TextStyle(
    color: Colors.black54,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  Widget _wash_iron(washInt) {
    if (washIron == null) {
      return Row();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'WASH & IRON',
          style: TextStyle(fontSize: 15.0),
        ),
        Text('AED ${washIron}'),
        Wrap(
          direction: Axis.horizontal,
          children: <Widget>[
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {
                  _cartFunction('wash', 'in');
                },
                child: Icon(Icons.arrow_upward),
              ),
            ),
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {},
                child: Text(washInt),
              ),
            ),
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {
                  _cartFunction('wash', 'out');
                },
                child: Icon(Icons.arrow_downward),
              ),
            ),
          ],
        ),
      ],
    );
  }
  // var wash_iron =

  _dryclean(dry) {
    if (dryClean == null) {
      return Row();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'DRYCLEAN',
          style: TextStyle(fontSize: 15.0),
        ),
        Text('AED ${dryClean}'),
        Wrap(
          direction: Axis.horizontal,
          children: <Widget>[
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {
                  _cartFunction('dry', 'in');
                },
                child: Icon(Icons.arrow_upward),
              ),
            ),
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {},
                child: Text(dry),
              ),
            ),
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {
                  _cartFunction('dry', 'out');
                },
                child: Icon(Icons.arrow_downward),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _iron(ironn) {
    if (ironing == null) {
      return Row();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'IRONING',
          style: TextStyle(fontSize: 15.0),
        ),
        Text('AED ${ironing}'),
        Wrap(
          direction: Axis.horizontal,
          children: <Widget>[
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {
                  _cartFunction('ironn', 'in');
                },
                child: Icon(Icons.arrow_upward),
              ),
            ),
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {},
                child: Text(ironn),
              ),
            ),
            ButtonTheme(
              minWidth: 10.0,
              child: RaisedButton(
                color: Colors.white,
                onPressed: () {
                  _cartFunction('ironn', 'out');
                },
                child: Icon(Icons.arrow_downward),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    item_name,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                _wash_iron(wash.toString()),
                Padding(padding: const EdgeInsets.all(15.0)),
                _dryclean(dry.toString()),
                Padding(padding: const EdgeInsets.all(15.0)),
                _iron(ironn.toString()),
                Padding(padding: const EdgeInsets.all(30.0)),
                SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    // height: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        // _addToCart();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('AED ${totalValue}',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.lightGreen)),
                          Text('Add to Order',
                              style: TextStyle(
                                  fontSize: 20, color: Color(0xff57d7ca))),
                        ],
                      ),
                    ))
              ],
            ),
          );
        });
  }
// void _onButtonPressed() {

//   }
  _addToCart(int item_id, String item_name, String dryclean_price,
      String wash_price, String iron_price) {
    setState(() {
      dryClean = dryclean_price;
      washIron = wash_price;
      ironing = iron_price;
      item_name = item_name;
      item_id = item_id;
    });
    _onButtonPressed();
  }

  _cartFunction(types, methods) {
    Navigator.pop(context);
    if (types == 'wash') {
      if (methods == 'in') {
        setState(() {
          wash++;
        });
      } else {
        if (wash == 0) {
        } else {
          setState(() {
            wash--;
          });
        }
      }
    } else if (types == 'dry') {
      if (methods == 'in') {
        setState(() {
          dry++;
        });
      } else {
        if (dry == 0) {
        } else {
          setState(() {
            dry--;
          });
        }
      }
    } else {
      if (methods == 'in') {
        setState(() {
          ironn++;
        });
      } else {
        if (ironn == 0) {
        } else {
          setState(() {
            ironn--;
          });
        }
      }
    }
    _mathCal();
    _onButtonPressed();
  }

  _mathCal() {
    double subtotal = 0;
    if (washIron != null) {
      subtotal = (double.parse(washIron) * wash) + subtotal;
    }
    if (dryClean != null) {
      subtotal = (double.parse(dryClean) * dry) + subtotal;
    }
    if (ironing != null) {
      subtotal = (double.parse(ironing) * ironn) + subtotal;
    }
    setState(() {
      totalValue = subtotal;
    });
  }

  Widget bodyData() => DataTable(
      columnSpacing: 12.0,
      columns: <DataColumn>[
        DataColumn(
          label: Container(child: Text("TRADITIONAL")),
          numeric: false,
          onSort: (i, b) {},
        ),
        DataColumn(
          label: Container(
              width: 30.0,
              child: Image(image: AssetImage("assets/icon/laundry.png"))),
          numeric: false,
          onSort: (i, b) {},
        ),
        DataColumn(
          label: Container(
              width: 35.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Image(image: AssetImage("assets/icon/wash.png")),
              )),
          numeric: false,
          onSort: (i, b) {},
        ),
        DataColumn(
          label: Container(
              width: 35.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Image(image: AssetImage("assets/icon/ironing.png")),
              )),
          onSort: (i, b) {},
        ),
        DataColumn(
          label: Text(''),
          onSort: (i, b) {},
        ),
      ],
      rows: list
          .map((data) => DataRow(
                cells: [
                  DataCell(Text(data.item_name), onTap: () {
                    _addToCart(data.item_id, data.item_name,
                        data.dryclean_price, data.wash_price, data.iron_price);
                  }),
                  DataCell(Text(data.dryclean_price), onTap: () {
                    _addToCart(data.item_id, data.item_name,
                        data.dryclean_price, data.wash_price, data.iron_price);
                  }),
                  DataCell(Text(data.wash_price), onTap: () {
                    _addToCart(data.item_id, data.item_name,
                        data.dryclean_price, data.wash_price, data.iron_price);
                  }),
                  DataCell(Text(data.iron_price), onTap: () {
                    _addToCart(data.item_id, data.item_name,
                        data.dryclean_price, data.wash_price, data.iron_price);
                  }),
                  DataCell(
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Icon(Icons.chevron_right),
                      ), onTap: () {
                    _addToCart(data.item_id, data.item_name,
                        data.dryclean_price, data.wash_price, data.iron_price);
                  }),
                ],
              ))
          .toList());

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.value.delivery_options} Delivery",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
              color: Colors.black54,
              fontFamily: "Gotik"),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF6991C7)),
        elevation: 0.0,
      ),
      body: Container(
        child: Column(
          children: [
            // Padding(padding: EdgeInsets.all(10.0)),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: bodyData(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Items {
  int item_id;
  String item_name;
  String dryclean_price;
  String wash_price;
  String iron_price;
  Items._(
      {this.item_id,
      this.item_name,
      this.dryclean_price,
      this.wash_price,
      this.iron_price});
  factory Items.fromJson(Map<String, dynamic> json) {
    return Items._(
      item_id: json['item_id'],
      item_name: json['item_name'],
      dryclean_price: json['dryclean_price'],
      wash_price: json['wash_price'],
      iron_price: json['iron_price'],
    );
  }
}
