import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:grocerry/globals/globalData.dart';
import 'admin_page.dart';

class InventoryScreen extends StatelessWidget {
  InventoryScreen({Key key}) : super(key: key);

  final TextEditingController priceController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController stockController = TextEditingController();

  String productCategory = '';
  List<String> productCategoryList = [
    'Select Category',
    'Dals or Pulses',
    'Salt / Sugar / Jaggery',
    'Rice & Rice Products',
    'Dry Fruits',
    'Masala & Spices',
    'Flours & Grains',
    'Cooking Oil & Ghee'
  ];

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
          actions: [
            TextButton.icon(
                onPressed: () {
                  showProductDialog(context, true);
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ))
          ],
          title: Text('Inventory'),
          backgroundColor: Colors.blue[900],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('Products').snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(height: 1, color: Colors.black),
                    itemCount: snap.data.docs.length,
                    itemBuilder: (ctx, i) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                        title:
                            Text('Name: ${snap.data.docs[i].data()['name']}'),
                        subtitle: Text(
                            'Price: $rupeeSymbol${double.parse(snap.data.docs[i].data()['price'])}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'Stock: ${snap.data.docs[i].data()['instock']}'),
                            IconButton(
                                padding: EdgeInsets.all(2),
                                onPressed: () async {
                                  deleteInventory(
                                      context, snap.data.docs[i].id);
                                },
                                icon: Icon(Icons.delete, color: Colors.red))
                          ],
                        ),
                        onTap: () {
                          showProductDialog(context, false,
                              productObj: snap.data.docs[i].data());
                        },
                      );
                    }),
              );
            }
          },
        ),
      )),
    );
  }

  showProductDialog(BuildContext context, bool isAdd, {var productObj}) {
    productCategory = '';
    var imageFile;
    if (!isAdd) {
      priceController.text = productObj['price'];
      stockController.text = productObj['instock'];
      productCategory = productObj['category'];
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return WillPopScope(
            onWillPop: () => null,
            child: AlertDialog(
              title: Text('${isAdd ? 'Add' : 'Update'} Product'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    isAdd
                        ? DropdownButton<String>(
                            value: productCategory.isEmpty
                                ? productCategoryList[0]
                                : productCategory,
                            style: TextStyle(color: Colors.black),
                            items: productCategoryList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            hint: Text(
                              "Select Category",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            onChanged: (String value) {
                              if (value != 'Select Category') {
                                setState(() {
                                  productCategory = value;
                                });
                              }
                            },
                          )
                        : Text(
                            'Category: ${productObj['category']}',
                            // textAlign: TextAlign.start,
                          ),
                    if (!isAdd) SizedBox(height: 5),
                    isAdd
                        ? TextField(
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                                hintStyle: TextStyle(fontSize: 14),
                                hintText: 'Product name'),
                            controller: nameController,
                          )
                        : Text(
                            'Name: ${productObj['name']}',
                            // textAlign: TextAlign.start,
                          ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          labelText: isAdd ? null : 'Product price',
                          hintStyle: TextStyle(fontSize: 14),
                          hintText: !isAdd ? null : 'Product price'),
                      keyboardType: TextInputType.number,
                      controller: priceController,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          labelText: isAdd ? null : 'Available in stock',
                          hintStyle: TextStyle(fontSize: 14),
                          hintText: !isAdd ? null : 'Available in stock'),
                      keyboardType: TextInputType.number,
                      controller: stockController,
                    ),
                  ],
                );
              }),
              actions: [
                TextButton(
                    onPressed: () {
                      dismissPopup(context);
                    },
                    child: Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      productDialogAction(context, isAdd,
                          productObj: isAdd ? null : productObj);
                    },
                    child: Text(isAdd ? 'Add' : 'Update')),
              ],
            ),
          );
        });
  }

  dismissPopup(BuildContext context) {
    if (priceController.text.isNotEmpty) priceController.clear();
    if (stockController.text.isNotEmpty) stockController.clear();
    if (nameController.text.isNotEmpty) nameController.clear();
    Navigator.of(context).pop();
  }

  productDialogAction(BuildContext context, bool isAdd,
      {var productObj}) async {
    FocusScope.of(context).requestFocus(FocusNode());

    var price = priceController.text == null ? '' : priceController.text.trim();
    var name = !isAdd
        ? productObj['name']
        : nameController.text == null
            ? ''
            : nameController.text.trim();
    var instock =
        stockController.text == null ? '' : stockController.text.trim();

    if ((isAdd &&
            (price.isEmpty ||
                name.isEmpty ||
                instock.isEmpty ||
                productCategory.isEmpty)) ||
        (!isAdd && (price.isEmpty && instock.isEmpty))) {
      showSnackBar(
          context, Colors.red, 'All fields are mandatory to add the product.');
    } else {
      QuerySnapshot<Map<String, dynamic>> productsList =
          await FirebaseFirestore.instance.collection('Products').get();

      var product;
      try {
        product = productsList.docs.length == 0
            ? null
            : productsList.docs.firstWhere(
                (element) =>
                    element['name'].toLowerCase() == name.toLowerCase(),
                orElse: () => null);
      } catch (e) {
        print(e);
      }

      if (product != null) {
        if (isAdd) {
          showSnackBar(context, Colors.red, 'Product already exists.');
        } else {
          if (instock.isEmpty) {
            instock = productObj['instock'];
          }
          if (price.isEmpty) {
            price = productObj['price'];
          }
          if (instock != productObj['instock'] ||
              price != productObj['price']) {
            // update only if user have changed something.
            updateProduct(
                context, productObj['productCode'], price, name, instock);
          } else {
            dismissPopup(context);
          }
        }
      } else {
        addProduct(context, productsList, price, name, instock);
      }
    }
  }

  addProduct(BuildContext context, productsList, price, name, instock) async {
    // Generate a v1 (time-based) id
    String productCode = Uuid().v1();
    FirebaseFirestore.instance.collection('Products').doc(productCode).set({
      'productCode': productCode,
      'category': productCategory,
      'name': name,
      'price': price,
      'instock': instock,
    }).then((value) {
      dismissPopup(context);
      showSnackBar(context, Colors.green, 'Product added.');
    });
  }

  updateProduct(BuildContext context, productCode, price, name, instock) async {
    await FirebaseFirestore.instance
        .collection('Products')
        .doc(productCode)
        .update({
      'productCode': productCode,
      'price': price,
      'name': name,
      'instock': instock
    }).then((value) {
      dismissPopup(context);
      showSnackBar(context, Colors.green, 'Product updated.');
    });
  }
}
