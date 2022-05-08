import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocerry/globals/globalData.dart';
import 'package:grocerry/home_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  bool isAdding = false;

  String productName = '';
  String productPrice = '';
  String inStock = '';

  backFlow() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return WillPopScope(
      onWillPop: () => backFlow(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => backFlow(),
            icon: Icon(Icons.arrow_back),
          ),
          title: Text('Scan Product', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue[900],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: isAdding
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Adding to cart..',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          )),
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )),
                        ]))
                  : Center(
                      child: Container(
                      margin: EdgeInsets.only(
                          top: 10, bottom: 50, left: 10, right: 10),
                      child: QRView(
                        overlay: QrScannerOverlayShape(
                            borderColor: Colors.red,
                            borderRadius: 10,
                            borderLength: 10,
                            borderWidth: 8,
                            cutOutSize: scanArea),
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                        onPermissionSet: (ctrl, p) =>
                            _onPermissionSet(context, ctrl, p),
                      ),
                    )),
            ),
          ],
        ),
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      showSnackBar(context, Colors.red, 'No permission');
    }
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (!isAdding && mounted) {
        await controller.pauseCamera();

        setState(() {
          isAdding = true;
        });

        DocumentSnapshot<Map<String, dynamic>> singleProduct =
            await FirebaseFirestore.instance
                .collection('Products')
                .doc(scanData.code)
                .get();
        if (singleProduct.exists) {
          if (int.parse(singleProduct.get('instock')) > 0) {
            productName = singleProduct.get('name');
            productPrice = singleProduct.get('price');
            inStock = singleProduct.get('instock');
            String updatedStock =
                (int.parse(singleProduct.data()['instock']) - 1).toString();

            updateInstock(scanData.code, updatedStock);
            await FirebaseFirestore.instance
                .collection('AllUsers')
                .doc(FirebaseAuth.instance.currentUser.email)
                .collection('Carts')
                .doc(scanData.code)
                .get()
                .then((doc) async {
              if (doc.exists) {
                await updateCartProduct(scanData.code,
                    (int.parse(doc.data()['quantity']) + 1).toString());
              } else {
                await FirebaseFirestore.instance
                    .collection('AllUsers')
                    .doc(FirebaseAuth.instance.currentUser.email)
                    .collection('Carts')
                    .doc(scanData.code)
                    .set({
                  'productName': productName,
                  'price': productPrice,
                  'quantity': '1',
                  'productCode': scanData.code,
                  'category': singleProduct.get('category')
                });
              }
            });

            setState(() {
              result = scanData;
            });

            Fluttertoast.showToast(
                msg: "Product has been added to cart",
                toastLength: Toast.LENGTH_SHORT);
          

            backFlow();
          } else {
            setState(() {
              isAdding = false;
            });
            showSnackBar(context, Colors.red, 'Out of stock');
          }
        } else {
          if (mounted) {
            setState(() {
              isAdding = false;
            });
            try {
              ScaffoldMessenger.of(context).clearSnackBars();
            } catch (e) {
              print(e);
            }
            showSnackBar(context, Colors.red, 'Cannot recognize product');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
