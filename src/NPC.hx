// NPC state and info

class NPC
{
  var game: Game;
  var scene: Scene;

  // stats and attributes
  public var id: String;
  public var name: String;
  public var disposition(default, set): Int;
  public var interest(default, set): Int;
  public var evalTimer: Int;

  // chat-related data
  var chatSkills: Array<ChatSkill>;
  var chatTopics: Array<ChatTopic>;
  var chatTopicUnknown: String;
  var hints: Array<ChatHint>;

  public function new(g: Game, s: Scene)
    {
      game = g;
      scene = s;
      id = '?';
      name = '?';
      chatSkills = null;
      chatTopics = null;
      chatTopicUnknown = null;
      hints = null;
    }


// OVERRIDE: pre-start settings and check
  function startChatPre(): Bool
    { return true; }

// OVERRIDE: turn callback
  function turnPre()
    {}

// OVERRIDE: finish chat with success
  function finishChatSuccess()
    {}

// OVERRIDE: finish chat with failure
  function finishChatFail()
    {}


// start char with this NPC
  public function startChat(): Int
    {
      if (!startChatPre())
        return -1;

      game.state = STATE_CHAT;
      game.npc = this;
      evalTimer = 0;
      print('You have started a conversation with ' + name + '.');
      if (hints == null) // only init on the first attempt
        initHints();
      printState();

      return 1;
    }


// chat commands
  public function runCommand(cmd: String, tokens: Array<String>): Int
    {
      // help
      var ret = 0;

      // chat (roll fast-talk, gain hints, raise disposition)
      if (cmd == 'chat' || cmd == 'c')
        {
          var res = game.player.roll('charisma');
          if (res == ROLL_SUCCESS || res == ROLL_CRIT)
            {
              var rnd = [
                'You make small talk with ' + name + '.',
                'You converse with ' + name + '.',
                'You chat with ' + name + ' about trivialities.',
              ];
              print(rnd[Std.random(rnd.length)]);
              disposition += 15;
              gainHints();
            }
          else
            {
              var rnd = [
                'You did not manage to make the conversation going.',
                'You try to talk with ' + name + ' casually but fail.',
              ];
              print(rnd[Std.random(rnd.length)]);
            }
          ret = 1;
        }

      // discuss
      else if (cmd == 'discuss' || cmd == 'd')
        {
          // list known topics
          if (tokens.length < 1)
            {
              game.adventure.printKnownTopics();
              return 1;
            }

          // check if topic is known
          var topic = game.adventure.getKnownTopic(tokens[0]);
          if (topic == null)
            {
              game.console.system('I have no idea who or what that is.');
              return 1;
            }
          var chatTopic = null;
          for (t in chatTopics)
            if (t.id == topic.id)
              {
                chatTopic = t;
                break;
              }
          if (chatTopic == null)
            {
              if (chatTopicUnknown != null)
                print(chatTopicUnknown);
              else print('You spend some time discussing ' + topic.name +
                'with ' + name + '. It does not appear that they\'re interested.');
              return 1;
            }

          // handle topic
          handleTopic(topic, chatTopic);

          ret = 1;
        }

      // evaluate (roll psychology and show correct convo state)
      else if (cmd == 'evaluate' || cmd == 'eval' || cmd == 'e')
        {
          var res = game.player.roll('psychology');
          if (res == ROLL_SUCCESS || res == ROLL_CRIT)
            {
              var rnd = [
                'You appraise the emotional state of ' + name + '.',
                'You assess the mood of ' + name + '.',
              ];
              print(rnd[Std.random(rnd.length)]);
              evalTimer += 3;
            }
          else
            {
              var rnd = [
                'You cannot quite grasp what ' + name + ' is thinking.',
                'It is hard to figure out what ' + name + ' is all about.',
                'It looks like interpreting the mood of ' + name + ' is beyond your capabilities.',
              ];
              print(rnd[Std.random(rnd.length)]);
            }
          ret = 1;
        }

      // probe (roll fast talk, gain hints, raise interest)
      else if (cmd == 'probe' || cmd == 'p')
        {
          var res = game.player.roll('fastTalk');
          if (res == ROLL_SUCCESS || res == ROLL_CRIT)
            {
              var rnd = [
                'You discuss some topics in-depth with ' + name + '.',
                'You argue with ' + name + ' about some subjects.',
              ];
              print(rnd[Std.random(rnd.length)]);
              interest += 15;
              gainHints();
            }
          else
            {
              var rnd = [
                'You put out some feelers but ' + name + ' is not biting.',
                'It looks like ' + name + ' is not that interested in that subject matter.',
                'You try debating about some matters but ' + name + ' does not have an opinion.',
              ];
              print(rnd[Std.random(rnd.length)]);
            }
          ret = 1;
        }

      // examine surroundings
      else if (Lambda.has([ 'look', 'l', 'examine', 'x' ], cmd))
        {
          print("TODO");
          ret = 1;
        }

      // roll a skill
      else if (cmd == 'roll' || cmd == 'r')
        {
          // find skill by name
          var skill = SkillConst.getByName(tokens[0]);
          if (skill == null)
            {
              print('No such skill found.');
              return -1;
            }
          var playerSkill = game.player.skills[skill.id];
          if (playerSkill.val == 0)
            {
              print('You do not have this skill.');
              return -1;
            }

          // check if this skill is available in this chat
          var chatSkill = null;
          for (ch in chatSkills)
            if (ch.id == skill.id)
              {
                chatSkill = ch;
                break;
              }
          if (chatSkill == null)
            {
              print('This skill is useless here.');
              ret = 1;
            }
          else
            {
              var roll = game.player.roll(skill.id);
              if (roll == ROLL_CRIT || roll == ROLL_SUCCESS)
                {
                  if (chatSkill.print != null)
                    print(chatSkill.print);
                  if (chatSkill.say != null)
                    say(chatSkill.say);
                  scene.location.handleActionResult(chatSkill.result);
                }
              else
                {
                  // find hint
                  for (hint in hints)
                    if (hint.type == HINT_SKILL && hint.id == skill.id)
                      {
                        hint.stage = 4;
                        updateHintText(hint);
                        break;
                      }
                }
              ret = 1;
            }
        }

      // no appropriate command found
      else return 0;

      // new turn
      // chat could finish as a result of command
      if (ret == 1 && game.state == STATE_CHAT)
        {
          // callback
          turnPre();

          // check for finish
          if (interest <= 0)
            {
              finishChat(false);
              return 1;
            }

          printState();

          if (evalTimer > 0)
            evalTimer--;
//          game.console.debug('' + evalTimer);
        }

      return ret;
    }


// handle conversation topic discussion
  function handleTopic(topic, chatTopic: ChatTopic)
    {

    }


// initialize hints state
  function initHints()
    {
      hints = [];

      // add skills
      for (skill in chatSkills)
        hints.push({
          type: HINT_SKILL,
          text: '',
          id: skill.id,
          knownLetters: [],
          fullText: SkillConst.getByID(skill.id).name,
          stage: 0,
        });
    }


// gain some amount of hints
  public function gainHints()
    {
      // example for skill persuade
      // 0: -
      // 1: [?]
      // 2: [?e*]
      // 3: [Skill ?e*]
      // 4: [Skill Persuade]

      for (hint in hints)
        {
          // 0: [?]
          if (hint.stage == 0)
            hint.stage = 1;

          // 1: [?]
          else if (hint.stage == 1)
            {
              hint.stage = 2;
              openHintLetter(hint);
            }

          // 2: [?e*]
          else if (hint.stage == 2)
            {
              if (Std.random(100) < 75)
                hint.stage = 3;
              openHintLetter(hint);
            }

          // 3: [Skill ?e*]
          else if (hint.stage == 3)
            openHintLetter(hint);
        }
    }


// open another hint letter
  function openHintLetter(hint: ChatHint)
    {
      // all text known
      if (hint.stage == 4 ||
          hint.knownLetters.length >= hint.fullText.length)
        return;

      var idx = Std.random(hint.fullText.length);
      hint.knownLetters.push(idx);

      updateHintText(hint);
    }
    

// update hint text
  function updateHintText(hint: ChatHint)
    {
      // 4: full text known
      if (hint.stage == 4)
        {
          hint.text = hint.fullText;
          return;
        }

      // update text
      var text = [];
      for (idx in hint.knownLetters)
        text[idx] = hint.fullText.charAt(idx);
      for (i in 0...text.length)
        if (text[i] == null)
          text[i] = '?';
      hint.text = text.join('');
      if (hint.text.length < hint.fullText.length)
        hint.text += '+';
//      print('' + hint);
    }


// finish chat
  public function finishChat(success: Bool)
    {
      if (success)
        finishChatSuccess();
      else finishChatFail();

      game.state = STATE_LOCATION;
      game.npc = null;
    }


// print chat state
  function printState()
    {
      var s = ''; //'You are talking with ' + name + '.\n';
      if (evalTimer > 0)
        s = 'Disposition: ' + disposition + '/100, ' +
          'Interest: ' + interest + '/100\n';
      var sb = new StringBuf();
      for (hint in hints)
        {
          // 0: -
          if (hint.stage == 0)
            continue;
          // 1: [?]
          else if (hint.stage == 1)
            {
              sb.add('[?] ');
              continue;
            }
          
          sb.add('[');
          // 3+: [Skill ?e*]
          if (hint.stage >= 3)
            {
              if (hint.type == HINT_SKILL)
                sb.add('Skill ');
              else if (hint.type == HINT_TOPIC)
                sb.add('Topic ');
              else if (hint.type == HINT_ITEM)
                sb.add('Item ');
            }

          // 2: [?e*]
          // 3: [Skill ?e*]
          // 4: [Skill Persuade]
          sb.add(hint.text);
          sb.add('] ');
        }
      if (sb.length > 0)
        s += 'Hints: ' + sb;
      print(s);
    }


// NPC says something
  inline function say(s: String)
    {
      game.console.print('*"' + s + '"*');
    }


// print shortcut
  inline function print(s: String)
    {
      if (s.charAt(0) == '"')
        game.console.print('*' + s + '*');
      else game.console.print(s);
    }


// get disposition
  function get_disposition()
    {
      return disposition;
    }

// set disposition
  function set_disposition(v: Int)
    {
      disposition = v;
//      game.console.debug('Disposition: ' + disposition);
      return v;
    }

// get interest
  function get_interest()
    {
      return interest;
    }

// set interest
  function set_interest(v: Int)
    {
      interest = v;
//      game.console.debug('Interest: ' + interest);
      return v;
    }


