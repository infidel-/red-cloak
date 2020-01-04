// adventure state

import infos.AdventureInfo;

class Adventure
{
  public var game: Game;
  public var info: AdventureInfo;

  public function new(g: Game, info: AdventureInfo)
    {
      game = g;
      this.info = info;
    }


// prints known conversation topics
  public function printKnownTopics()
    {
      var s = new StringBuf();
      s.add('Known topics: ');
      for (ch in game.adventure.info.topics)
        if (ch.isKnown)
          s.add(ch.name + ', ');
      var msg = s.toString();
      msg = msg.substr(0, msg.length - 2);
      game.console.print(msg);
    }


// get known topic info
  public function getKnownTopic(name: String)
    {
      var topic = null;
      for (t in game.adventure.info.topics)
        if (t.isKnown && Lambda.has(t.names, name))
          return t;

      return null;
    }
}
