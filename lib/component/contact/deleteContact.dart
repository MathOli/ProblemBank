import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class deleteContact{

  var db = FirebaseFirestore.instance;

  deleteContact(
      BuildContext context, DocumentSnapshot doc, int posicao){
        db.collection("contactlist").doc(doc.id).delete();
        setState(() {
          items.removeAt(posicao);
    
        });
  }

  get items => null;

  void setState(Null Function() param0) {}
}