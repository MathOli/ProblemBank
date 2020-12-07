import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/spent_model.dart';

class changeSpent{

  TextEditingController _ncontroller;
  TextEditingController _vcontroller;

  var db = FirebaseFirestore.instance;

  modifySpentE(BuildContext context, Spent spent) {
    _ncontroller = new TextEditingController(text: spent.nome);
    _vcontroller = new TextEditingController(text: spent.valor);

    Widget modifyButton = FlatButton(
        child: Text("Salvar"),
        onPressed: () => changeSpent(
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

  changeSpent(BuildContext context, Spent spent) {
    db.collection("spendinglist").doc(spent.id).set({
      "nome": spent.nome,
      "valor": spent.valor,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }
}