// player state

class Player
{
  var game: Game;
  public var skills: Map<String, Skill>;
  public var stats: Stats;
  public var hp: Int;
  public var maxHP: Int;
  public var maxSan: Int;

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
      skills['sanity'].val = stats.pow * 5;
      skills['charisma'].val = stats.cha * 5;
      maxHP = Math.round((stats.str + stats.con) / 2.0);
      hp = maxHP;
      maxSan = skills['sanity'].val;
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
        {
          game.console.system('No such skill: ' + id);
          return ROLL_FAIL;
        }
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
      // DEBUG: fail roll
      if (game.debug.failRoll)
        {
          roll = 99;
          game.debug.failRoll = false;
        }
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


// roll for sanity
  public function rollSanity(valSuccess: Int, valFail: Int, ?msg: String = null)
    {
      var res = roll('sanity');
      var val = 0;
      if (res == ROLL_FAIL || res == ROLL_FUMBLE)
        val = valFail;
      else val = valSuccess;

      if (msg != null)
        game.console.print('<span class=msgSanity>' + msg + '</span>');

      var skill = skills['sanity'];
      skill.val -= val;
      if (skill.val < 0)
        skill.val = 0;

      if (val > 0)
        game.console.system('[-' + val + ' sanity, ' + skill.val + ' left]');

      if (skill.val == 0)
        game.finish('loseSanity');
    }


// receive damage
  public function damage(val: Int)
    {
      hp -= val;
      if (hp < 0)
        hp = 0;

      game.console.system('[-' + val + ' hit points, ' + hp + ' left]');

      if (hp == 0)
        game.finish('loseHP');
    }
}


typedef _SkillMod = {
  var src: String;
  var val: Int;
}
