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


  public static var stringsFail: Map<String, Array<String>> = [
    'idea' => [
      'Apparently, you have no clue about it.',
      'You have no idea why that is important.',
    ],
  ];

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
