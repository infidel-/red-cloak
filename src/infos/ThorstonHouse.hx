// DEMO - Thorston's House

package infos;

class ThorstonHouse extends Scene
{
  public function new(g: Game)
    {
      super(g);

      cluesTotal = 3;

      // =locations
      locations = [
        {
          id: 'gates',
          game: game,
          name: 'At the gates',
          note: 'You are at the gates in the fence surrounding the nice two-storied house where Great Harold lives when he is in the city.',
          objects: [
            'bell' => {
              id: 'bell',
              names: [ 'bell', 'button' ],
              locationNote: 'There is an electric door bell near the gates here.',
              note: 'This is a button for an electric door bell.',
              actions: [
                {
                  names: [ 'ring', 'push' ],
                  note: "You can't hear the sound from here but soon the front door opens and a man comes up to the gates. He must be the butler.",
                  result: {
                    type: RESULT_CHAT,
                    info: 'butlerThorston',
                  }
                }
              ]
            },
            'fence' => {
              id: 'fence',
              note: 'The wrought iron fence is significantly taller than you are.',
              names: [ 'wall', 'fence' ],
              actions: [
                {
                  names: [ 'climb' ],
                  note: 'You cannot climb the fence here.',
                },
              ]
            },
            'gates' => {
              id: 'gates',
              note: 'The gates are tall and imposing.',
              names: [ 'gates', 'gate' ],
              actions: [
                {
                  names: [ 'climb' ],
                  note: 'You cannot climb the gates.',
                },
                {
                  names: [ 'open' ],
                  note: 'The gates are locked from the inside.',
                },
              ]
            },
          ],
        },
        {
          id: 'firstFloor',
          game: game,
          name: 'First floor corridor',
          note: 'You are in the corridor at the first floor. There are a couple of doors here.',
          objects: new Map(),
        },
        {
          id: 'workshop',
          game: game,
          name: 'Workshop',
          note: 'This large room is filled to the brim with magician paraphernalia. A working desk near the window, a makeup table with a mirror in the corner next to a wardrobe, large chests, copious amounts of stage clothing, small cages supposedly for rabbits, all that could swallow a whole party of investigators.',
          objects: [
            'diary' => {
              id: 'diary',
              names: [ 'diary', 'book' ],
              locationNote: 'A leather bound diary is lying on the desk.',
              actions: [
                {
                  names: [ 'read', 'x' ],
                  func: function(o: ObjectInfo)
                    {
                      if (o.state < 3)
                        o.state++;
                      if (o.state == 1)
                        print('The diary describes Thorston\'s eventful life full of public appearances and performances. (more)');
                      else if (o.state == 2)
                        print('Last entry is dated two weeks ago. (more)');
                      else if (o.state == 3)
                        {
                          var res = game.player.roll('idea');
                          if (res == ROLL_FAIL || res == ROLL_FUMBLE)
                            {
                              printFail('idea');
                              game.adventure.failClue('thorstonDiary');
                            }
                          else
                            {
                              print('Thorston has regularly written in his diary. It is strange that he stopped writing so abruptly.');
                              game.adventure.gainClue('thorstonDiary');
                            }
                          o.state = 4;
                          o.isEnabled = false;
                        }
                      else if (o.state == 4)
                        print('You are done with the diary.');
                    }
                }
              ]
            },
            'wardrobe' => {
              id: 'wardrobe',
              names: [ 'wardrobe', 'cabinet', 'closet' ],
              actions: [
                {
                  names: [ 'x' ],
                  func: function(o: ObjectInfo)
                    {
                      if (o.state == 0)
                        {
                          var res = game.player.roll('spotHidden');
                          if (res == ROLL_FAIL || res == ROLL_FUMBLE)
                            {
                              printFail('spotHidden');
                              o.state = 1;
                            }
                          else
                            {
                              o.state = 2;
                            }
                        }

                      if (o.state == 1)
                        printString('nothingImportant');
                      else if (o.state == 2)
                        print('It looks like the wardrobe has been moved recently.');
                      else if (o.state == 3)
                        print('The wardrobe is moved to the side opening a wall behind it.');
                    }
                },
                {
                  names: [ 'move', 'push', 'pull' ],
                  roll: 'strength',
                  func: function(o: ObjectInfo)
                    {
                      if (o.state == 3)
                        {
                          print('The wardrobe is already out of the way.');
                          return;
                        }

                      var res = game.player.roll('strength');
                      if (res == ROLL_FAIL || res == ROLL_FUMBLE)
                        {
                          print('The wardrobe proves too heavy for you to move.');
                        }
                      else
                        {
                          print('Straining and grunting, you move the heavy wardrobe out of the way. It reveals a big black spot on the wall behind it.');
                          o.state = 3;
                          location.objects['smudge'].isEnabled = true;
                        }
                    }
                },
                {
                  names: [ 'open' ],
                  note: 'After a thorough inspection of its contents, you close it again. There is nothing interesting inside.'
                }
              ]
            },
            'smudge' => {
              id: 'smudge',
              names: [ 'smudge', 'spot', 'patch' ],
              isEnabled: false,
              locationNote: 'There is a large brown smudge on the wall behind the wardrobe.',
            },
            'odor' => {
              id: 'odor',
              names: [ 'smell', 'odor' ],
              locationNote: 'You notice a faint pungent odor pervading the room.',
            },
            'paper' => {
              id: 'paper',
              names: [ 'paper' ],
              locationNote: 'There is a small piece of paper tucked into the corner of a mirror.',
            },
            // TODO: wardrobe, mirror, smudge, chest(s), clothing, cage, window, table
          ],
        }
      ];
      startingLocation = locations[0];

      // =npcs
      npcs = [
        new ButlerThorston(game, this),
      ];
    }
}
