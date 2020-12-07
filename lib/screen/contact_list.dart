import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:problembank/model/contact_model.dart';
import 'package:problembank/screen/dashboard.dart';
import 'package:problembank/screen/spent_list.dart';
import 'package:problembank/screen/transfer_list.dart';
import 'package:problembank/component/contact/newContact.dart';
import 'package:problembank/component/contact/modifyContact.dart';
import 'package:problembank/component/contact/deleteContact.dart';

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Contact> items;

  var db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot> contacts;

  @override
  void initState() {
    super.initState();
    items = List();
    contacts?.cancel();
    contacts = db.collection("contactlist").snapshots().listen((snapshot) {
      final List<Contact> contact = snapshot.docs
          .map((documentSnapshot) =>
              Contact.fromMap(documentSnapshot.data(), documentSnapshot.id))
          .toList();
      setState(() {
        this.items = contact;
      });
    });
  }

  @override
  void dispose() {
    contacts?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Contatos'),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
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
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(text: items[index].nome, style: TextStyle(fontSize: 24)),
                                  TextSpan(text: " (${items[index].banco})", style: TextStyle(fontSize: 16, color: Colors.grey))
                                ],
                              ),
                            ),
//                            Text(items[index].nome,
//                                style: TextStyle(fontSize: 24)),
                            subtitle: Text(
                                "Ag: ${items[index].agencia}/Cc: ${items[index].conta}",
                                style: TextStyle(fontSize: 20)),
                            leading: Icon(
                              Icons.person,
                              color: Colors.indigo,
                              size: 42.0,
                            ),
                            trailing: Column(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.delete_forever,
                                    color: Colors.red,
                                    size:24.0,),
                                    onPressed: () => {
                              deleteContact(
                                          context, documentos[index], index)
                                    })
                              ],
                            ),
                            onTap: () => {
                            modifyContanct(
                              _scaffoldKey.currentContext ,
                                  Contact(
                                      items[index].id,
                                      items[index].nome,
                                      items[index].conta,
                                      items[index].agencia,
                            items[index].banco )
                            )
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
        child: Icon(Icons.group_add),
        onPressed: () => newContact(context),
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
                icon: Icon(Icons.sticky_note_2),
                color: Colors.indigo,
                iconSize: 50.0,
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TransferList(),
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
    return FirebaseFirestore.instance.collection("contactlist").snapshots();
  }

}
