library globalData;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

String rupeeSymbol = '\u{20B9} ';

updateCartProduct(String productCode, quantity) async {
  await FirebaseFirestore.instance
      .collection('AllUsers')
      .doc(FirebaseAuth.instance.currentUser.email)
      .collection('Carts')
      .doc(productCode)
      .update({
    'quantity': quantity,
  });
}

updateInstock(String productCode, updatedStock) async {
  await FirebaseFirestore.instance
      .collection('Products')
      .doc(productCode)
      .update({
    'instock': updatedStock,
  });
}

deleteCartProduct(context, docId) async {
  await FirebaseFirestore.instance
      .collection('AllUsers')
      .doc(FirebaseAuth.instance.currentUser.email)
      .collection('Carts')
      .doc(docId)
      .delete();
  // showSnackBar(context, Colors.red, 'Item removed');
}

addProductInCart(BuildContext context, String productCode) async {
  DocumentSnapshot<Map<String, dynamic>> singleProduct = await FirebaseFirestore
      .instance
      .collection('Products')
      .doc(productCode)
      .get();
  if (singleProduct.exists) {
    if (int.parse(singleProduct.get('instock')) > 0) {
      var productName = singleProduct.get('name');
      var productPrice = singleProduct.get('price');
      var inStock = singleProduct.get('instock');
      String updatedStock =
          (int.parse(singleProduct.data()['instock']) - 1).toString();

      updateInstock(productCode, updatedStock);
      await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(FirebaseAuth.instance.currentUser.email)
          .collection('Carts')
          .doc(productCode)
          .get()
          .then((doc) async {
        if (doc.exists) {
          await updateCartProduct(
              productCode, (int.parse(doc.data()['quantity']) + 1).toString());
        } else {
          await FirebaseFirestore.instance
              .collection('AllUsers')
              .doc(FirebaseAuth.instance.currentUser.email)
              .collection('Carts')
              .doc(productCode)
              .set({
            'productName': productName,
            'price': productPrice,
            'quantity': '1',
            'productCode': productCode,
            'category': singleProduct.get('category')
          });
        }
      });

      Fluttertoast.showToast(
          msg: "Product has been added to cart",
          toastLength: Toast.LENGTH_SHORT);
    } else {
      showSnackBar(context, Colors.red, 'Out of stock');
    }
  }
}

deleteInventory(context, docId) async {
  await FirebaseFirestore.instance.collection('Products').doc(docId).delete();
  showSnackBar(context, Colors.red, 'Product removed');
}

showSnackBar(context, color, msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 2),
      backgroundColor: color,
      content: Text(msg)));
}
