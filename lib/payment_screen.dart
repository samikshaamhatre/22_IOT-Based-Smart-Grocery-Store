import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocerry/globals/globalData.dart';
import 'package:grocerry/home_page.dart';

class PaymentScreen extends StatelessWidget {
  var quantity, totalPrice;
  String cardNo = '', expiryDate = '', cvv, userName = '';
  PaymentScreen(this.quantity, this.totalPrice);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => backFlow(context),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                backFlow(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 26),
            ),
            title: Text('Payment', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue[900],
          ),
          body: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Method', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Card(
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        TextFormField(
                          autocorrect: false,
                          maxLength: 16,
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: false,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            cardNo = val;
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Card No.',
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: TextFormField(
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                enableSuggestions: false,
                                maxLength: 5,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Cannot be empty';
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  expiryDate = val;
                                },
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(
                                //     RegExp(r'^\d{2}\/\d{2}$'),
                                //   )
                                // ],
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  hintText: 'Expiry Date',
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                enableSuggestions: false,
                                maxLength: 3,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Cannot be empty';
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  cvv = val;
                                },
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'CVV',
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: false,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            userName = val;
                          },
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: 'User Name',
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              )),
          bottomNavigationBar: SafeArea(
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
                    offset: Offset(0.0, 0.0), // shadow direction: bottom right
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
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Total Price: $rupeeSymbol$totalPrice',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                        child: Text('Pay',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white)),
                      ),
                      onPressed: () {
                        validate(context);
                      },
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  validate(context) {
    if (cardNo.isEmpty ||
        expiryDate.isEmpty ||
        cvv.isEmpty ||
        userName.isEmpty) {
      showSnackBar(context, Colors.red, 'Please fill all the details');
    } else {
      RegExp expiryDataRegex = RegExp(r'^\d{2}\/\d{2}$');

      if (cardNo == '5123456789123456' &&
          expiryDataRegex.hasMatch(expiryDate)) {
        Timer timer =
            Timer(Duration(minutes: 1, seconds: 30), (() => backFlow(context)));

        // payment successful
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              return WillPopScope(
                onWillPop: () => null,
                child: AlertDialog(
                  insetPadding: EdgeInsets.symmetric(horizontal: 30),
                  contentPadding: EdgeInsets.all(20),
                  title:
                      Text('Payment Successful', textAlign: TextAlign.center),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                          image: AssetImage(
                            "assets/payement_success.png",
                          ),
                          height: 100.0),
                      SizedBox(height: 10),
                      Text('Please wait until admin approves your order.',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            });
      } else {
        showSnackBar(context, Colors.red, 'Please fill the valid card details');
      }
    }
  }

  backFlow(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => MyHomePage()));
  }
}
