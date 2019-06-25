#include "WinHttp.au3"

Global $MD5 = HttpPost("http://127.0.0.1:8080/words", "password=WeWantThisAsMd5")
MsgBox(64, "MD5", $MD5)