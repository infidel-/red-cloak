// console functionality (excluding platform-specific UI)

class Console
{
  var game: Game;
  var _console: _Console;

  public function new(g: Game)
    {
      game = g;
      _console = new _Console(game);
    }


// run console command (called from platform-specific UI)
// 0 - error, show standard error message
// 1 - success
// -1 - error, skip standard error message
  public function runCommand(str: String): Int
    {
      // split command into tokens
      var tmp = str.split(' ');
      var tokens = [];
      for (x in tmp)
        if (!Lambda.has(Const.ignoredKeywords, x))
          tokens.push(x.toLowerCase());
//      trace(tokens);

      var cmd = tokens.shift();

      // try common commands first
      var ret = runCommandCommon(cmd, tokens);
      if (ret != 0)
        return ret;

      // state-specific commands
      if (game.state == STATE_LOCATION)
        return runCommandLocation(cmd, tokens);
      else if (game.state == STATE_CHAT)
        return game.npc.runCommand(cmd, tokens);

      return 0;
    }


// common commands
  function runCommandCommon(cmd: String, tokens: Array<String>): Int
    {
      // help
      if (cmd == 'help' || cmd == 'h' || cmd == '?')
        {
          if (tokens.length == 0)
            {
              var s = 'Commonly available commands: ' +
                'again (g), clues, skills/stats, topics/topic, who\n';
              if (game.state == STATE_LOCATION)
                s += 'Location commands: ' +
                  'enter, examine (x), exit, go, ' +
                  'look (l), roll (r), talk (t), use (u)';
              else if (game.state == STATE_CHAT)
                s += 'chat, evaluate (eval), ' +
                'examine (x), exit, ' +
                'look (l), probe (p), roll (r), topic, use (u)';
              system(s);
            }
          else
            {
              var text = commandHelp[tokens[0]];
              if (text != null)
                system(text);
              else system('There is no such command or no help available.');
            }
          return 1;
        }

      // repeat last command
      else if (cmd == 'again' || cmd == 'g')
        {
          // do not store repeat itself
          _console.removeLast();

          var command = _console.getLast();
          if (command != null)
            return runCommand(command);
        }

#if mydebug
      else if (cmd == 'debug' || cmd == 'dbg')
        return runDebugCommand(tokens);
#end

      // skills/stats
      else if (cmd == 'skills' || cmd == 'stats')
        {
          var sb = new StringBuf();
          var stats = game.player.stats;
          sb.add('<span class=consoleSys>STR ' + stats.str + ', ' +
            'CON ' + stats.con + ', ' +
            'DEX ' + stats.dex + ', ' +
            'SIZ ' + stats.siz + ', ' +
            'INT ' + stats.int + ', ' +
            'POW ' + stats.pow + ', ' +
            'CHA ' + stats.cha + ', ' +
            'EDU ' + stats.edu + '\n');
          sb.add('Skills: ');
          for (skill in game.player.skills)
            sb.add(skill.info.name + ' (' + skill.val + '%), ');
          var s = sb.toString();
          s = s.substr(0, s.length - 2);
          s += '</span>';
          print(s);
          return 1;
        }

      // topics
      else if (cmd == 'topics' || cmd == 'topic')
        {
          // list known topics
          if (tokens.length < 1)
            {
              var s = new StringBuf();
              s.add('Known topics: ');
              for (ch in game.adventure.info.topics)
                if (ch.isKnown)
                  s.add(ch.name + ', ');
              var msg = s.toString();
              msg = msg.substr(0, msg.length - 2);
              print(msg);
              return 1;
            }

          // check if topic is known
          var name = tokens[0];
          var topic = null;
          for (t in game.adventure.info.topics)
            if (t.isKnown && Lambda.has(t.names, name))
              {
                topic = t;
                break;
              }
          if (topic == null)
            {
              system('I have no idea who that is.');
              return 1;
            }
          print(topic.note);

          return 1;
        }

      // who
      else if (cmd == 'who')
        {
          // list known characters
          if (tokens.length < 1)
            {
              var s = new StringBuf();
              s.add('Known characters: ');
              for (ch in game.adventure.info.who)
                if (ch.isKnown)
                  s.add(ch.name + ', ');
              var msg = s.toString();
              msg = msg.substr(0, msg.length - 2);
              print(msg);
              return 1;
            }

          // check if char is known
          var name = tokens[0];
          var char = null;
          for (ch in game.adventure.info.who)
            if (ch.isKnown && Lambda.has(ch.names, name))
              {
                char = ch;
                break;
              }
          if (char == null)
            {
              system('I have no idea who that is.');
              return 1;
            }
          print(char.note);

          return 1;
        }

      return 0;
    }


// location commands
  function runCommandLocation(cmd: String, tokens: Array<String>): Int
    {
      // look/examine
      if (Lambda.has([ 'look', 'l', 'examine', 'x' ], cmd))
        {
          // examine location
          if (tokens.length < 1)
            {
              game.scene.printLocation();
              return 1;
            }

          // find referenced object
          var obj = game.scene.getObject(tokens[0]);
          if (obj == null)
            {
              system("I did not understand what that referred to.");
              return -1;
            }

          print(obj.note);
          return 1;
        }

      // location-specific commands
      else return game.scene.location.runCommand(cmd, tokens);

      return 0;
    }


#if mydebug
// debug command
  function runDebugCommand(tokens: Array<String>): Int
    {
      if (tokens.length == 0)
        {
          system('Debug commands:\n' +
            'skill [id/name] [val] - set skill value'
          );
          return 1;
        }
      var cmd = tokens[0];

      // debug skill <id/name> <val> - set skill value
      if (cmd == 'skill')
        {
          var id = tokens[1];
          var val = Std.parseInt(tokens[2]);
          var skill = SkillConst.getByName(id);
          if (skill == null)
            {
              system('No such skill.');
              return 0;
            }
          var playerSkill = game.player.skills[skill.id];
          playerSkill.val = val;
          system('[Skill ' + skill.name + ' set to ' + val + '.]');

          return 1;
        }

      return 0;
    }
#end


// print string
  public inline function print(s: String)
    {
      _console.print(s);
    }


// print debug string
  public inline function debug(s: String)
    {
      _console.debug(s);
    }


// print error string
  public inline function error(s: String)
    {
      _console.error(s);
    }


// print system string
  public inline function system(s: String)
    {
      _console.print('<span class=consoleSys>' + s + '</span>');
    }


// clear console
  public inline function clear()
    {
      _console.clear();
    }


  static var commandHelp = [
    'again' => 'again, g - Repeats previous command again.',
    'examine' => 'examine, x, look, l <object> - Examines the given object.',
    'look' => 'examine, x, look, l <object> - Examines the given object.',
    'roll' => 'roll, r <skill> - Makes a roll for a given skill.',
    'stats' => 'stats, skills - Lists player skills and stats.',
    'skills' => 'stats, skills - Lists player skills and stats.',
    'topic' => 'topics, topic <topic> - Prints information about a known conversation topic. If the name is not given, lists known topics.',
    'topics' => 'topics, topic <topic> - Prints information about a known conversation topic. If the name is not given, lists known topics.',
    'who' => 'who <name> - Prints information about a non-player character. If the name is not given, lists known characters.',
  ];
}