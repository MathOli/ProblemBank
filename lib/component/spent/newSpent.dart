import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/spent_model.dart';

class newSpent{

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  var db = FirebaseFirestore.instance;

  newSpent(context) {

    Widget createButton = FlatButton(
      child: Text("Adicionar"),
      onPressed: () => createSpent(
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
      title: Text("Novo Gasto"),
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

  void createSpent(BuildContext context, Spent spent) async {
    await db.collection("spendinglist").doc(spent.id).set({
      "nome": spent.nome,
      "valor": spent.valor,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }
}