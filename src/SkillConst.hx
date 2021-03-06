// skills info

class SkillConst
{
  public static var infos: Array<_SkillInfo> = [
	// investigation
    {
      id: 'libraryUse',
      name: 'Library Use',
      names: [ 'library use', 'lib' ],
      val: 25,
      isFake: false,
    },
    {
      id: 'listen',
      name: 'Listen',
      names: [ 'listen' ],
      val: 25,
      isFake: false,
    },
    {
      id: 'spotHidden',
      name: 'Spot Hidden',
      names: [ 'spot hidden', 'spot' ],
      val: 25,
      isFake: false,
    },
    {
      id: 'idea', // int x5
      name: 'Idea',
      names: [ 'idea' ],
      val: 0,
      isFake: false,
    },
    {
      id: 'knowledge', // edu x5
      name: 'Knowledge',
      names: [ 'knowledge', 'know' ],
      val: 0,
      isFake: false,
    },
    {
      id: 'willpower', // pow x5
      name: 'Willpower',
      names: [ 'willpower', 'will', 'wp' ],
      val: 0,
      isFake: false,
    },
    {
      id: 'sanity', // pow x5
      name: 'Sanity',
      names: [ 'sanity', 'san' ],
      val: 0,
      isFake: true,
    },

    // social
    {
      id: 'charisma', // cha x5
      name: 'Charisma',
      names: [ 'charisma', 'cha' ],
      val: 0,
      isFake: false,
    },
    {
      id: 'credit',
      name: 'Credit Rating',
      names: [ 'credit rating', 'credit' ],
      val: 15,
      isFake: false,
    },
    {
      id: 'fastTalk',
      name: 'Fast Talk',
      names: [ 'fast talk', 'talk', 'fast' ],
      val: 5,
      isFake: false,
    },
    {
      id: 'persuade',
      name: 'Persuade',
      names: [ 'persuade', 'per' ],
      val: 15,
      isFake: false,
    },
    {
      id: 'psychology',
      name: 'Psychology',
      names: [ 'psychology', 'psy' ],
      val: 5,
      isFake: false,
    },

    {
      id: 'strength', // str x5
      name: 'Strength',
      names: [ 'strength', 'str' ],
      val: 0,
      isFake: false,
    },
    
    // combat
    {
      id: 'fist',
      name: 'Fist/Punch',
      names: [ 'fist', 'punch' ],
      val: 50,
      isFake: false,
    },

    // academia and misc
    {
      id: 'law',
      name: 'Law',
      names: [ 'law' ],
      val: 5,
      isFake: false,
    },
    {
      id: 'chemistry',
      name: 'Chemistry',
      names: [ 'chemistry', 'chem' ],
      val: 0,
      isFake: false,
    },
/*
Combat:
Dodge DEX ×2%
Head Butt 10%
Ranged Weapon (spec.) {varies}
Kick 25%
Martial Arts 0%
Melee Weapon (spec.) {varies}
Grapple 25%

Second Tier (used less often):
First Aid 30%
Climb 40%
Jump 25%
Throw 25%  

Third Tier (used very rarely at specific places, part of occupation):  

Academic
Accounting 10%
Anthropology 0%
Archaeology 0%
Astronomy 0%
Biology 0%
Geology 0%
History 20%
Natural History 10%
Occult 5%
Own Language EDU×5%
Pharmacy 0%
Physics 0%
Medicine 5%
Psychoanalysis 0%
Mythos 0%

Misc
Swim 25%
Ride 5%
Drive Auto 20%
Electrical Repair 10%
Locksmith 0%
Mechanical Repair 20%
Navigate 10%
Sneak 10%
Track 10% 
*/
  ];


// add default skill values to player/npc skills
  public static function addDefaults(skills: Map<String, Skill>)
    {
      for (info in infos)
        skills.set(info.id, {
          val: info.val,
          info: info
        });
    }


// find skill by id
  public static function getByID(id: String): _SkillInfo
    {
      for (info in infos)
        if (info.id == id)
          return info;
      return null;
    }


// find skill by name
  public static function getInfo(name: String): _SkillInfo
    {
      for (info in infos)
        if (Lambda.has(info.names, name))
          return info;
      return null;
    }


// prints skills
  public static function printSkills(game: Game)
    {
      var sb = new StringBuf();
      sb.add('Skills: ');
      for (skill in game.player.skills)
        if (!skill.info.isFake)
          sb.add(skill.info.name + ' (' + skill.val + '%), ');
      var s = sb.toString();
      s = s.substr(0, s.length - 2);
      s += '</span>';
      game.console.print(s);
    }
}

typedef _SkillInfo = {
  public var id: String;
  public var name: String;
  public var names: Array<String>;
  public var val: Int;
  public var isFake: Bool;
}
