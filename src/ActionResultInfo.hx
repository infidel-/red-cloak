// action result info (also used for object actions)

typedef ActionResultInfo = {
  var type: _ActionResultType;
  @:optional var info: String;
  @:optional var value: Int;
}

enum _ActionResultType
{
  RESULT_CHAT;
  RESULT_CHAT_FINISH_SUCCESS;
  RESULT_CHAT_FINISH_FAIL;
  RESULT_CHAT_INTEREST;
}
