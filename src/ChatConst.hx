class ChatConst
{
  public static var commonTopics: Map<String, {
    var id: String;
    var name: String;
    var nameLower: String;
    var names: Array<String>;
  }> = [
    'politics' => {
      id: 'politics',
      name: 'Politics',
      nameLower: 'politics',
      names: [
        'politics',
        'pol',
      ]
    },
    'science' => {
      id: 'science',
      name: 'Science',
      nameLower: 'science',
      names: [
        'science',
        'sci',
      ]
    },
    'news' => {
      id: 'news',
      name: 'News',
      nameLower: 'news',
      names: [
        'news',
        'new',
      ]
    },
    'sports' => {
      id: 'sports',
      name: 'Sports',
      nameLower: 'sports',
      names: [
        'sports',
        'spo',
      ]
    },
    'entertainment' => {
      id: 'entertainment',
      name: 'Entertainment',
      nameLower: 'entertainment',
      names: [
        'entertainment',
        'ent'
      ]
    },
    'business' => {
      id: 'business',
      name: 'Business',
      nameLower: 'business',
      names: [
        'business',
        'bus',
      ]
    },
    'culture' => {
      id: 'culture',
      name: 'Culture',
      nameLower: 'culture',
      names: [
        'culture',
        'cul',
      ]
    },
  ];


// prints common conversation topics
  public static function printCommonTopics(game: Game)
    {
      var s = new StringBuf();
      s.add('Common topics: ');
      for (ch in commonTopics)
        s.add(ch.name + ', ');
      var msg = s.toString();
      msg = msg.substr(0, msg.length - 2);
      game.console.print(msg);
    }


// get common topic info
  public static function getCommonTopic(name: String)
    {
      var topic = null;
      for (t in commonTopics)
        if (Lambda.has(t.names, name))
          return t;

      return null;
    }
}
