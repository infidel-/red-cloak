// player/npc skill

import SkillConst;

@:structInit class Skill
{
  public var val: Int;
  public var info: _SkillInfo;

  public function new(val: Int, info: _SkillInfo)
    {
      this.val = val;
      this.info = info;
    }
}
