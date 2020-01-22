// adventure static data and code

package infos;

class AdventureInfo
{
  public var game: Game;
  public var who: Array<{
    var id: String;
    var name: String;
    var names: Array<String>;
    var note: String;
    var isKnown: Bool;
  }>;
  public var topics: Array<_ChatSpecialTopicInfo>;
  public var clues: Map<String, String>;
  public var items: Map<String, {
    var id: String;
    var name: String;
    var names: Array<String>;
    var note: String;
  }>;

  public function new(g: Game)
    {
      game = g;
      who = [
        {
          id: 'curator',
          name: 'Edward Balog',
          names: [
            'balog',
            'curator',
            'edward',
          ],
          note: "Edward Balog is the curator of the Metropolis Art Museum and your business partner. You often procure various art objects for him in return for handsome paychecks. The method of procurement varies heavily.",
          isKnown: true,
        },
        {
          id: 'thorston',
          name: 'Harold Thorston',
          names: [
            'great',
            'harold',
            'illusionist',
            'mage',
            'magician',
            'thorston',
          ],
          note: "Great Harold is a famous illusionist known for his elaborate and expensive stunts. Reported missing since yesterday's performance in the museum.",
          isKnown: true,
        },
      ];

      var topicThorston = Reflect.copy(who[1]);
      topics = [
        {
          id: 'redCloak',
          name: 'Red Cloak',
          names: [
            'cloak',
            'red',
            'murders',
            'murderer',
          ],
          note: "Red Cloak is the name the press gave to the mysterious murderer that has recently started terrorizing the inhabitants of Metro city.",
          isKnown: true,
        },
        topicThorston,
      ];

      // clues
      clues = [
        'workshopDiary' => 'Thorston has stopped writing in his diary two weeks ago.',
        'workshopSmudge' => 'There is a big brown smudge on the wall behind the wardrobe in Thorston\'s workshop in the form of a human.',
      ];

      items = [
        'smudgeSample' => {
          id: 'smudgeSample',
          name: 'sample of smudge',
          names: [ 'smudge', 'sample' ],
          note: 'This is a sample of brown smudge you have collected in Thorston\'s workshop.',
        }
      ];
    }
}

typedef _ChatSpecialTopicInfo = {
  var id: String;
  var name: String;
  var names: Array<String>;
  var note: String;
  var isKnown: Bool;
};
