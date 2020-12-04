import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/transfer_model.dart';

class TransferList extends StatefulWidget {
  @override
  _TransferListState createState() => _TransferListState();
}

class _TransferListState extends State<TransferList> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  TextEditingController _ncontroller;
  TextEditingController _vcontroller;

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
                              modifyContact(
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
        onPressed: () => newTransfer(),
      ),
    );
  }

  Stream<QuerySnapshot> getContactsList() {
    return FirebaseFirestore.instance.collection("transferlist").snapshots();
  }

  void newTransfer() {
    Widget createButton = FlatButton(
      child: Text("Adicionar"),
      onPressed: () => createTransfer(
          context,
          Transfer(
            null,
            _nomeController.text,
            _valorController.text,
          )),
    );

    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text("Nova Transferencia"),
      content: Container(
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
                hintText: 'Nome da Pessoa',
                labelText: 'Nome',
                counterText: "",
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            TextField(
              controller: _valorController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo)),
                hintText: '000.00',
                labelText: 'Valor',
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

  void createTransfer(BuildContext context, Transfer transfer) async {
    await db.collection("transferlist").doc(transfer.id).set({
      "nome": transfer.nome,
      "valor": transfer.valor,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }

  void deleteTransfer(
      BuildContext context, DocumentSnapshot doc, int posicao) async {
    await db.collection("transferlist").doc(doc.id).delete();
    setState(() {
      items.removeAt(posicao);
      Navigator.of(context).pop();
    });
  }

  void changeContact(BuildContext context, Transfer transfer) async {
    await db.collection("transferlist").doc(transfer.id).set({
      "nome": transfer.nome,
      "valor": transfer.valor,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }

  void modifyContact(BuildContext context, Transfer transfer) {
    _ncontroller = new TextEditingController(text: transfer.nome);
    _vcontroller = new TextEditingController(text: transfer.valor);

    Widget modifyButton = FlatButton(
        child: Text("Salvar"),
        onPressed: () => changeContact(
              context,
              Transfer(
                transfer.id,
                _ncontroller.text,
                _vcontroller.text,
              ),
            ));

    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text("Alterar Transferencia"),
      content: Container(
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
                hintText: 'Nome da Pessoa',
                labelText: 'Nome',
                counterText: "",
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            TextField(
              controller: _vcontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo)),
                hintText: '000.00',
                labelText: 'Valor',
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
