class Spent {
  String _id;
  String _nome;
  String _valor;

  Spent(this._id, this._nome, this._valor);

  Spent.map(dynamic obj) {
    this._id = obj['id'];
    this._nome = obj['nome'];
    this._valor = obj['valor'];
  }

  Spent.fromMap(Map<String, dynamic> map, String id) {
    this._id = id ?? '';
    this._nome = map["nome"];
    this._valor = map["valor"];
  }

  String get id => _id;
  String get nome => _nome;
  String get valor => _valor;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map["nome"] = _nome;
    map["valor"] = _valor;
    return map;
  }
}
