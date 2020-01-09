// player state

class Player
{
  var game: Game;
  public var skills: Map<String, Skill>;
  public var stats: Stats;

  public function new(g: Game, s: Stats)
    {
      game = g;
      stats = s;

      // default skills
      skills = new Map();
      SkillConst.addDefaults(skills);

      // stat-based skills
      skills['strength'].val = stats.str * 5;
      skills['idea'].val = stats.int * 5;
      skills['knowledge'].val = stats.edu * 5;
      skills['willpower'].val = stats.pow * 5;
      skills['charisma'].val = stats.cha * 5;
    }


// roll skill by its name/string id/synonym
// 0: skill at default 0
// -1: failure
// -2: fumble
// 1: success
// 2: success
  public function roll(id: String, ?mods: Array<_SkillMod> = null): _RollResult
    {
      var skill = skills[id];
      if (skill == null)
        throw 'No such skill: ' + id;
      if (skill.val == 0)
        return ROLL_ZERO;

      // apply mods
      var value = skill.val;
      var valuestr = '' + value;
      if (mods != null)
        {
          valuestr = '';
          for (m in mods)
            {
              value += m.val;
              valuestr += ' ' + (m.val > 0 ? '+' : '') + m.val;
            }
          if (value < 0)
            value = 0;
          valuestr = value + ' (' + skill.val + valuestr + ')';
        }

      var roll = 1 + Std.random(100);
      var success = (roll <= value);
      var str = '';
      var res: _RollResult = null;
      if (success && roll == 1)
        {
          str = '<span class=rollSuccess>**Critical Success**</span>';
          res = ROLL_CRIT;
        }
      else if (success)
        {
          str = '<span class=rollSuccess>Success</span>';
          res = ROLL_SUCCESS;
        }
      else if (!success && roll == 100)
        {
          str = '<span class=rollFail>**Fumble**</span>';
          res = ROLL_FUMBLE;
        }
      else if (!success)
        {
          str = '<span class=rollFail>Failure</span>';
          res = ROLL_FAIL;
        }
      game.console.system('[Roll ' + skill.info.name + ', ' +
        roll + '/' + valuestr + ', ' + str + ']');

      return res;
    }
}


typedef _SkillMod = {
  var src: String;
  var val: Int;
}
