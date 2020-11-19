class Contact {
  String _id;
  String _nome;
  String _conta;
  String _agencia;
  Contact(this._id, this._nome, this._conta, this._agencia);

  Contact.map(dynamic obj) {
    this._id = obj['id'];
    this._nome = obj['nome'];
    this._conta = obj['conta'];
    this._agencia = obj['agencia'];
  }
  Contact.fromMap(Map<String, dynamic> map, String id) {
    this._id = id ?? '';
    this._nome = map["nome"];
    this._conta = map["conta"];
    this._agencia = map["agencia"];
  }

  String get id => _id;
  String get nome => _nome;
  String get conta => _conta;
  String get agencia => _agencia;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map["nome"] = _nome;
    map["conta"] = _conta;
    map["agencia"] = this._agencia;
    return map;
  }
}
