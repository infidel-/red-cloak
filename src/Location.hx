// scene location info

@:structInit class Location
{
  public var id: String;
  public var game: Game;
  public var name: String;
  public var note: String;
  public var objects: Array<ObjectInfo>;

  public function new(id: String,
      game: Game,
      name: String,
      note: String,
      objects: Array<ObjectInfo>)
    {
      this.id = id;
      this.game = game;
      this.name = name;
      this.note = note;
      this.objects = objects;
    }


// runs a console command on this location
// 0 - error, show standard error message
// 1 - success
// -1 - error, skip standard error message
  public function runCommand(cmd: String, tokens: Array<String>): Int
    {
      // we need at least 2 tokens: command and object
      if (tokens.length < 1)
        return 0;

      // find object with this name
      var obj = game.scene.getObject(tokens[0]);
      if (obj == null || obj.actions == null)
        return 0;
      
      // check if this object has this action
      var action = null;
      for (a in obj.actions)
        if (Lambda.has(a.names, cmd))
          {
            action = a;
            break;
          }
      if (action == null)
        return 0;

      if (action.note != null)
        game.console.print(action.note);
      if (action.func != null)
        action.func(obj);
      if (action.result != null)
        return handleActionResult(action.result);

      return 1;
    }


// helper: handle action result
  public function handleActionResult(result: ActionResultInfo): Int
    {
      // start a new chat
      if (result.type == RESULT_CHAT)
        {
          var npc = game.scene.getNPC(result.info);
          if (npc == null)
            {
              game.console.error('No such NPC found: ' + result.info + '.');
              return -1;
            }

          return npc.startChat();
        }

      // finish chat: success
      else if (result.type == RESULT_CHAT_FINISH_SUCCESS)
        {
          game.npc.finishChat(true);
        }

      else game.console.error('No result handler for ' + result);
      return 1;
    }

  public static var commandHelp = [
    'examine' => 'examine, x, look, l <object> - Examines the given object. If no object is given, describes the scene.',
    'look' => 'examine, x, look, l <object> - Examines the given object. If no object is given, describes the scene.',
  ];
}
