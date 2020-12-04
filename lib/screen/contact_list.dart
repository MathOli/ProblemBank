import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/contact_model.dart';
import 'package:problembank/enum/choice.dart';

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _agenciaController = TextEditingController();
  final TextEditingController _contaController = TextEditingController();

  TextEditingController _ncontroller;
  TextEditingController _ccontroller;
  TextEditingController _acontroller;

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
                      itemBuilder: (_, index) {
                        return Card(
                          child: ListTile(
                            title: Text(items[index].nome,
                                style: TextStyle(fontSize: 24)),
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
                              modifyContact(
                                  context,
                                  Contact(
                                      items[index].id,
                                      items[index].nome,
                                      items[index].conta,
                                      items[index].agencia)),
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
        onPressed: () => newContact(),
      ),
    );
  }

  Stream<QuerySnapshot> getContactsList() {
    return FirebaseFirestore.instance.collection("contactlist").snapshots();
  }

  void deleteContact(
      BuildContext context, DocumentSnapshot doc, int posicao) async {
    db.collection("contactlist").doc(doc.id).delete();
    setState(() {
      items.removeAt(posicao);
    });
  }

  void newContact() {
    Widget createButton = FlatButton(
      child: Text("Adicionar"),
      onPressed: () => createContact(
          context,
          Contact(null, _nomeController.text, _contaController.text,
              _agenciaController.text)),
    );

    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text("Novo Contato"),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: 500,
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo)),
                  hintText: 'Nome da pessoa',
                  labelText: 'Nome',
                  counterText: "",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              TextField(
                controller: _agenciaController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo)),
                  hintText: '0000',
                  labelText: 'Agencia',
                  counterText: "",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _contaController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo)),
                  hintText: '00000-0',
                  labelText: 'Conta',
                  counterText: "",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        createButton,
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

  void createContact(BuildContext context, Contact contact) async {
    await db.collection("contactlist").doc(contact.id).set({
      "nome": contact.nome,
      "conta": contact.conta,
      "agencia": contact.agencia,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }

  void changeContact(BuildContext context, Contact contact) async {
    await db.collection("contactlist").doc(contact.id).set({
      "nome": contact.nome,
      "conta": contact.conta,
      "agencia": contact.agencia,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }

  void modifyContact(BuildContext context, Contact contact) {
    _ncontroller = new TextEditingController(text: contact.nome);
    _ccontroller = new TextEditingController(text: contact.conta);
    _acontroller = new TextEditingController(text: contact.agencia);

    Widget modifyButton = FlatButton(
        child: Text("Salvar"),
        onPressed: () => changeContact(
              context,
              Contact(contact.id, _ncontroller.text, _ccontroller.text,
                  _acontroller.text),
            ));

    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text("Alterar Contato"),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: 500,
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _ncontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo)),
                  hintText: 'Nome da pessoa',
                  labelText: 'Nome',
                  counterText: "",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
                enableSuggestions: false,
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: _acontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo)),
                  hintText: '0000',
                  labelText: 'Agencia',
                  counterText: "",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _ccontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo)),
                  hintText: '00000-0',
                  labelText: 'Conta',
                  counterText: "",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        modifyButton,
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

}
