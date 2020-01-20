// game constants

class Const
{
// these keywords are ignored by the command parser
  public static var ignoredKeywords = [
    '', // empty word created by whitespace in the middle of the command
    'a',
    'at',
    'in',
    'is',
    'on',
    'the',
  ];


// roll fail strings
  public static var stringsFail: Map<String, Array<String>> = [
    'idea' => [
      'Apparently, you have no clue about it.',
      'You have no idea why that is important.',
    ],
    'spotHidden' => [
      'You fail to notice anything special here.',
      'Nothing catches your eye.',
      'There is nothing here that attracts your attention.',
    ],
    'strength' => [
      'Your strength fails you.',
    ],
  ];


// common string
  public static var strings: Map<String, Array<String>> = [
    'nothingImportant' => [
      'There is nothing important here.',
      'You do not see anything important here.',
    ]
  ];

// canned strings

// trace call stack for debug
  public static inline function traceStack()
    {
      trace(haxe.CallStack.toString(haxe.CallStack.callStack()));
    }


  public static function dice(x: Int, y: Int)
    {
      var r = 0;
      for (i in 0...x)
        r += 1 + Std.random(y);
      return r;
    }
}
