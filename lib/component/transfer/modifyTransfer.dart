import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/transfer_model.dart';

class modifyTransfer{

  TextEditingController _ncontroller;
  TextEditingController _vcontroller;

  var db = FirebaseFirestore.instance;

  void changeTransfer(BuildContext context, Transfer transfer) async {
    await db.collection("transferlist").doc(transfer.id).set({
      "nome": transfer.nome,
      "valor": transfer.valor,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }

  modifyTransfer(BuildContext context, Transfer transfer) {
    _ncontroller = new TextEditingController(text: transfer.nome);
    _vcontroller = new TextEditingController(text: transfer.valor);

    Widget modifyButton = FlatButton(
        child: Text("Salvar"),
        onPressed: () => changeTransfer(
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