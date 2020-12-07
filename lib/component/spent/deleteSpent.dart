import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class deleteSpent{

  var db = FirebaseFirestore.instance;

  deleteSpent(
      BuildContext context, DocumentSnapshot doc, int posicao){
    db.collection("spendinglist").doc(doc.id).delete();
    setState(() {
      items.removeAt(posicao);
      Navigator.of(context).pop();
    });
  }
  get items => null;

  void setState(Null Function() param0) {}
}