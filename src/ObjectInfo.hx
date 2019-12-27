// scene location object info

typedef ObjectInfo = {
  var id: String;
  var names: Array<String>;
  @:optional var locationNote: String;
  var note: String;
  @:optional var actions: Array<ObjectActionInfo>;
  var isKnown: Bool;
}
