// scene dynamic state

class Scene
{
  public var game: Game;
  public var console: Console;
  public var location: Location;
  public var locations: Array<Location>;
  public var startingLocation: Location;
  public var npcs: Array<NPC>;

  public function new(g: Game)
    {
      game = g;
      location = null;
      locations = [];
      npcs = [];
      console = game.console;
    }


// enter scene
  public function enter()
    {
      location = this.startingLocation;
      game.state = STATE_LOCATION;
      printLocation();
    }


// print current location info
  public function printLocation()
    {
      console.print('**' + location.name + '**\n' +
        location.note);
      for (o in location.objects)
        if (o.isKnown && o.locationNote != null)
          console.print(o.locationNote);
    }


// get object info by its name
  public function getObject(name: String): ObjectInfo
    {
      for (o in location.objects)
        if (o.isKnown && Lambda.has(o.names, name))
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
}
