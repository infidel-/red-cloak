import js.jquery.JQuery;
import js.Browser;

// Console adapted to Haxe from JS console by Will Hilton
// https://codepen.io/wmhilton/pen/PbGqQG

class ConsoleJS
{
  var game: Game;
  var console: JQuery;
  var output: JQuery;
  var input: JQuery;
  var inner: JQuery;
  var md: MarkDown;
  var cursorHistory: Int;
  var cmdHistory: Array<String>;

  public function new(g: Game)
    {
      game = g;
      cmdHistory = new Array();
      output = new JQuery('#outputs');
      console = new JQuery('.console');
      inner = new JQuery('.console-inner');
      md = untyped Browser.window.markdownit({
        html: true,
        linkify: true,
        breaks: true
      });
      input = new JQuery('.console-input');
      input.on('keydown', onKeyDown);

      untyped __js__("$('.console').click(function() {
          $('.console-input').focus();
        });");
      untyped __js__("autosize($('textarea'));");
    }


// handle keyboard keys
  function onKeyDown(event)
    {
//      trace(event);

      // up - scroll history
      if (event.which == 38 ||
          (event.key == 'k' && event.ctrlKey == true))
        {
          event.preventDefault();
          if (cursorHistory == 0)
            return;
          cursorHistory--;
          input.val(cmdHistory[cursorHistory]);
        }

      // down - scroll history
      else if (event.which == 40 ||
          (event.key == 'j' && event.ctrlKey == true))
        {
          event.preventDefault();
          if (cursorHistory > cmdHistory.length - 1)
            {
              input.val('');
              return;
            }
          cursorHistory++;
          input.val(cmdHistory[cursorHistory]);
        }

      // enter - handle command
      else if (event.which == 13)
        {
          // get command text and display it
          event.preventDefault();
          var cmd = StringTools.trim(input.val());
          if (cmd.length == 0)
            return;

          // show command
          if (cmdHistory[cmdHistory.length - 1] != cmd)
            {
              cmdHistory.push(cmd);
              if (cmdHistory.length > 10)
                cmdHistory.shift();
            }
          cursorHistory = cmdHistory.length;
          output.append("<div class='output-cmd'>" + cmd + "</div>");
          input.val('');
          untyped __js__("autosize.update($('textarea'));");
          new JQuery("html, body").animate({
            scrollTop: new JQuery(Browser.document).height()
          }, 300);
//          trace(cmd);

          // run command
          try {
            var ret = game.console.runCommand(cmd);
            if (ret == 0) // could not parse or run this command
              {
                print('I did not understand that.');
                return;
              }
            }
          catch (e: Dynamic)
            {
              print('**Exception: ' + 
                haxe.CallStack.toString(haxe.CallStack.exceptionStack()) +
                '**');
            }
        }
    }


// get last command from history
  public inline function getLast(): String
    {
      if (cmdHistory.length == null)
        return null;
      else return cmdHistory[cmdHistory.length - 1];
    }


// remove last command from history
  public inline function removeLast()
    {
      if (cmdHistory.length > 0)
        cmdHistory.pop();
    }


// clear all text
  public inline function clear()
    {
      output.html('');
    }


// print line of text
  public function print(s: String)
    {
      output.append(md.render(s));
      console.scrollTop(inner.height());
    }


// print error string
  public inline function error(s: String)
    {
      print('<span class="consoleError">' + s + '</span>');
    }


// print debug string
  public inline function debug(s: String)
    {
#if mydebug
      output.append('<span class="consoleDebug">' + s + '</span><br>');
      console.scrollTop(inner.height());
#end
    }
}


// https://github.com/markdown-it/markdown-it extern

extern class MarkDown
{
  public function render(s: String): String;
}
