import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/contact_model.dart';

class modifyContanct {
  TextEditingController _ncontroller;
  TextEditingController _ccontroller;
  TextEditingController _acontroller;
  TextEditingController _bcontroller;

  var db = FirebaseFirestore.instance;

  modifyContanct(BuildContext context, Contact contact) {
    _ncontroller = new TextEditingController(text: contact.nome);
    _ccontroller = new TextEditingController(text: contact.conta);
    _acontroller = new TextEditingController(text: contact.agencia);
    _bcontroller = new TextEditingController(text: contact.banco);

    Widget modifyButton = FlatButton(
        child: Text("Salvar"),
        onPressed: () =>
            changeContact(
              context,
              Contact(contact.id, _ncontroller.text, _ccontroller.text,
                  _acontroller.text, _bcontroller.text),
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
          height: 400,
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
              ),
              TextField(
                controller: _bcontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo)),
                  hintText: 'Nome do banco',
                  labelText: 'Banco',
                  counterText: "",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
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


  changeContact(BuildContext context, Contact contact) async {
    await db.collection("contactlist").doc(contact.id).set({
      "nome": contact.nome,
      "conta": contact.conta,
      "agencia": contact.agencia,
      "banco": contact.banco,
    });

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }
}
