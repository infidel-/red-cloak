// adventure state

import infos.AdventureInfo;

class Adventure
{
  public var game: Game;
  public var info: AdventureInfo;
  var knownClues: Array<String>;

  public function new(g: Game, info: AdventureInfo)
    {
      game = g;
      this.info = info;
      this.knownClues = [];
    }


// prints known conversation topics
  public function printKnownTopics()
    {
      var s = new StringBuf();
      s.add('Known special topics: ');
      for (ch in info.topics)
        if (ch.isKnown)
          s.add(ch.name + ', ');
      var msg = s.toString();
      msg = msg.substr(0, msg.length - 2);
      game.console.print(msg);
    }


// get known topic info
  public function getKnownTopic(name: String): _ChatSpecialTopicInfo
    {
      var topic = null;
      for (t in info.topics)
        if (t.isKnown && Lambda.has(t.names, name))
          return t;

      return null;
    }


// get topic info by id
  public function getByID(id: String): _ChatSpecialTopicInfo
    {
      var topic = null;
      for (t in info.topics)
        if (t.id == id)
          return t;

      return null;
    }


// prints known clues
  public function printKnownClues()
    {
      var s = new StringBuf();
      if (knownClues.length == 0)
        {
          s.add('You do not know any clues yet.\n');
        }

      else
        {
          s.add('Known clues:\n');
          for (c in knownClues)
            s.add(info.clues[c] + '\n');
        }

      // clues count (only when on scene)
      if (game.state != STATE_MAP && game.scene.cluesTotal > 0)
        {
          s.add('\nThere are ' +
            (game.scene.cluesTotal - game.scene.clues -
             game.scene.cluesFailed) + '/' + game.scene.cluesTotal +
            ' clues left on this scene');
          if (game.scene.cluesFailed > 0)
            s.add(' (' + game.scene.cluesFailed + ' failed).');
          else s.add('.');
        }

      game.console.print(s.toString());
    }


// gain adventure clue
  public function gainClue(id: String)
    {
      if (info.clues[id] == null)
        throw 'No such clue: ' + id;

      knownClues.push(id);

      game.console.system('[You have gained a clue.]');
      if (game.state != STATE_MAP)
        game.scene.clues++;
    }


// fail gaining adventure clue
  public function failClue(id: String)
    {
      game.console.system('[You have failed to gain a clue.]');
      if (game.state != STATE_MAP)
        game.scene.cluesFailed++;
    }
}
