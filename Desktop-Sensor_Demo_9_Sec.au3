#include <Timers.au3>
#include <Date.au3>
#include <Influx.au3>

#include <MsgBoxConstants.au3>
#include "formGen.au3"
#Include <Array.au3>


Func _WinGetPath($Title="", $strComputer='localhost')
    $win = WinGetTitle($Title)
    $pid = WinGetProcess($win)
	$handle = WinGetHandle($win)
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""
	$objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery ("SELECT * FROM Win32_Process WHERE ProcessId = " & $pid, "WQL", _
		 $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
	  For $objItem In $colItems
		 If $objItem.ExecutablePath Then Return $objItem.ExecutablePath
	  Next
	EndIf
EndFunc


MsgBox(1, "Start", "Start recording")
$idleTimeThreshold = 600 * 1000 ; 10 minutes
$recordInterval = 1000 ; 1 sec
$oErrorHandler = ObjEvent("AutoIt.Error", "ComErrorHandler")
$sTextFile = "C:\Temp\ActivityLog.csv"
FileWriteLine( $sTextFile, @CRLF & "---- Recording Session on " & _Now() & " ----" )

$iCounter = 0
$sPrevLine = ''
$username = FileRead ( "username.txt" )
While $iCounter <= 5 ; 5 seconds, each 1 seconds
	Local $iIdleTime = _Timer_GetIdleTime()
	If $idleTimeThreshold < $iIdleTime Then
		Sleep($recordInterval)
		ConsoleWrite("idle" & @CRLF)
		$iCounter = $iCounter + 1
		ContinueLoop
	EndIf
	$sTitle = WinGetTitle( "[ACTIVE]" )
	$sPath = _WinGetPath( $sTitle )
	$formattedNow = StringReplace(_Now(), " ", ";")
	ConsoleWrite("Title = " & $sTitle & @CRLF)
	$split = StringSplit($sTitle, " - ", 1)
	ConsoleWrite($split[0] & @CRLF)
	$appName = $split[$split[0]]
	ConsoleWrite("App name = " & $appName & @CRLF)
	$file = ""
	if ($appName == "Word") Then
	    ConsoleWrite("Check word" & @CRLF)
		If @error <> 0 Then ConsoleWrite("Error creating a new Word application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended & @CRLF)
		Local $oWord = ObjGet("", "Word.Application")

		If IsObj($oWord) then
			;Local $nDocs = $oWord.Documents.Count
			Local $aWord = $oWord.ActiveDocument
			ConsoleWrite("active: " & $aWord.Name & @CRLF)
			If IsObj($aWord) Then
				$file = $aWord.Name
			EndIf
		EndIf
	EndIf
	if ($appName == "PowerPoint") Then
	    ConsoleWrite("Check ppt" & @CRLF)
	    Local $ppt = ObjGet("", "PowerPoint.Application") ; Create an Excel Object
		If IsObj($ppt) Then
			$file = $ppt.ActivePresentation.Name
			If @error Then

			EndIf
		EndIf
	EndIf
	if ($appName == "Excel") Then
	    ConsoleWrite("Check excel" & @CRLF)

		Local $oExcel = ObjGet("", "Excel.Application") ; Create an Excel Object
		If IsObj($oExcel) Then
			$file = $oExcel.ActiveWorkBook.Name
			If @error Then

			EndIf
		EndIf
	EndIf
	ConsoleWrite("Check DOM complete" & @CRLF)
	SendRecord($file, $sPath, $appName, $username)
	FileWriteLine( $sTextFile, $formattedNow & ";" & $sTitle & ";" & $sPath & " | " & $appName)
	$iCounter = $iCounter + 1
	Sleep( $recordInterval )
WEnd


Func ComErrorHandler()
;ignore
EndFunc

MsgBox( 1, "End", "Finished recording" )

;Run ( "notepad.exe " & $sTextFile, @WindowsDir, @SW_MAXIMIZE )