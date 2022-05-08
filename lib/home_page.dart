import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocerry/globals/globalData.dart';
import 'package:grocerry/payment_screen.dart';
import 'package:grocerry/scan_screeen.dart';
import 'auth_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int backCount = 0;
  var currentCartList = [];
  bool showSuggestion = false;
  double totalPrice = 0.0;
  int quantity = 0;
  onBackPressed() {
    backCount++;
    if (backCount > 1) {
      SystemNavigator.pop();
    } else {
      Fluttertoast.showToast(
          msg: "Press back again to exit", toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  getPriceAndQuantity(currentCartList) {
    totalPrice = 0;
    quantity = 0;

    currentCartList.forEach((e) {
      var currentPrice = e.data()['price'];
      quantity += int.parse(e.data()['quantity']);
      totalPrice = totalPrice +
          double.parse(currentPrice) * double.parse(e.data()['quantity']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(),
      child: Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => ScanPage()));
                      },
                      icon: Icon(Icons.qr_code_scanner,
                          color: Colors.white, size: 26),
                    ),
                  )),
            ],
            title: Text('Cart', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue[900],
          ),
          drawer: SafeArea(
              child: Drawer(
            child: Column(children: [
              UserAccountsDrawerHeader(
                accountName: Text(''),
                accountEmail: Text(
                  FirebaseAuth.instance.currentUser.email,
                  style: TextStyle(fontSize: 20),
                ),
                decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12.0))),
              ),
              ListTile(
                  title: Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => AuthScreen()),
                          (route) => false);
                    });
                  }),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Divider(
                  thickness: 2.5,
                ),
              ),
            ]),
          )),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getCartList(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snap.data.docs.length <= 0) {
                  return Center(
                      child: Text(
                    'No items in cart',
                    style: TextStyle(fontSize: 20),
                  ));
                } else {
                  currentCartList = snap.data.docs;
                  // totalPrice = 0.0;
                  // quantity = 0;

                  // currentCartList.forEach((e) {
                  //   var currentPrice = e.data()['price'];
                  //   quantity += int.parse(e.data()['quantity']);
                  //   totalPrice = totalPrice +
                  //       double.parse(currentPrice) *
                  //           double.parse(e.data()['quantity']);
                  // });

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Text(
                      //     'Total Items: $quantity   Total Price: $rupeeSymbol$totalPrice',
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.bold, fontSize: 18),
                      //   ),
                      // ),
                      Expanded(
                        flex: 10,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: currentCartList.length,
                            itemBuilder: (ctx, i) {
                              return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Colors.black)),
                                    title: Text(currentCartList[i]
                                        .data()['productName']),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                            'Qty: ${currentCartList[i].data()['quantity']}'),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                            '${int.parse(currentCartList[i].data()['quantity'])} x ${double.parse(currentCartList[i].data()['price'])}'),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                            'Total Price: $rupeeSymbol${double.parse(currentCartList[i].data()['price']) * double.parse(currentCartList[i].data()['quantity'])}'),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            padding: EdgeInsets.all(2),
                                            onPressed: () async {
                                              int currentQuantity = int.parse(
                                                  currentCartList[i]
                                                      .data()['quantity']);
                                              int updatedStock =
                                                  currentQuantity - 1;
                                              if (updatedStock == 0) {
                                                deleteCartProduct(context,
                                                    currentCartList[i].id);
                                                setState(() {
                                                  currentCartList =
                                                      currentCartList;
                                                });
                                                Fluttertoast.showToast(
                                                    msg: 'Prodcuct removed',
                                                    toastLength:
                                                        Toast.LENGTH_SHORT);
                                              } else {
                                                updateCartProduct(
                                                    currentCartList[i]
                                                        .data()['productCode'],
                                                    updatedStock.toString());
                                                setState(() {
                                                  currentCartList =
                                                      currentCartList;
                                                });
                                              }
                                            },
                                            icon: Icon(Icons.remove,
                                                color: Colors.black)),
                                        Text(
                                            '${currentCartList[i].data()['quantity']}'),
                                        IconButton(
                                            padding: EdgeInsets.all(2),
                                            onPressed: () async {
                                              var currentItem =
                                                  currentCartList[i].data();
                                              print(
                                                  'currentItem - $currentItem');

                                              int updatedStock = int.parse(snap
                                                      .data.docs[i]
                                                      .data()['quantity']) +
                                                  1;
                                              DocumentSnapshot<
                                                      Map<String, dynamic>>
                                                  singleProduct =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Products')
                                                      .doc(currentItem[
                                                          'productCode'])
                                                      .get();
                                              int inStockAmount = int.parse(
                                                  singleProduct['instock']);
                                              if (updatedStock >
                                                  inStockAmount) {
                                                showSnackBar(
                                                    context,
                                                    Colors.red,
                                                    'Out of stock.');
                                              } else {
                                                updateCartProduct(
                                                    currentCartList[i]
                                                        .data()['productCode'],
                                                    updatedStock.toString());
                                                setState(() {
                                                  currentCartList =
                                                      currentCartList;
                                                });
                                              }
                                            },
                                            icon: Icon(Icons.add,
                                                color: Colors.black)),
                                        IconButton(
                                            padding: EdgeInsets.all(2),
                                            onPressed: () async {
                                              deleteCartProduct(context,
                                                  currentCartList[i].id);
                                              Fluttertoast.showToast(
                                                  msg: 'Prodcuct removed',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT);
                                              setState(() {
                                                currentCartList =
                                                    snap.data.docs;
                                              });
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.red)),
                                      ],
                                    ),
                                  ));
                            }),
                      ),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('Products')
                              .snapshots(),
                          builder: (ctx, snap) {
                            if (snap.connectionState ==
                                    ConnectionState.waiting ||
                                snap.data.docs.length <= 0 ||
                                currentCartList.length <= 0) {
                              return Container();
                            }
                            var suggestionList = getSuggestionList(
                                snap.data.docs, currentCartList);

                            return suggestionList.length > 0
                                ? Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 0),
                                          child: Text(
                                            'Recommended Products:',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: suggestionList.length,
                                              itemBuilder: (ctx, i) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    addProductInCart(
                                                        context,
                                                        suggestionList[i]
                                                            ['productCode']);
                                                  },
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5.0,
                                                          vertical: 20),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 10.0,
                                                        ),
                                                        width: 150,
                                                        decoration: new BoxDecoration(
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .circular(
                                                                    8),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black)),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                'Name: ${suggestionList[i]['name']}'),
                                                            SizedBox(height: 5),
                                                            Text(
                                                                'Price: $rupeeSymbol${double.parse(suggestionList[i]['price'])}'),
                                                          ],
                                                        ),
                                                      )),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container();
                          })
                    ],
                  );
                }
              }),
          bottomNavigationBar:
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: getCartList(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Container(width: 0, height: 0);
                    } else if (snap.data.docs == null ||
                        snap.data.docs.length <= 0) {
                      return Container(width: 0, height: 0);
                    } else {
                      getPriceAndQuantity(snap.data.docs);
                      return SafeArea(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[100],
                                blurRadius: 1.0,
                                spreadRadius: 4.8,
                                offset: Offset(
                                    0.0, 0.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Items: $quantity',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Total Price: $rupeeSymbol$totalPrice',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      primary: Colors.green),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 15),
                                    child: Text('Proceed',
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (_) => PaymentScreen(
                                                quantity, totalPrice)));
                                  },
                                )
                              ]),
                        ),
                      );
                    }
                  })),
    );
  }

  getCartList() {
    return FirebaseFirestore.instance
        .collection('AllUsers')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('Carts')
        .snapshots();
  }

  getSuggestionList(productList, cartList) {
    var recommendedList = [];
    var cartListProductCodes = [];
    // get all the cart product codes
    for (var cartItem in cartList) {
      var currCartItem = cartItem.data();
      cartListProductCodes.add(currCartItem['productCode']);
    }
    if (cartList.length > 0) {
      for (var cartItem in cartList) {
        var currCartItem = cartItem.data();
        for (var item in productList) {
          var currProductItem = item.data();
          bool itemFound = currProductItem['instock'] != '0' &&
              currProductItem['category'] == currCartItem['category'] &&
              !cartListProductCodes.contains(currProductItem['productCode']);
          if (itemFound) {
            if (recommendedList.length > 0) {
              var obj = recommendedList.firstWhere((element) {
                return element['productCode'] == currProductItem['productCode'];
              }, orElse: () => null);
              if (obj == null) {
                // add item only if list doesn't contain
                // the same item
                recommendedList.add(currProductItem);
              }
            } else {
              recommendedList.add(currProductItem);
            }
          }
        }
      }
    }

    return recommendedList;
  }
}
