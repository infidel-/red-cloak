// DEMO - Thorston's House

package infos;

class ThorstonHouse extends Scene
{
  public function new(g: Game)
    {
      super(g);

      // =locations
      locations = [
        {
          id: 'gates',
          game: game,
          name: 'At the gates',
          note: 'You are at the gates in the fence surrounding the nice two-storied house where Great Harold lives when he is in the city.',
          objects: [
            {
              id: 'bell',
              isKnown: true,
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
            {
              id: 'fence',
              isKnown: true,
              note: 'The wrought iron fence is significantly taller than you are.',
              names: [ 'wall', 'fence' ],
              actions: [
                {
                  names: [ 'climb' ],
                  note: 'You cannot climb the fence here.',
                },
              ]
            },
            {
              id: 'gates',
              isKnown: true,
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
          name: 'First floor corridor.',
          note: 'You are in the corridor at the first floor. There are a couple doors here.',
          objects: [],
        }
      ];
      startingLocation = locations[0];

      // =npcs
      npcs = [
        new ButlerThorston(game, this),
      ];
    }
}
