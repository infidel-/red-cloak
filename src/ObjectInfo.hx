// scene location object info

typedef ObjectInfo = {
  var id: String;
  @:optional var state: Int; // generic object state counter (default 0)
  var names: Array<String>;
  @:optional var locationNote: String;
  @:optional var note: String;
  @:optional var actions: Array<ObjectActionInfo>;
  @:optional var isEnabled: Bool;
}
