import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/spent_model.dart';
import 'package:problembank/screen/dashboard.dart';
import 'package:problembank/screen/transfer_list.dart';

import 'contact_list.dart';

class SpentList extends StatefulWidget {
  @override
  _SpentListState createState() => _SpentListState();
}

class _SpentListState extends State<SpentList> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  TextEditingController _ncontroller;
  TextEditingController _vcontroller;

  List<Spent> items;

  var db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot> spents;

  @override
  void initState() {
    super.initState();
    items = List();
    spents?.cancel();
    spents = db.collection("spendinglist").snapshots().listen((snapshot) {
      final List<Spent> spent = snapshot.docs
          .map((documentSnapshot) =>
              Spent.fromMap(documentSnapshot.data(), documentSnapshot.id))
          .toList();
      setState(() {
        this.items = spent;
      });
    });
  }

  @override
  void dispose() {
    spents?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Gastos'),
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
                              Icons.monetization_on,
                              color: Colors.indigo,
                              size: 42.0
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.delete_forever,
                                    color: Colors.red,
                                    size: 24.0),
                                    onPressed: () => {
                                      deleteTransfer(
                                          context, documentos[index], index)
                                    }),
                              ],
                            ),
                            onTap: () => {
                              modifyContact(
                                context,
                                Spent(
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
        child: Icon(Icons.add),
        onPressed: () => newTransfer(),
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
                    icon: Icon(Icons.contact_page),
                    color: Colors.indigo,
                    iconSize: 50.0,
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ContactList(),
                      ));
                    }
                )
              ]
          )
      ),
    );
  }

  Stream<QuerySnapshot> getContactsList() {
    return FirebaseFirestore.instance.collection("spendinglist").snapshots();
  }

  void newTransfer() {

    String nomeCidade="";
    var cidades =['Santos','Porto Alegre','Campinas','Rio de Janeiro'];
    var itemSelecionado = 'Santos';

    Widget createButton = FlatButton(
      child: Text("Adicionar"),
      onPressed: () => createTransfer(
          context,
          Spent(
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
                hintText: 'Nome do Produto',
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

  void createTransfer(BuildContext context, Spent spent) async {
    await db.collection("spendinglist").doc(spent.id).set({
      "nome": spent.nome,
      "valor": spent.valor,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }

  void deleteTransfer(
      BuildContext context, DocumentSnapshot doc, int posicao) async {
    await db.collection("spendinglist").doc(doc.id).delete();
    setState(() {
      items.removeAt(posicao);
      Navigator.of(context).pop();
    });
  }

  void changeContact(BuildContext context, Spent spent) async {
    await db.collection("spendinglist").doc(spent.id).set({
      "nome": spent.nome,
      "valor": spent.valor,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }

  void modifyContact(BuildContext context, Spent spent) {
    _ncontroller = new TextEditingController(text: spent.nome);
    _vcontroller = new TextEditingController(text: spent.valor);

    Widget modifyButton = FlatButton(
        child: Text("Salvar"),
        onPressed: () => changeContact(
              context,
              Spent(
                spent.id,
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
      title: Text("Alterar Produto"),
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
                hintText: 'Nome do Produto',
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
