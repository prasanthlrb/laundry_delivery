import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laundry_delivery/PickupDetails.dart';
import 'package:laundry_delivery/HttpAddress.dart';
import 'package:flutter/cupertino.dart';

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
  String item_name = '';
  int item_id;

  int wash;
  int dry;
  int ironn;
  double totalValue;
  bool isSwitched = false;
  double subTotal = 0;
  List<Items> list = new List();
  String types;
  Future<void> _getItems() async {
    final response = await http.get(
        "${httpAddr.url}api/item-price-list/${widget.value.delivery_options}/${widget.value.ids}");
    if (response.statusCode == 200) {
      setState(() {
        list = (json.decode(response.body) as List)
            .map((data) => new Items.fromJson(data))
            .toList();
      });
      _setTotal();
    } else {
      throw Exception('Failed to load photos');
    }
  }

  void _orderPlaced() async {
    list.map((data) {
      if (data.total > 0) {
        http
            .post(
              "${httpAddr.url}api/add-to-cart",
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'item_id': data.item_id.toString(),
                'order_id': widget.value.ids.toString(),
                'laundry_price': data.wash_price,
                'dry_clean_price': data.dryclean_price,
                'iron_price': data.iron_price,
                'laundry_qty': data.wash_qty.toString(),
                'dry_clean_qty': data.dryclean_qty.toString(),
                'iron_qty': data.iron_qty.toString(),
                'total': data.total.toString(),
              }),
            )
            .then((response) {});
      }
    }).toList();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('HomeScreen', (Route<dynamic> route) => false);
  }

  Future<void> _addItemToServer(int order_id) {
    // Navigator.of(context).push(
    //   PageRouteBuilder(
    //     pageBuilder: (_, __, ___) => new OrderConfirm(order_id),
    //   ),
    // );
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
    if (washIron == '-') {
      return Row();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Image(
          image: AssetImage("assets/icon/wash.png"),
          width: 30.0,
        ),
        Text(
          'WASH & IRON',
          style: TextStyle(fontSize: 15.0),
        ),
        Text('AED ${washIron}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              width: 35.0,
              height: 35.0,
              child: new FloatingActionButton(
                onPressed: () {
                  _cartFunction('wash', 'in');
                },
                child: new Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 20.0,
                ),
                backgroundColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Text('$wash', style: new TextStyle(fontSize: 25.0)),
            ),
            SizedBox(
              width: 35.0,
              height: 35.0,
              child: new FloatingActionButton(
                onPressed: () {
                  _cartFunction('wash', 'out');
                },
                child: new Icon(
                    const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                    size: 20.0,
                    color: Colors.black),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
  // var wash_iron =

  _dryclean(dry) {
    if (dryClean == '-') {
      return Row();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Image(
          image: AssetImage("assets/icon/laundry.png"),
          width: 30.0,
        ),
        Text(
          'DRYCLEAN',
          style: TextStyle(fontSize: 15.0),
        ),
        Text('AED ${dryClean}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 35.0,
              height: 35.0,
              child: new FloatingActionButton(
                onPressed: () {
                  _cartFunction('dry', 'in');
                },
                child: new Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 20.0,
                ),
                backgroundColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Text('$dry', style: new TextStyle(fontSize: 25.0)),
            ),
            SizedBox(
              width: 35.0,
              height: 35.0,
              child: new FloatingActionButton(
                onPressed: () {
                  _cartFunction('dry', 'out');
                },
                child: new Icon(
                    const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                    size: 20.0,
                    color: Colors.black),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  _iron(ironn) {
    if (ironing == '-') {
      return Row();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Image(
          image: AssetImage("assets/icon/ironing.png"),
          width: 30.0,
        ),
        Text(
          'IRONING',
          style: TextStyle(fontSize: 15.0),
        ),
        Text('AED ${ironing}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 35.0,
              height: 35.0,
              child: new FloatingActionButton(
                onPressed: () {
                  _cartFunction('ironn', 'in');
                },
                child: new Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 20.0,
                ),
                backgroundColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Text('$ironn', style: new TextStyle(fontSize: 25.0)),
            ),
            SizedBox(
              width: 35.0,
              height: 35.0,
              child: new FloatingActionButton(
                onPressed: () {
                  _cartFunction('ironn', 'out');
                },
                child: new Icon(
                    const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                    size: 20.0,
                    color: Colors.black),
                backgroundColor: Colors.white,
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
                Padding(padding: const EdgeInsets.all(10.0)),
                _wash_iron(wash.toString()),
                Padding(padding: const EdgeInsets.all(5.0)),
                _dryclean(dry.toString()),
                Padding(padding: const EdgeInsets.all(5.0)),
                _iron(ironn.toString()),
                Padding(padding: const EdgeInsets.all(10.0)),
                SizedBox(
                    width: double.infinity,
                    height: 100.0,
                    // height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        onPressed: () {
                          _addItem();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('AED ${totalValue}',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black54)),
                            Text('ADD ITEMS',
                                style: TextStyle(
                                    fontSize: 20, color: Color(0xff57d7ca))),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          );
        });
  }
// void _onButtonPressed() {

//   }
  int indexed;
  _addToCart(int index) {
    // print(list[index]);
    setState(() {
      dryClean = list[index].dryclean_price;
      washIron = list[index].wash_price;
      ironing = list[index].iron_price;
      item_name = list[index].itemName;
      item_id = list[index].item_id;
      wash = list[index].wash_qty;
      dry = list[index].dryclean_qty;
      ironn = list[index].iron_qty;
      totalValue = double.parse(list[index].total.toString());
      indexed = index;
    });

    _onButtonPressed();
  }

  _cartFunction(types, methods) {
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
  }

  _mathCal() {
    double subtotal = 0;
    if (washIron != '-') {
      subtotal = (double.parse(washIron) * wash) + subtotal;
    }
    if (dryClean != '-') {
      subtotal = (double.parse(dryClean) * dry) + subtotal;
    }
    if (ironing != '-') {
      subtotal = (double.parse(ironing) * ironn) + subtotal;
    }
    setState(() {
      totalValue = subtotal;
    });
    Navigator.pop(context);
    _onButtonPressed();
  }

  _addItem() {
    setState(() {
      list[indexed].dryclean_qty = dry;
      list[indexed].wash_qty = wash;
      list[indexed].iron_qty = ironn;
      list[indexed].total = totalValue;
    });
    Navigator.pop(context);
    _setTotal();
  }

  _setTotal() {
    double subT = 0;
    list.map((data) {
      if (data.total > 0) {
        subT = data.total + subT;
      }
    }).toList();
    setState(() {
      subTotal = subT;
    });
  }

  Widget bodyData() {
    if (list.length > 0) {
      return DataTable(
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
                    selected: data.total != 0 ? true : false,
                    cells: [
                      DataCell(Text(data.itemName), onTap: () {
                        _addToCart(list.indexOf(data));
                      }),
                      DataCell(Text(data.dryclean_price), onTap: () {
                        _addToCart(list.indexOf(data));
                      }),
                      DataCell(Text(data.wash_price), onTap: () {
                        _addToCart(list.indexOf(data));
                      }),
                      DataCell(Text(data.iron_price), onTap: () {
                        _addToCart(list.indexOf(data));
                      }),
                      DataCell(
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Icon(Icons.chevron_right),
                          ), onTap: () {
                        _addToCart(list.indexOf(data));
                        // setState(() {
                        //   data.itemName = "1|${data.itemName}";
                        // });
                      }),
                    ],
                  ))
              .toList());
    } else {
      return Padding(
        padding: new EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
          ],
        ),
      );
    }
  }

  _floatingButton() {
    if (subTotal == 0 || subTotal == 0.0) {
      return Container(
        child: FloatingActionButton.extended(
          onPressed: () {
            // Add your onPressed code here!
            // _orderPlaced(1);
          },
          icon: Icon(Icons.close),
          label: Text('SKIP'),
          backgroundColor: Color(0xff57d7ca),
        ),
      );
    } else {
      return Container(
        padding: new EdgeInsets.only(right: 70.0, bottom: 10.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            //Add your onPressed code here!
            _orderPlaced();
          },
          icon: Icon(Icons.shopping_cart),
          label: Text('Total : AED ${subTotal}'),
          backgroundColor: Color(0xff57d7ca),
        ),
      );
    }
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Price List",
                    style: _txtCustom.copyWith(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: bodyData(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _floatingButton(),
    );
  }
}

class Items {
  int item_id;
  String itemName;
  String dryclean_price;
  String wash_price;
  String iron_price;
  int dryclean_qty;
  int wash_qty;
  int iron_qty;
  double total;
  Items._({
    this.item_id,
    this.itemName,
    this.dryclean_price,
    this.wash_price,
    this.iron_price,
    this.dryclean_qty,
    this.wash_qty,
    this.iron_qty,
    this.total,
  });
  factory Items.fromJson(Map<String, dynamic> json) {
    return Items._(
      item_id: json['item_id'],
      itemName: json['item_name'],
      dryclean_price: json['dryclean_price'],
      wash_price: json['wash_price'],
      iron_price: json['iron_price'],
      dryclean_qty: json['dryclean_qty'],
      wash_qty: json['wash_qty'],
      iron_qty: json['iron_qty'],
      total: double.parse(json['total']),
    );
  }
}
