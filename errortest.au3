#include "WinHttp.au3"

Global $iEventError = 0
SendRecord()

Func SendRecord($file, $process, $appName)
	$oMyError = ObjEvent("AutoIt.Error", "ErrFunc")

	HttpPost("https://tsdb.informatik.uni-rostock.de:8086/write?db=loggerTestDB", "activity_tracking,user=max, file="& $file &",process="& $process &",app="& $appName &"")
	If $iEventError Then
		$iEventError = 0 ; Reset after displaying a COM Error occurred
	EndIf
	Exit
EndFunc

Func ErrFunc()
    $iEventError = 1 ; Use to check when a COM Error occurs
EndFunc

