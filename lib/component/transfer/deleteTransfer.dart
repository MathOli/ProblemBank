import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/transfer_model.dart';

class deleteTransfer{

  var db = FirebaseFirestore.instance;

  deleteTransfer(
      BuildContext context, DocumentSnapshot doc, int posicao){
    db.collection("transferlist").doc(doc.id).delete();
    setState(() {
      items.removeAt(posicao);
      Navigator.of(context).pop();
    });
  }

  get items => null;

  void setState(Null Function() param0) {}
}