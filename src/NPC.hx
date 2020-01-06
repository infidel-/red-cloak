// NPC state and info

class NPC
{
  var game: Game;
  var scene: Scene;

  // stats and attributes
  public var id: String;
  public var name: String;
  public var nameUpper: String;
  public var anxiety(get, set): Int;
  var _anxiety: Int;
  public var rapport(get, set): Int;
  var _rapport: Int;
  public var evalTimer: Int;
  var chatMode: ChatMode;
  var chatState(get, set): ChatState;
  var _chatState: ChatState;
  var chatStateTimer: Int;

  // chat-related data
  var gender: Bool; // false - male, true - female
  var pronoun: String;
  var chatSkills: Array<ChatSkill>;
  var chatCommonTopics: Map<String, ChatCommonTopic>;
//  var chatTopics: Array<ChatTopic>;
  var chatTopicUnknown: String;
  var chatTopicNotInterested: String;
  var hints: Array<ChatHint>;

  public function new(g: Game, s: Scene)
    {
      game = g;
      scene = s;
      gender = false;
      pronoun = 'he';
      id = '?';
      name = '?';
      nameUpper = '?';
      _anxiety = 0;
      _rapport = 0;
      chatMode = CHAT_MODE_CAUTIOUS;
      _chatState = NPC_STATE_NORMAL;
      chatStateTimer = 0;
      chatSkills = null;
      chatCommonTopics = null;
//      chatTopics = null;
      chatTopicUnknown = null;
      chatTopicNotInterested = null;
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
      _anxiety = 0;
      _rapport = 0;

      if (!startChatPre())
        return -1;

      game.state = STATE_CHAT;
      game.npc = this;
      evalTimer = 0;
      chatStateTimer = 0;
      _chatState = NPC_STATE_NORMAL;
      print('You have started a conversation with ' + name + '.');
      if (hints == null) // only init on the first attempt
        initHints();
      printState();

      return 1;
    }


// chat commands
// 0 - error, show standard error message
// 1 - success, new conversation turn
// -1 - error, skip standard error message
  public function runCommand(cmd: String, tokens: Array<String>,
      tokensFull: Array<String>): Int
    {
      var ret = 0;

      // chat (roll fast-talk, gain hints, restore topic points)
      if (cmd == 'chat' || cmd == 'c')
        {
          ret = chatCommand();
        }

      // discuss
      else if (cmd == 'discuss' || cmd == 'd')
        {
          // list topics
          if (tokens.length < 1)
            {
              game.adventure.printKnownTopics();
              ChatConst.printCommonTopics(game);
              return 1;
            }

          // find topic record
          var topic = ChatConst.getCommonTopic(tokens[0]);
          if (topic == null)
            {
              game.console.system('I have no idea who or what that is.');
              return 1;
            }
          var chatTopic = chatCommonTopics[topic.id];
          if (chatTopic == null)
            {
              if (chatTopicNotInterested != null)
                print(chatTopicNotInterested);
              else print('You spend some time discussing ' + topic.name +
                'with ' + name + '. It does not appear that ' + pronoun +
                ' is interested.');
              ret = 1;
            }

          // handle topic
          else ret = discussCommonTopic(chatTopic, topic);
        }

      // evaluate (roll psychology and show correct convo state)
      else if (cmd == 'evaluate' || cmd == 'eval' || cmd == 'e')
        {
          var res = game.player.roll('psychology');
          if (res == ROLL_SUCCESS || res == ROLL_CRIT)
            {
              var rnd = [
                'You appraise the emotional state of ' + name + '.',
                'You expertly assess the mood of ' + name + '.',
              ];
              print(rnd[Std.random(rnd.length)]);
              evalTimer += 4;
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

      // mode (switch convo mode)
      else if (cmd == 'mode' || cmd == 'm')
        {
          // list modes
          if (tokensFull.length < 1)
            {
              print('Available modes are: cautious (c), intimate (i) and aggressive (a).');
              return 1;
            }

          // change mode and print it
          var modeStr = '';
          if (tokensFull[0] == 'cautious' || tokensFull[0] == 'c')
            {
              chatMode = CHAT_MODE_CAUTIOUS;
              modeStr = 'Cautious';
            }
          else if (tokensFull[0] == 'intimate' || tokensFull[0] == 'i')
            {
              chatMode = CHAT_MODE_INTIMATE;
              modeStr = 'Intimate';
            }
          else if (tokensFull[0] == 'aggressive' || tokensFull[0] == 'a')
            {
              chatMode = CHAT_MODE_AGGRESSIVE;
              modeStr = 'Aggressive';
            }
          else
            {
              print('No such mode.');
              return 1;
            }
          print('Mode: ' + modeStr);

          return 1;
        }

      // probe (roll fast talk, gain hints, open topic)
      else if (cmd == 'probe' || cmd == 'p')
        {
          // list topics
          if (tokens.length < 1)
            {
              ChatConst.printCommonTopics(game);
              return 1;
            }

          // find topic record
          var topic = ChatConst.getCommonTopic(tokens[0]);
          if (topic == null)
            {
              game.console.system('I have no idea what that is.');
              return 1;
            }
          var chatTopic = chatCommonTopics[topic.id];
          if (chatTopic == null)
            {
              if (chatTopicUnknown != null)
                print(chatTopicUnknown);
              else print('You spend some time probing ' + name +
                ' on ' + topic.nameLower +
                ' topic. It does not appear that they\'re interested.');
              return 1;
            }

          // check if already known
          var hint = getHint(HINT_TOPIC, topic.id);

          // roll skill
          var res = game.player.roll('fastTalk');
          var s = new StringBuf();
          s.add('You probe ' + name + ' on the topic of ' +
            topic.nameLower + '.');
          if (hint.stage < 4)
            {
              s.add(' It appears that ' + pronoun +
                (chatTopic.isFavorite ? ' loves' : ' hates') +
                ' talking about it.');

              // uncover topic
              hint.stage = 4;
              hint.text = hint.fullText;
            }
          print(s.toString());
          gainHints(res);

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
          if (anxiety > 100)
            {
              finishChat(false);
              return 1;
            }

          if (evalTimer > 0)
            evalTimer--;
          // DEBUG: evaluate timer always on
          if (game.debug.evaluate && evalTimer == 0)
            evalTimer = 1;
//          game.console.debug('' + evalTimer);

          // state return
          if (chatStateTimer > 0)
            {
              chatStateTimer--;
              if (chatStateTimer == 0)
                {
                  print(nameUpper + ' has somewhat calmed down.');
                  chatState = NPC_STATE_NORMAL;
                }
            }

          printState();
        }

      return ret;
    }


// chat (roll fast-talk, gain hints, restore topic points)
  function chatCommand(): Int
    {
      var res = game.player.roll('charisma');
      var rnd = [
        'You make small talk with ' + name + '.',
        'You converse with ' + name + '.',
        'You chat with ' + name + ' about trivialities.',
      ];
      print(rnd[Std.random(rnd.length)]);
      gainHints(res);

      // restore topic points on success
      if (res != ROLL_SUCCESS && res != ROLL_CRIT)
        return 1;

      // pick favorite or not
      var isFavorite = false;
      var rnd = Std.random(100);
      if ((chatState == NPC_STATE_NORMAL && rnd < 50) ||
          (chatState == NPC_STATE_CONFUSION && rnd < 50) ||
          (chatState == NPC_STATE_ENMITY && rnd < 20) ||
          (chatState == NPC_STATE_AGREEMENT && rnd < 80))
        isFavorite = true;

      // pick random topic of this type that does not have full points
      var tmp = [];
      for (t in chatCommonTopics)
        if (t.isFavorite == isFavorite && t.points < t.maxPoints)
          tmp.push(t);
      if (tmp.length == 0)
        return 1;

      var topic = tmp[Std.random(tmp.length)];
      var points = (res == ROLL_SUCCESS ? 1 : 3);
      if (topic.points + points > topic.maxPoints)
        points = topic.maxPoints - topic.points;

      topic.points += points;
      var info = ChatConst.getCommonTopic(topic.id);
      print('[+' + points + ' ' + info.name + ' points]');

      return 1;
    }


// handle common topic discussion
  function discussCommonTopic(chatTopic: ChatCommonTopic, topic): Int
    {
      // check and decrease topic points
      if (chatTopic.points <= 0)
        {
          print('That topic is currently exhausted.');
          return -1;
        }
      chatTopic.points--;

      // uncover chatTopic
      var s = new StringBuf();
      s.add('You ');
      if (chatMode == CHAT_MODE_CAUTIOUS)
        s.add('discreetly converse about **' + topic.nameLower + '** with ' +
          name);
      else if (chatMode == CHAT_MODE_INTIMATE)
        s.add('intimately discuss **' + topic.nameLower + '** with ' + name);
      else if (chatMode == CHAT_MODE_AGGRESSIVE)
        s.add('aggressively confront ' + name + ' about **' +
          topic.nameLower + '**');

      // roll skill according to state
      var skillID = null;
      if (chatMode == CHAT_MODE_CAUTIOUS)
        skillID = 'fastTalk';
      else if (chatMode == CHAT_MODE_INTIMATE)
        skillID = 'persuade';
      else if (chatMode == CHAT_MODE_AGGRESSIVE)
        skillID = 'knowledge';
      var res = game.player.roll(skillID);

      // pick coef according to result
      // cannot ROLL_ZERO because all convo skills have > 0 base
      var coef = 1.0;
      if (res == ROLL_FUMBLE)
        {
          s.add(' sounding like a blabbering fool.');
          coef = 0.25;
        }
      else if (res == ROLL_FAIL)
        {
          s.add(' with a miniscule amount of expertise.');
          coef = 0.5;
        }
      else if (res == ROLL_SUCCESS)
        {
          s.add(' with a degree of competence.');
          coef = 1.0;
        }
      else if (res == ROLL_CRIT)
        {
          s.add(' making excellent points.');
          coef = 1.5;
        }

      var hint = getHint(HINT_TOPIC, topic.id);
      if (hint.stage < 4)
        {
          hint.stage = 4;
          hint.text = hint.fullText;
          s.add(' It appears that ' + pronoun +
            (chatTopic.isFavorite ? ' loves' : ' hates') +
            ' talking about it.');
        }

      // handle results
      // normal
      var oldChatState = chatState;
      if (chatState == NPC_STATE_NORMAL && chatTopic.isFavorite)
        {
          if (chatMode == CHAT_MODE_CAUTIOUS)
            {
              rapport += Std.int(10 * coef);
            }
          else if (chatMode == CHAT_MODE_INTIMATE)
            {
              rapport += Std.int(10 * coef);
              anxiety -= Std.int(10 * coef);
            }
          else if (chatMode == CHAT_MODE_AGGRESSIVE)
            {
              anxiety += Std.int(10 * coef);
              var rnd = Std.random(100);
              if (rnd < 80)
                chatState = NPC_STATE_CONFUSION;
              else chatState = NPC_STATE_AGREEMENT;
            }
        }
      else if (chatState == NPC_STATE_NORMAL && !chatTopic.isFavorite)
        {
          if (chatMode == CHAT_MODE_CAUTIOUS)
            {
              anxiety -= Std.int(10 * coef);
            }
          else if (chatMode == CHAT_MODE_INTIMATE)
            {
              rapport -= Std.int(10 * coef);
              anxiety += Std.int(10 * coef);
            }
          else if (chatMode == CHAT_MODE_AGGRESSIVE)
            {
              anxiety += Std.int(10 * coef);
              var rnd = Std.random(100);
              if (rnd < 80)
                chatState = NPC_STATE_CONFUSION;
              else chatState = NPC_STATE_ENMITY;
            }
        }

      // confusion
      else if (chatState == NPC_STATE_CONFUSION && chatTopic.isFavorite)
        {
          if (chatMode == CHAT_MODE_CAUTIOUS)
            {
              rapport -= Std.int(10 * coef);
            }
          else if (chatMode == CHAT_MODE_INTIMATE)
            {
              var rnd = Std.random(100);
              if (rnd < 80)
                chatState = NPC_STATE_AGREEMENT;
              else chatState = NPC_STATE_ENMITY;
            }
          else if (chatMode == CHAT_MODE_AGGRESSIVE)
            {
              anxiety += Std.int(10 * coef);
              var rnd = Std.random(100);
              if (rnd < 80)
                chatState = NPC_STATE_ENMITY;
              else chatState = NPC_STATE_AGREEMENT;
            }
        }
      else if (chatState == NPC_STATE_CONFUSION && !chatTopic.isFavorite)
        {
          if (chatMode == CHAT_MODE_CAUTIOUS)
            {
              anxiety += Std.int(10 * coef);
            }
          else if (chatMode == CHAT_MODE_INTIMATE)
            {
              rapport += Std.int(10 * coef);
              anxiety -= Std.int(10 * coef);
            }
          else if (chatMode == CHAT_MODE_AGGRESSIVE)
            {
              anxiety += Std.int(10 * coef);
              var rnd = Std.random(100);
              if (rnd < 80)
                chatState = NPC_STATE_ENMITY;
              else chatState = NPC_STATE_AGREEMENT;
            }
        }

      // enmity
      else if (chatState == NPC_STATE_ENMITY && chatTopic.isFavorite)
        {
          if (chatMode == CHAT_MODE_CAUTIOUS)
            {
              rapport -= Std.int(10 * coef);
              var rnd = Std.random(100);
              if (rnd < 10)
                chatState = NPC_STATE_CONFUSION;
            }
          else if (chatMode == CHAT_MODE_INTIMATE)
            {
              rapport -= Std.int(20 * coef);
              var rnd = Std.random(100);
              if (rnd < 10)
                chatState = NPC_STATE_CONFUSION;
            }
          else if (chatMode == CHAT_MODE_AGGRESSIVE)
            {
              rapport -= Std.int(30 * coef);
            }
        }
      else if (chatState == NPC_STATE_ENMITY && !chatTopic.isFavorite)
        {
          if (chatMode == CHAT_MODE_CAUTIOUS)
            {
              anxiety += Std.int(10 * coef);
              var rnd = Std.random(100);
              if (rnd < 20)
                chatState = NPC_STATE_CONFUSION;
            }
          else if (chatMode == CHAT_MODE_INTIMATE)
            {
              anxiety += Std.int(20 * coef);
              var rnd = Std.random(100);
              if (rnd < 20)
                chatState = NPC_STATE_CONFUSION;
            }
          else if (chatMode == CHAT_MODE_AGGRESSIVE)
            {
              anxiety += Std.int(30 * coef);
            }
        }

      // agreement
      else if (chatState == NPC_STATE_AGREEMENT && chatTopic.isFavorite)
        {
          if (chatMode == CHAT_MODE_CAUTIOUS)
            {
              rapport += Std.int(10 * coef);
              var rnd = Std.random(100);
              if (rnd < 10)
                chatState = NPC_STATE_CONFUSION;
            }
          else if (chatMode == CHAT_MODE_INTIMATE)
            {
              rapport += Std.int(20 * coef);
              var rnd = Std.random(100);
              if (rnd < 20)
                chatState = NPC_STATE_CONFUSION;
            }
          else if (chatMode == CHAT_MODE_AGGRESSIVE)
            {
              rapport += Std.int(30 * coef);
              var rnd = Std.random(100);
              if (rnd < 10)
                chatState = NPC_STATE_CONFUSION;
              else if (rnd < 20)
                chatState = NPC_STATE_ENMITY;
            }
        }
      else if (chatState == NPC_STATE_AGREEMENT && !chatTopic.isFavorite)
        {
          if (chatMode == CHAT_MODE_CAUTIOUS)
            {
              anxiety -= Std.int(10 * coef);
              var rnd = Std.random(100);
              if (rnd < 10)
                chatState = NPC_STATE_CONFUSION;
            }
          else if (chatMode == CHAT_MODE_INTIMATE)
            {
              anxiety -= Std.int(20 * coef);
              var rnd = Std.random(100);
              if (rnd < 20)
                chatState = NPC_STATE_CONFUSION;
            }
          else if (chatMode == CHAT_MODE_AGGRESSIVE)
            {
              anxiety -= Std.int(30 * coef);
              var rnd = Std.random(100);
              if (rnd < 10)
                chatState = NPC_STATE_CONFUSION;
              else if (rnd < 20)
                chatState = NPC_STATE_ENMITY;
            }
        }

      // state changed
      if (oldChatState != chatState)
        {
          if (chatState == NPC_STATE_CONFUSION)
            s.add(' You have managed to confuse ' + name + '.');
          else if (chatState == NPC_STATE_ENMITY)
            s.add(' You have succeeded in making ' + name + ' annoyed.');
          else if (chatState == NPC_STATE_AGREEMENT)
            s.add(' ' + nameUpper + ' completely agrees with you now.');
        }
      print(s.toString());

      return 1;
    }


// initialize hints state
  function initHints()
    {
      hints = [];

      // add common topics
      for (topic in chatCommonTopics)
        hints.push({
          type: HINT_TOPIC,
          text: '',
          id: topic.id,
          knownLetters: [],
          fullText: ChatConst.getCommonTopic(topic.id).name,
          stage: 0,
        });

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
  public function gainHints(res: _RollResult)
    {
      // example for skill persuade
      // 0: -
      // 1: [?]
      // 2: [?e*]
      // 3: [Skill ?e*]
      // 4: [Skill Persuade]

      for (hint in hints)
        {
          // roll result influence
          if (res == ROLL_FUMBLE)
            {
              if (Std.random(100) < 75)
                continue;
            }
          else if (res == ROLL_FAIL)
            {
              if (Std.random(100) < 50)
                continue;
            }
          else if (res == ROLL_SUCCESS)
            {
              if (Std.random(100) < 25)
                continue;
            }

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
              if (Std.random(100) < 50)
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
      var ss = new StringBuf(); //'You are talking with ' + name + '.\n';
      if (chatState == NPC_STATE_CONFUSION)
        ss.add(nameUpper + ' looks baffled.');
      else if (chatState == NPC_STATE_ENMITY)
        ss.add(nameUpper + ' looks irritated.');
      else if (chatState == NPC_STATE_AGREEMENT)
        ss.add(nameUpper + ' looks at you smiling.');
      else if (chatState == NPC_STATE_NORMAL)
        ss.add(nameUpper + ' looks at you expectantly.');
      if (evalTimer > 0 && chatState != NPC_STATE_NORMAL)
        ss.add(' [' + chatStateTimer + ' turns left]');
      ss.add('\n');
      if (evalTimer > 0)
        ss.add('[Anxiety: ' + anxiety + '/100, ' +
          'Rapport: ' + rapport + '/100]\n');

      ss.add('Mode: ');
      if (chatMode == CHAT_MODE_CAUTIOUS)
        ss.add('Cautious');
      else if (chatMode == CHAT_MODE_INTIMATE)
        ss.add('Intimate');
      else if (chatMode == CHAT_MODE_AGGRESSIVE)
        ss.add('Aggressive');
      ss.add('\n');

      // print hints
      var hintstr = printHints();
      if (hintstr.length > 0)
        ss.add('Hints: ' + hintstr);
      print(ss.toString());
    }


// print hints state
  function printHints(): String
    {
      // print known hints
      var sb = new StringBuf();
//      game.console.debug(hints + '');
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
          if (hint.type == HINT_TOPIC && hint.stage == 4)
            {
              var topic = chatCommonTopics[hint.id];
              sb.add('<span class=topic' +
                (topic.isFavorite ? 'Loves' : 'Hates') + '>' +
                hint.text + '</span>');
              if (evalTimer > 0)
                sb.add(' (' + topic.points + ')');
            }
          else sb.add(hint.text);
          sb.add('] ');
        }

      return sb.toString();
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


// get/set anxiety
  function get_anxiety(): Int
    {
      return _anxiety;
    }
  function set_anxiety(v: Int)
    {
      if (v < 0)
        v = 0;
      if (v > 100)
        v = 100;
      var mod = v - _anxiety;
      game.console.debug('anxiety ' + _anxiety + ' ' +
        (mod > 0 ? '+' : '') + mod +
        ' = ' + v);
      _anxiety = v;
      return v;
    }


// find hint
  function getHint(t: ChatHintType, id: String): ChatHint
    {
      for (h in hints)
        if (h.type == t && h.id == id)
          return h;

      return null;
    }


// get/set rapport
  function get_rapport(): Int
    {
      return _rapport;
    }
  function set_rapport(v: Int)
    {
      if (v < 0)
        v = 0;
      if (v > 100)
        v = 100;
      var mod = v - _rapport;
      game.console.debug('rapport ' + _rapport + ' ' +
        (mod > 0 ? '+' : '') + mod +
        ' = ' + v);
      _rapport = v;
      return v;
    }


// get/set NPC state
  function get_chatState(): ChatState
    {
      return _chatState;
    }
  function set_chatState(v: ChatState)
    {
      if (_chatState == v)
        return v;

      _chatState = v;
      if (v != NPC_STATE_NORMAL)
        chatStateTimer = 4;
      game.console.debug('set state to ' + v);

      return v;
    }


  public static var commandHelp = [
    'again' => 'again, g - Repeats previous command again.',
    'chat' => 'chat, c - (Roll Charisma) Make small talk to the character. Raises character anxiety and gives some hints.',
    'discuss' => 'discuss, d <topic> - Discuss this topic in conversation.',
    'evaluate' => 'evaluate, eval, e - (Roll Psychology) Assess the emotional state of the character. Shows detailed information for the next three turns.',
    'examine' => 'examine, x, look, l - (Roll Spot Hidden) Examines the NPC and surroundings, giving some hints.',
    'look' => 'examine, x, look, l - (Roll Spot Hidden) Examines the NPC and surroundings, giving some hints.',
    'probe' => 'probe, p - (Roll Fast Talk) Converse about some general topics in-depth with the character. Raises character rapport and gives some hints.',
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


typedef ChatCommonTopic = {
  var id: String;
  var points: Int;
  var maxPoints: Int;
  var isFavorite: Bool;
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


enum ChatMode {
  CHAT_MODE_CAUTIOUS;
  CHAT_MODE_INTIMATE;
  CHAT_MODE_AGGRESSIVE;
}


enum ChatState {
  NPC_STATE_NORMAL;
  NPC_STATE_CONFUSION;
  NPC_STATE_ENMITY;
  NPC_STATE_AGREEMENT;
}
