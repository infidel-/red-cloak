package infos;

import NPC;

// butler at Thorston's house

class ButlerThorston extends NPC
{
  public var tries: Int; // chat tries

  public function new(g: Game, s: Scene)
    {
      super(g, s);

      id = 'butlerThorston';
      name = 'the butler';
      nameUpper = 'The butler';
      tries = 3;
      chatSkills = [
        'credit' => {
          id: 'credit',
          isOneTime: true,
          isEnabled: true,
          say: 'Oh, you are a business partner of mister Thorston? Please, do come in!',
          sayFail: 'I do not believe I have had the pleasure of meeting you before.',
          result: {
            type: RESULT_CHAT_FINISH_SUCCESS,
          }
        },
        'law' => {
          id: 'law',
          isOneTime: true,
          isEnabled: true,
          say: 'So you are helping the police with the investigation? Please, do come in!',
          sayFail: 'Let me see some credentials first.',
          result: {
            type: RESULT_CHAT_FINISH_SUCCESS,
          }
        },
      ];
      chatTopicUnknown = 'The butler looks at you politely feigning interest.';
      chatTopicNotInterested = 'The butler is not interested in that topic.';
      chatCommonTopics = [
        'politics' => {
          id: 'politics',
          points: 3,
          maxPoints: 3,
          isFavorite: true,
        },
        'news' => {
          id: 'news',
          points: 3,
          maxPoints: 3,
          isFavorite: false,
        },
      ];

      examineNote = 'When irritated, the butler can be exploited to gain favor.';
      chatSpecialTopics = [
       'redCloak' => {
          id: 'redCloak',
          isEnabled: true,
          func: function()
            {
              if (chatState != NPC_STATE_ENMITY)
                {
                  sayRandom([
                    'Outrageous! The police should immediately find the murderer!',
                    'What are we paying the taxes for?!',
                  ]);
                }
              else
                {
                  say('Someone should do something about it!',
                    '+20 Rapport');
                  rapport += 20;
                  disableSpecialTopic('redCloak');
                  setState(NPC_STATE_AGREEMENT);
                }
            }
        },

        'thorston' => {
          id: 'thorston',
          isEnabled: true,
          func: function()
            {
              if (rapport < 75)
                {
                  sayRandom([
                    'Mister Thorston is not available at the moment.',
                    'Mister Thorston is missing and the police have been notified.',
                    'I am not at liberty to discuss my employer with strangers.',
                  ]);
                }
              else
                {
                  say('I see you are also troubled by his disappearance. I suppose I could let you check the house out.');
                  finishChat(true);
                }
            }
        },
      ];
    }


// pre-start chat check
  override function startChatPre(): Bool
    {
      if (tries == 0)
        {
          say('Please leave or I will call the police!');
          print('The butler goes back into the house.');
          return false;
        }

      if (tries > 1)
        say('What is your business here?');
      else say('This is the last time I am talking to you!');
      tries--;

      // reset state
//      anxiety = Std.int(anxiety / 2);
//      rapport = Std.int(rapport / 2);
      anxiety = 0;
      rapport = 0;
      enableSpecialTopic('redCloak');
      enableSkill('law');
      enableSkill('credit');
      addEffect({
        id: 'impatient',
        timer: 10,
        print: function (s: StringBuf, e: Effect)
          {
            s.add('Impatient ' + sys(e.timer + ' turns left'));
          },
        finish: function ()
          {
            finishChat(false);
          }
      });
      return true;
    }


// turn callback
  override function turnPre()
    {
    }


// chat finish fail
  override function finishChatFail()
    {
      if (tries > 0)
        say('I do not have time for this!');
      else say('Stop wasting my time or I will call the police!');
      print('The butler goes back into the house.');
    }


// chat finish success
  override function finishChatSuccess()
    {
      print('You follow the butler into the house.');
      game.scene.move('firstFloor');
    }
}
