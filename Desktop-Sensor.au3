#include <Date.au3>
MsgBox(1, "Start", "Start recording")

$sTextFile = "C:\Temp\ActivityLog.txt"
FileWriteLine( $sTextFile, @CRLF & "---- Recording Session on " & _Now() & " ----" )

$iCounter = 0
$sPrevLine = ''
While $iCounter <= 2880 ; one working day, each 10 seconds
   Sleep( 10000 )
   $sTitle = WinGetTitle( "[ACTIVE]" )
   ; $sText = WinGetText( "[ACTIVE]" )
   ; $sText = StringStripCR( $sText )

   ; check if line exist already, and if not, write it
   $sPrevLine = StringMid( FileReadLine( $sTextFile, -1 ), 21)
   If Not ( $sPrevLine == $sTitle ) Then
	  FileWriteLine( $sTextFile, _Now() & ' ' & $sTitle )
   EndIf
   $iCounter = $iCounter + 1
WEnd

MsgBox( 1, "End", "Finished recording" )

Run ( "notepad.exe " & $sTextFile, @WindowsDir, @SW_MAXIMIZE )