import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:problembank/model/contact_model.dart';

class newContact {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _agenciaController = TextEditingController();
  final TextEditingController _contaController = TextEditingController();
  final TextEditingController _bancoController = TextEditingController();

  var db = FirebaseFirestore.instance;

  newContact(BuildContext context) {
    Widget createButton = FlatButton(
      child: Text("Adicionar"),
      onPressed: () => createContact(
          context,
          Contact(null, _nomeController.text, _contaController.text,
              _agenciaController.text, _bancoController.text)),
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
          height: 400,
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
                controller: _bancoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo)),
                  hintText: 'Nome do Banco',
                  labelText: 'Banco',
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

  createContact(BuildContext context, Contact contact) async {
    await db.collection("contactlist").doc(contact.id).set({
      "nome": contact.nome,
      "conta": contact.conta,
      "agencia": contact.agencia,
      "banco": contact.banco,
    });

    _nomeController.text = '';
    _contaController.text = '';
    _agenciaController.text = '';
    _bancoController.text = '';

    Navigator.of(context).pop();
    SystemChannels.textInput.invokeListMethod('TextInput.hide');
  }
}


