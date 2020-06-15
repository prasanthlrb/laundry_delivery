import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:laundry_delivery/HttpAddress.dart';
import 'package:laundry_delivery/PickupDetails.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ItemsPage extends StatefulWidget {
  final ItemInfo value;
  ItemsPage({Key key, this.value}) : super(key: key);
  @override
  _SecondPageState createState() => _SecondPageState();
}

var _txtCustomSub = TextStyle(
  color: Colors.black38,
  fontSize: 13.5,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);
var httpAddr = HttpAddress();
List<String> suggestions = [];
List<Item> items = List();
String delivery_option;
int _ids;

class _SecondPageState extends State<ItemsPage> {
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<Item>>();
  AutoCompleteTextField<Item> textField;
  Item selected;
  @override
  void initState() {
    super.initState();
    _fetchItem();
    setState(() {
      delivery_option = widget.value.delivery_options;
      _ids = widget.value.ids;
    });
  }

  _fetchItem() async {
    final response = await http.get("${httpAddr.url}api/get-item");
    if (response.statusCode == 200) {
      setState(() {
        items = (json.decode(response.body) as List)
            .map((data) => new Item.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load Items');
    }
  }

  _SecondPageState() {
    print("Assign");
    textField = new AutoCompleteTextField<Item>(
      decoration: new InputDecoration(
          hintText: "Search Services:", suffixIcon: new Icon(Icons.search)),
      itemSubmitted: (item) {
        print("Assign1");
        setState(() => selected = item);
        orderDetailPage();
      },
      key: key,
      suggestions: items,
      itemBuilder: (context, suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.name),
          ),
          padding: EdgeInsets.all(8.0)),
      itemSorter: (a, b) => a.id == b.id ? 0 : a.id > b.id ? -1 : 1,
      itemFilter: (suggestion, input) =>
          suggestion.name.toLowerCase().startsWith(input.toLowerCase()),
    );
  }

  SpecialChar(String title) {
    return ButtonTheme(
      minWidth: 40.0,
      child: RaisedButton(
        color: Colors.white,
        onPressed: () {},
        child: Text(title),
      ),
    );
  }

  String dryClean;
  String washIron;
  String ironing;

  int wash = 0;
  int dry = 0;
  int ironn = 0;
  double totalValue = 0;
  Future orderDetailPage() async {
    setState(() {
      wash = 0;
      dry = 0;
      ironn = 0;
      totalValue = 0;
    });
    http.Response response = await http.get(
        "${httpAddr.url}api/get-service/${delivery_option}/${selected.id}");

    Map orderDetails = json.decode(response.body);
    setState(() {
      dryClean = orderDetails['dryclean_price'];
      washIron = orderDetails['wash_price'];
      ironing = orderDetails['iron_price'];
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

  double total = 0;
  double sub = 0;

  List<Cart> cartItems = new List();
  Future<void> _fetchData() async {
    final response = await http.get("${httpAddr.url}api/order-by-item/${_ids}");
    if (response.statusCode == 200) {
      setState(() {
        cartItems = (json.decode(response.body) as List)
            .map((data) => new Cart.fromJson(data))
            .toList();
      });
      (json.decode(response.body) as List).map((data) {
        sub = double.parse(data['total']) + sub;
      }).toList();
      setState(() {
        total = sub;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future<void> _addToCart() {
    http
        .post(
      "${httpAddr.url}api/add-to-cart",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'item_id': selected.id.toString(),
        'order_id': _ids.toString(),
        'laundry_price': washIron,
        'dry_clean_price': dryClean,
        'iron_price': ironing,
        'laundry_qty': wash.toString(),
        'dry_clean_qty': dry.toString(),
        'iron_qty': ironn.toString(),
        'total': totalValue.toString(),
      }),
    )
        .then((response) {
      Navigator.pop(context);
      _fetchData();
    });
  }

  Future<void> _itemPickup() async {
    final response = await http.get("${httpAddr.url}api/item-pickup/${_ids}");
    if (response.statusCode == 200) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          'HomeScreen', (Route<dynamic> route) => false);
    }
  }

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

  _itemAddToOrder() {
    if (total == 0 || total == 0.0) {
      return Padding(
        padding: const EdgeInsets.only(right: 10.0),
      );
    }
    return Padding(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AED ${total}',
                        style:
                            TextStyle(fontSize: 20, color: Colors.lightGreen)),
                    Text('Item Pickup',
                        style:
                            TextStyle(fontSize: 20, color: Color(0xff57d7ca))),
                  ],
                ),
              ))
        ],
      ),
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
                    selected.name,
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
                        _addToCart();
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        title: Text(
          "${delivery_option} Delivery",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
              color: Colors.black54,
              fontFamily: "Poppins-Bold"),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          new Column(children: [
            new Padding(
                child: new Container(child: textField),
                padding: EdgeInsets.all(16.0)),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, left: 0.0, right: 0.0, bottom: 10.0),
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
            _itemAddToOrder(),
          ]),
        ],
      ),
    );
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

class Item {
  int id;
  String name;
  Item._({this.id, this.name});
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item._(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Cart {
  int id;
  String item_name;
  String wash_price;
  String wash_qty;
  String dry_price;
  String dry_qty;
  String iorn_price;
  String iron_qty;
  String total;
  Cart._(
      {this.id,
      this.item_name,
      this.wash_price,
      this.wash_qty,
      this.dry_price,
      this.dry_qty,
      this.iorn_price,
      this.iron_qty,
      this.total});
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart._(
      id: json['id'],
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
