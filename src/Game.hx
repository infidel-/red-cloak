class Game
{
  public var console: Console;
  public var adventure: Adventure;
  public var scene: Scene;
  public var npc: NPC;
  public var player: Player;
  public var state(get, set): _GameState;
  var _state: _GameState;

  public function new()
    {
      _state = STATE_MAP;
      npc = null;
      player = new Player(this, {
        str: Const.dice(3,6),
        con: Const.dice(3,6),
        dex: Const.dice(3,6),
        siz: 6 + Const.dice(2,6),
        int: 6 + Const.dice(2,6),
        pow: Const.dice(3,6),
//        cha: Const.dice(3,6),
        cha: 6 + Const.dice(2,6),
        edu: 3 + Const.dice(3,6),
      });
      console = new Console(this);

      // temp character
      player.skills['psychology'].val += (3 + Std.random(3)) * 10;
      player.skills['fastTalk'].val += 40;

      // temp start
      console.print('### Welcome to CthulhuRPG DEMO.');
      console.print("<span style='color:#50f0d0'>*Both the mask and the magician are missing and the curator is keen on finding the former. Hopefully, these two events are related. The magician's house might hold some answers.*</span>");
      adventure = new Adventure(this, new infos.AdventureInfo(this));
      scene = new infos.ThorstonHouse(this);
      console.runCommand('stats');
      scene.enter();
    }


// get state
  function get_state()
    {
      return _state;
    }

// set state
  function set_state(st: _GameState)
    {
      _state = st;
      console.debug('Game state: ' + _state);
      return st;
    }


  static var inst: Game;
  static function main()
    {
      inst = new Game();
    }
}