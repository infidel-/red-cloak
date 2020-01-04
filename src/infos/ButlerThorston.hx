package infos;

// butler at Thorston's house

class ButlerThorston extends NPC
{
  public var tries: Int; // chat tries

  public function new(g: Game, s: Scene)
    {
      super(g, s);

      id = 'butlerThorston';
      name = 'the butler';
      tries = 3;
      chatSkills = [
        {
          id: 'credit',
          say: 'Oh, you\'re a business partner of mister Thorston? Please, do come in!',
          result: {
            type: RESULT_CHAT_FINISH_SUCCESS,
          }
        },
        {
          id: 'law',
          say: 'So, you\'re helping the police with the investigation? Please, do come in!',
          result: {
            type: RESULT_CHAT_FINISH_SUCCESS,
          }
        },
        {
          id: 'persuade',
          say: 'Oh, you\'re a friend of mister Thorston? Please, do come in!',
          result: {
            type: RESULT_CHAT_FINISH_SUCCESS,
          }
        },
      ];
      chatTopicUnknown = 'The butler looks at you politely feigning interest.';
      chatTopics = [
        {
          id: 'redCloak',
          stages: [
            {
              say: 'Outrageous! The police should immediately find the murderer!',
              result: {
                type: RESULT_CHAT_INTEREST,
                value: 20
              }
            },
            {
              say: 'What are we paying the taxes for?!',
              result: {
                type: RESULT_CHAT_INTEREST,
                value: 20
              }
            },
          ]
        },
/*
        {
          id: 'thorston',
          func: function()
            {
              if (disposition < 75)
                {
                  handleTopic({
                    id: 'thorston',
                    stages: [
                      {
                        say: 'Mister Thorston is not available at the moment.'
                      },
                      {
                        say: 'Mister Thorston is missing and the police have been notified.'
                      }
                    ]
                  });
                  say()

                }
              else
                {
                  say('I see you are also troubled by his disappearance. I suppose I could let you check the house out.');
                  finishChat(true);
                }
            }
        },
*/
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

      say('What is your business here?');
      tries--;
      disposition = 50;
      interest = 30;
      return true;
    }


// turn callback
  override function turnPre()
    {
      print('The butler is gradually losing patience.');
      interest -= 5;
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
