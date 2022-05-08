import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_page.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key key}) : super(key: key);
  backFlow(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => AdminPage()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => backFlow(context),
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => AdminPage())),
              icon: Icon(Icons.arrow_back),
            ),
            backgroundColor: Colors.blue[900],
            title: Text('Order History')),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('AllOrders')
                .orderBy('orderDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.data.docs.length <= 0) {
                return Center(
                    child: Text(
                  'No Order History',
                  style: TextStyle(fontSize: 20),
                ));
              } else {
                List<QueryDocumentSnapshot<Map<String, dynamic>>> historyData =
                    snapshot.data.docs.reversed.toList();
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                  child: ListView.builder(
                      itemCount: historyData.length,
                      itemBuilder: (ctx, i) {
                        var data = snapshot.data.docs[i];

                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(
                              top: 5.0, left: 8.0, right: 8.0, bottom: 5.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${data['email']}'),
                                SizedBox(
                                  height: 3,
                                ),
                                Text('Order Date: ${data['orderDate']}'),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                    'Total Quantity: ${data['totalQuantity']}'),
                                SizedBox(
                                  height: 3,
                                ),
                                Text('Total Price: ${data['totalPrice']}'),
                              ],
                            ),
                          ),
                        );
                      }),
                );
              }
            }),
      )),
    );
  }
}