  public static var commandHelp = [
    'again' => 'again, g - Repeats previous command again.',
    'chat' => 'chat, c - (Roll Charisma) Make small talk to the character. Raises character disposition and gives some hints.',
    'discuss' => 'discuss, d <topic> - Discuss this topic in conversation.',
    'evaluate' => 'evaluate, eval, e - (Roll Psychology) Assess the emotional state of the character. Shows detailed information for the next three turns.',
    'examine' => 'examine, x, look, l - (Roll Spot Hidden) Examines the NPC and surroundings, giving some hints.',
    'look' => 'examine, x, look, l - (Roll Spot Hidden) Examines the NPC and surroundings, giving some hints.',
    'probe' => 'probe, p - (Roll Fast Talk) Converse about some general topics in-depth with the character. Raises character interest and gives some hints.',
    'roll' => 'roll, r <skill> - Makes a roll for a given skill.',
    'topic' => 'topics, topic <topic> - Prints information about a known conversation topic. If the name is not given, lists known topics.',
    'topics' => 'topics, topic <topic> - Prints information about a known conversation topic. If the name is not given, lists known topics.',
    'who' => 'who <name> - Prints information about a non-player character.',
  ];
}


typedef ChatSkill = {
  var id: String;
  @:optional var print: String;
  @:optional var say: String;
  var result: ActionResultInfo;
}


typedef ChatTopic = {
  var id: String;
  var stages: Array<{
    var say: String;
    @:optional var result: ActionResultInfo;
  }>;
  @:optional var print: String;
  @:optional var say: String;
  @:optional var result: ActionResultInfo;
}


typedef ChatHint = {
  public var type: ChatHintType;
  public var id: String;
  public var text: String;
  public var knownLetters: Array<Int>;
  public var fullText: String;
  // example for skill persuade
  // 0: -
  // 1: [?]
  // 2: [?e*]
  // 3: [Skill ?e*]
  // 4: [Skill Persuade]
  public var stage: Int;
}


enum ChatHintType {
  HINT_SKILL;
  HINT_TOPIC;
  HINT_ITEM;
}
