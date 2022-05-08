import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocerry/HistoryScreen.dart';
import 'package:grocerry/adminInventory.dart';
import 'package:grocerry/globals/globalData.dart';
import 'package:intl/intl.dart';

import 'auth_screen.dart';

class AdminPage extends StatefulWidget {
  // when we want to update UI(user interfaces) we will be using statefulwidget other statelesswidget
  const AdminPage({Key key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Pending Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      drawer: SafeArea(
          child: Drawer(
        child: Column(children: [
          UserAccountsDrawerHeader(
            accountName: Text(''),
            accountEmail: Text(FirebaseAuth.instance.currentUser.email,
                style: TextStyle(fontSize: 20)),
            decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12.0))),
          ),
          ListTile(
              title: Text('Pending Order'),
              onTap: () async {
                Navigator.of(context).pop();
              }),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Divider(
              thickness: 2.5,
            ),
          ),
          ListTile(
              title: Text('Inventory'),
              onTap: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => InventoryScreen()),
                );
              }),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Divider(
              thickness: 2.5,
            ),
          ),
          ListTile(
              title: Text('History'),
              onTap: () async {
                Navigator.of(context).pop();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => HistoryScreen()),
                );
              }),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Divider(
              thickness: 2.5,
            ),
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
        stream: FirebaseFirestore.instance.collection('AllUsers').snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: snap.data.docs.length,
                      itemBuilder: (ctx, i) {
                        return FutureBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance
                                .collection('AllUsers')
                                .doc(snap.data.docs[i].data()['email'])
                                .collection('Carts')
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (!snapshot.hasData ||
                                  snapshot.hasError ||
                                  snapshot.data.docs.length <= 0) {
                                return Divider(
                                  thickness: 0.0,
                                  height: 0.0,
                                );
                              } else {
                                double totalPrice = 0.0;
                                int quantity = 0;
                                snapshot.data.docs.forEach((e) {
                                  quantity += int.parse(e.data()['quantity']);
                                  totalPrice = totalPrice +
                                      double.parse(e.data()['price']) *
                                          double.parse(e.data()['quantity']);
                                });
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 10),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Colors.black)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Name: ${snap.data.docs[i].data()['name']}'),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text('Total Items: $quantity'),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text('Total Price: $totalPrice'),
                                            ],
                                          ),
                                          ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.green),
                                              label: Text('Checkout'),
                                              onPressed: () async {
                                                Map data = {};
                                                snapshot.data.docs
                                                    .forEach((element) {
                                                  data.putIfAbsent(element.id,
                                                      () => element.data());
                                                });
                                                await FirebaseFirestore.instance
                                                    .collection('AllOrders')
                                                    .doc()
                                                    .set({
                                                  'totalPrice': totalPrice,
                                                  'totalQuantity': quantity,
                                                  'email': snap.data.docs[i]
                                                      .data()['email'],
                                                  'orderDate': DateFormat(
                                                          'dd-MM-yyyy hh:mm a')
                                                      .format(DateTime.now()),
                                                  'data': data,
                                                }).then((value) async {
                                                  await snapshot.data.docs
                                                      .forEach((element) async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('AllUsers')
                                                        .doc(snap.data.docs[i]
                                                            .data()['email'])
                                                        .collection('Carts')
                                                        .doc(element.id)
                                                        .delete();
                                                  });
                                                }).then((value) {
                                                  showSnackBar(
                                                      context,
                                                      Colors.green,
                                                      'Order Checked Out');
                                                  setState(() {});
                                                });
                                              },
                                              icon: Icon(Icons.check))
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            });
                      }),
                ),
              ],
            );
          }
        },
      ),
    ));
  }
}
