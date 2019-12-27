// adventure state

import infos.AdventureInfo;

class Adventure
{
  public var game: Game;
  public var info: AdventureInfo;

  public function new(g: Game, info: AdventureInfo)
    {
      game = g;
      this.info = info;
    }
}
