#include "WinHttp.au3"

Global $iEventError = 0

Func SendRecord($file, $process, $appName, $user = "Max")
	ConsoleWrite("Sending record to influx" & @CRLF)
	$oMyError = ObjEvent("AutoIt.Error", "ErrFunc")

	$payload = 'activity_tracking,user='& $user &' file="'& $file &'",process="'& $process &'",app="'& $appName & '"'
	ConsoleWrite($payload  & @CRLF)
	HttpPost("https://tsdb.informatik.uni-rostock.de:8086/write?db=loggerTestDB", $payload)
	If $iEventError Then
		$iEventError = 0 ; Reset after displaying a COM Error occurred
	EndIf
EndFunc

Func ErrFunc()
	ConsoleWrite("Error sending record" & @CRLF)
    $iEventError = 1 ; Use to check when a COM Error occurs
EndFunc

