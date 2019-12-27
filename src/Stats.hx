// player/npc stats

@:structInit class Stats
{
  public var str: Int;
  public var con: Int;
  public var dex: Int;
  public var siz: Int;
  public var int: Int;
  public var pow: Int;
  public var cha: Int;
  public var edu: Int;


  public function new(str, con, dex, siz, int, pow, cha, edu)
    {
      this.str = str;
      this.con = con;
      this.dex = dex;
      this.siz = siz;
      this.int = int;
      this.pow = pow;
      this.cha = cha;
      this.edu = edu;
    }
}
