#include "WinHttp.au3"
$oMyError = ObjEvent("AutoIt.Error", "ErrFunc")
$MD5 = HttpPost("https://tsdb.informatik.uni-rostock.2de:8086/write?db=loggerTestDB", "cpu_load_short,host=server01,region=us-west value=0.64")
If @error Then
	MsgBox(64, "MD5", "23")
else
	MsgBox(64, "MD5", $MD5)
Endif