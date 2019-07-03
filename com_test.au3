Global $oMyError
$oErrorHandler = ObjEvent("AutoIt.Error", "ComErrorHandler")
Local $ppt = ObjGet("", "PowerPoint.Application") ; Create an Excel Object
$file = "default"
If IsObj($ppt) Then
	$file = $ppt.ActivePresentation.Name
	If @error Then

	EndIf
EndIf
ConsoleWrite("" & $file & @CRLF)

$oErrorHandler = 0

Func ComErrorHandler()
;ignore
EndFunc