// scene object action info

typedef ObjectActionInfo = {
  var names: Array<String>;
  @:optional var note: String;
  @:optional var roll: String; // action is also accessible with roll cmd
  @:optional var result: ActionResultInfo;
  @:optional var func: ObjectInfo -> Void;
}
