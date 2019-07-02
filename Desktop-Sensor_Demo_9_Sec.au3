
#include <Word.au3>
#include <Excel.au3>
#include <Powerpoint.au3>
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
   ;ConsoleWrite('@@ Debug(' & $handle & ')' & @CRLF)

   If IsObj($colItems) Then
      For $objItem In $colItems
         If $objItem.ExecutablePath Then Return $objItem.ExecutablePath
      Next
   EndIf
EndFunc


MsgBox(1, "Start", "Start recording")

$sTextFile = "C:\Temp\ActivityLog.csv"
FileWriteLine( $sTextFile, @CRLF & "---- Recording Session on " & _Now() & " ----" )

$iCounter = 0
$sPrevLine = ''
$username = FileRead ( "username.txt" )
While $iCounter <= 5 ; 5 seconds, each 1 seconds
   $sTitle = WinGetTitle( "[ACTIVE]" )
   $sPath = _WinGetPath( $sTitle )
   ; $sText = WinGetText( "[ACTIVE]" )
   ; $sText = StringStripCR( $sText )
   $formattedNow = StringReplace(_Now(), " ", ";")
   ConsoleWrite("Title = " & $sTitle & @CRLF)
   $split = StringSplit($sTitle, " - ", 1)
   ConsoleWrite($split[0] & @CRLF)
   $appName = $split[$split[0]]
   ConsoleWrite("App name = " & $appName & @CRLF)
   $file = ""
   if ($appName == "Word") Then
	    ConsoleWrite("Check word" & @CRLF)
	    ;Local $word = _Word_Create()
		If @error <> 0 Then ConsoleWrite("Error creating a new Word application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended & @CRLF)
		Local $oWord = ObjGet("", "Word.Application") ;_Word_DocGet($word, 0)
		;If @error Then Exit MsgBox($MB_SYSTEMMODAL, "Word UDF: _Word_DocGet Example", _
       ; "Error accessing collection of documents." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
		;MsgBox($MB_SYSTEMMODAL, "Word UDF: _Word_DocGet Example", "First document in the document collection has been selected." & _
       ; @CRLF & "Name is: " & $oDoc.Name & @CRLF & "Total number of documents in the collection: " & @extended)

		If IsObj($oWord) then
			Local $nDocs = $oWord.Documents.Count
			Local $aWord = $oWord.ActiveDocument
			ConsoleWrite("active: " & $aWord.Name & @CRLF)
			If IsObj($aWord) Then
				$file = $aWord.Name
			EndIf
		EndIf
;	    if IsObj($oDoc) then
;		  $file = $oDoc.Name
;		else
;		  ConsoleWrite("Error creating a new Word application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended & @CRLF)
;		EndIf
   EndIf
   if ($appName == "PowerPoint") Then
	    ConsoleWrite("Check ppt")
	    Local $ppt = _PPT_PowerPointApp()
		If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Word UDF: _Word_Create Example", _
        "Error creating a new Word application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
		Local $oDoc = _PPT_PresentationName($ppt)
		;;;If @error Then Exit MsgBox($MB_SYSTEMMODAL, "Word UDF: _Word_DocGet Example", _
        ;"Error accessing collection of documents." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
		;MsgBox($MB_SYSTEMMODAL, "Word UDF: _Word_DocGet Example", "First document in the document collection has been selected." & _
        ;@CRLF & "Name is: " & $oDoc & @CRLF & "Total number of documents in the collection: " & @extended)
		$file = $oDoc
   EndIf
   ConsoleWrite("Check DOM complete" & @CRLF)
   SendRecord($file, $sPath, $appName, $username)
   FileWriteLine( $sTextFile, $formattedNow & ";" & $sTitle & ";" & $sPath & " | " & $appName)
   $iCounter = $iCounter + 1
   Sleep( 1000 )
WEnd

MsgBox( 1, "End", "Finished recording" )

;Run ( "notepad.exe " & $sTextFile, @WindowsDir, @SW_MAXIMIZE )