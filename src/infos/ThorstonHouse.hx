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
          actions: [],
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
          actions: [],
          objects: new Map(),
        },

        {
          id: 'workshop',
          game: game,
          name: 'Workshop',
          note: 'This large room is filled to the brim with magician paraphernalia. A working desk near the window, a makeup table with a mirror in the corner next to a wardrobe, large chests, copious amounts of stage clothing, small cages supposedly for rabbits, all that could swallow a whole party of investigators.',
          actions: [],
          objects: [

            // ==========
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
                              game.adventure.failClue('workshopDiary');
                            }
                          else
                            {
                              print('Thorston has regularly written in his diary. It is strange that he stopped writing so abruptly.');
                              game.adventure.gainClue('workshopDiary');
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

            // ==========
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
                          print('Straining and grunting, you move the heavy wardrobe out of the way. It reveals a big brown spot on the wall behind it.');
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

            // ==========
            'smudge' => {
              id: 'smudge',
              names: [ 'smudge', 'spot', 'patch', 'wall' ],
              isEnabled: false,
              locationNote: 'There is a large brown smudge on the wall behind the wardrobe.',
              actions: [
                {
                  names: [ 'x' ],
                  func: function(o: ObjectInfo)
                    {
                      print('The smudge resembles a human figure in form.');
                      game.adventure.gainClue('workshopSmudge');
                      o.isEnabled = false;
                    }
                },
                {
                  names: [ 'analyze', 'get', 'sample' ],
                  roll: 'chemistry',
                  func: function(o: ObjectInfo)
                    {
                      if (o.state == 1)
                        {
                          print('You have already taken a sample.');
                          return;
                        }

                      var res = game.player.roll('chemistry');
                      if (res == ROLL_FAIL || res == ROLL_FUMBLE)
                        {
                          printFail('chemistry');
                        }
                      else
                        {
                          print('You have gathered a sample of the smudge for later analysis in the laboratory.');
                          game.adventure.gainItem('smudgeSample');
                          o.state = 1;
                        }
                    }
                }
              ]
            },

            // ==========
            'odor' => {
              id: 'odor',
              names: [ 'smell', 'odor' ],
              locationNote: 'You notice a faint pungent odor pervading the room.',
            },

            // ==========
            'paper' => {
              id: 'paper',
              names: [ 'paper' ],
              locationNote: 'There is a small piece of paper tucked into the corner of the mirror.',
              actions: [
                {
                  names: [ 'x', 'read' ],
                  func: function(o: ObjectInfo)
                    {
                      print('It is Balog\'s business card. Nothing particular stands out about it.' +
                          (o.state == 0 ? ' However, the mirror itself...' : ''));
                      o.isEnabled = false;
                    }
                }
              ]
            },

            // ==========
            'mirror' => {
              id: 'mirror',
              names: [ 'mirror' ],
              actions: [
                {
                  names: [ 'x' ],
                  func: function(o: ObjectInfo)
                    {
                      if (o.state < 3)
                        {
                          var res = game.player.roll('spotHidden');
                          if (res == ROLL_FAIL || res == ROLL_FUMBLE)
                            {
                              printFail('spotHidden');
                            }
                          else
                            {
                              if (o.state == 0)
                                print('There is something unnatural in the reflection. (more)');
                              else if (o.state == 1)
                                print('You cannot quite grasp what is it about the reflection you find weird. (more)');
                              else if (o.state == 2)
                                {
                                  print('It is as if the reflection has all colors washed out of it. Everything looks grey and lifeless.');
                                  location.objects['paper'].state = 1;
                                  game.scene.moveTo('reflection');
                                }
                              o.state++;
                            }
                        }

                      else if (o.state == 3)
                        {
                          print('You tense uncontrollably while looking into the mirror. Nothing happens.');
                        }
                    }
                },
              ]
            }
            // TODO: mirror, chest(s), clothing, cage, window, table
          ],
        },

        // ===============
        {
          id: 'reflection',
          game: game,
          name: 'Reflection',
          note: 'You are mesmerized by the reflection in the mirror. You need to do something about it.',
          actions: [
            {
              names: [ 'move', 'look away', 'resist', 'run', 'leave', 'turn away', 'run away' ],
              func: function ()
                {
                  var res = game.player.roll('willpower');
                  if (res == ROLL_FAIL || res == ROLL_FUMBLE)
                    {
                      var tmp = [
                        'move' => 'You cannot move.',
                        'look away' => 'Something compels you to look into the mirror.',
                        'run' => 'You cannot run.',
                        'leave' => 'You cannot leave.',

                      ];
                      print(tmp[game.console.lastCommand]);
                    }
                  else
                    {
                      print('Through sheer force of will you have turned away from the mirror. A moment passes and everything is back to normal.');
                      game.scene.moveTo('workshop');
                    }
                }
            }
          ],

          objects: [
            // ==========
            'mirror' => {
              id: 'mirror',
              names: [ 'mirror', 'reflection' ],
              actions: [
                {
                  names: [ 'attack', 'hit', 'punch' ],
                  roll: 'fist',
                  func: function(o: ObjectInfo)
                    {
                      var res = game.player.roll('fist');
                      if (res == ROLL_FAIL || res == ROLL_FUMBLE)
                        {
                          print('You did not manage to break the mirror. Your hand hurts, though.');
                          game.player.damage(1);
                        }
                      else
                        {
                          print('Screaming out, you smash the mirror with your fist. You feel much better now except for your bleeding hand.');
                          game.player.damage(1);
                          game.scene.moveTo('workshop');
                        }
                    }
                },
                {
                  names: [ 'x' ],
                  func: function(o: ObjectInfo)
                    {
                      print('The man in the mirror stares at you unblinking.');
                      print('*He does not look like you at all.*');
                      game.player.rollSanity(1, Const.dice(1, 3),
                        'Inexorably, he reaches out with his pale gray hand.');
                      game.scene.moveTo('workshop');
                    }
                }
              ]
            }
          ]
        },

        // ===============
      ];
      startingLocation = locations[0];

      // =npcs
      npcs = [
        new ButlerThorston(game, this),
      ];
    }
}
