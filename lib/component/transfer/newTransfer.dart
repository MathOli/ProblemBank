import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/transfer_model.dart';

class newTransfer{

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  var db = FirebaseFirestore.instance;

  newTransfer(BuildContext context) {
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
}