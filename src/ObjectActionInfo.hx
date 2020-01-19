// scene object action info

typedef ObjectActionInfo = {
  var names: Array<String>;
  @:optional var note: String;
  @:optional var result: ActionResultInfo;
  @:optional var func: ObjectInfo -> Void;
}
