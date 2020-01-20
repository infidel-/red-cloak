// scene dynamic state

class Scene
{
  public var game: Game;
  public var console: Console;
  public var location: Location;
  public var locations: Array<Location>;
  public var startingLocation: Location;
  public var npcs: Array<NPC>;
  public var clues: Int;
  public var cluesFailed: Int;
  public var cluesTotal: Int;

  public function new(g: Game)
    {
      game = g;
      location = null;
      locations = [];
      npcs = [];
      console = game.console;
      clues = 0;
      cluesFailed = 0;
      cluesTotal = 0;
    }


// enter scene
  public function enter()
    {
      // init scene locations default values
      for (l in locations)
        for (o in l.objects)
          {
            if (o.state == null)
              o.state = 0;
            if (o.isEnabled == null)
              o.isEnabled = true;
          }

      location = this.startingLocation;
      game.state = STATE_LOCATION;
      printLocation();
    }


// move to location by id
  public function moveTo(id: String)
    {
      for (l in locations)
        if (l.id == id)
          {
            location = l;
            printLocation();
            return;
          }
    }


// print current location info
  public function printLocation()
    {
      console.print('**' + location.name + '**\n' +
        location.note);
      var s = new StringBuf();
      for (o in location.objects)
        if (o.isEnabled && o.locationNote != null)
          {
            s.add(o.locationNote);
            s.add(' ');
          }
      if (s.length > 0)
        console.print(s.toString());
    }


// get object info by its name
  public function getEnabledObject(name: String): ObjectInfo
    {
      for (o in location.objects)
        if (o.isEnabled && Lambda.has(o.names, name))
          return o;
      return null;
    }


// get npc info by id
  public function getNPC(id: String): NPC
    {
      for (npc in npcs)
        if (npc.id == id)
          return npc;
      return null;
    }


// move player to a given location in the scene
  public function move(id: String)
    {
      var newloc = null;
      for (loc in locations)
        if (loc.id == id)
          {
            newloc = loc;
            break;
          }
      if (newloc == null)
        {
          game.console.error('No such location: ' + id + '.');
          return;
        }

      location = newloc;
      printLocation();
    }


  inline function print(s: String)
    {
      game.console.print(s);
    }


  inline function printFail(id: String)
    {
      game.console.printFail(id);
    }


  inline function printString(id: String)
    {
      game.console.printString(id);
    }
}
