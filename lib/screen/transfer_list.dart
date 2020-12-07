import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/component/transfer/deleteTransfer.dart';
import 'package:problembank/component/transfer/modifyTransfer.dart';
import 'package:problembank/component/transfer/newTransfer.dart';
import 'package:problembank/model/transfer_model.dart';
import 'package:problembank/screen/spent_list.dart';

import 'contact_list.dart';
import 'dashboard.dart';

class TransferList extends StatefulWidget {
  @override
  _TransferListState createState() => _TransferListState();
}

class _TransferListState extends State<TransferList> {

  List<Transfer> items;

  var db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot> transfers;

  @override
  void initState() {
    super.initState();
    items = List();
    transfers?.cancel();
    transfers = db.collection("transferlist").snapshots().listen((snapshot) {
      final List<Transfer> transfer = snapshot.docs
          .map((documentSnapshot) =>
              Transfer.fromMap(documentSnapshot.data(), documentSnapshot.id))
          .toList();
      setState(() {
        this.items = transfer;
      });
    });
  }

  @override
  void dispose() {
    transfers?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Transferencias'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: getContactsList(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                  break;
                default:
                  List<DocumentSnapshot> documentos = snapshot.data.docs;
                  return ListView.builder(
                      itemCount: documentos.length,
                      itemBuilder: (_, index) {
                        return Card(
                          child: ListTile(
                            title: Text(items[index].nome,
                                style: TextStyle(fontSize: 24)),
                            subtitle: Text("Valor: ${items[index].valor}",
                                style: TextStyle(fontSize: 20)),
                            leading: Icon(
                              Icons.attach_money,
                              color: Colors.green,
                              size: 42.0
                            ),
                            trailing:Column(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.delete_forever,
                                      color: Colors.red,
                                      size:24.0,),
                                    onPressed: () => {
                                      deleteTransfer(
                                          context, documentos[index], index)
                                    })
                              ],
                            ) ,
                            onTap: () => {
                              modifyTransfer(
                                context,
                                Transfer(
                                  items[index].id,
                                  items[index].nome,
                                  items[index].valor,
                                ),
                              ),
                            },
                          ),
                        );
                      });
              }
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.note_add),
        onPressed: () => newTransfer(context),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.dashboard),
                    color: Colors.indigo,
                    iconSize: 50.0,
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Dashboard(),
                      ));
                    }
                ),
                IconButton(
                    icon: Icon(Icons.contact_page),
                    color: Colors.indigo,
                    iconSize: 50.0,
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ContactList(),
                      ));
                    }
                ),
                IconButton(
                    icon: Icon(Icons.attach_money),
                    color: Colors.indigo,
                    iconSize: 50.0,
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SpentList(),
                      ));
                    }
                )
              ]
          )
      ),
    );
  }

  Stream<QuerySnapshot> getContactsList() {
    return FirebaseFirestore.instance.collection("transferlist").snapshots();
  }


}
