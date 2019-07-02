#include <MsgBoxConstants.au3>
#include "formGen.au3"
#Include <Array.au3>
; *****************************************************************************
Global $base64 = StringSplit("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/","",2)
$base64[62] = "%2B"	; +
$base64[63] = "%2F"	; /
Global Const $WdCollapseEnd = 0 ; Collapse the range to the ending point
Global $oHandleComError = ObjEvent("AutoIt.Error", "HandleComError") ; Install a custom error handler
Global $ajax = ObjCreate("MSXML2.XMLHTTP")
Global $url = "http://127.0.0.1/condor/condorinformatique/receivejobs.php"
Global $oWord = ObjGet("", "Word.Application")
If @error <> 0 Or $oWord.Documents.Count = 0 Then
   ; This is the case in which MSWord or is not present (@error <> 0)
   ; or has not documents ($oWord.Documents.Count = 0)
   $form = "File,Document,,30,,Documents (*.doc\59*.docx)|All (*.*);" _
			& "C,Enter for a New Document"
   $parms = formGen("Word File",$form,-1,"",100,100)	; create a form for call a filename
   If $parms.Item("fg_button") = "Cancel" Then Exit
   If $parms.Item("Document") <> "" Then
	  $oDoc = ObjGet($parms.Item("Document"))	; open the MSWord document
   Else
	  $oAppl = ObjCreate("Word.Application")
	  $oAppl.Visible = True
	  $oDoc = $oAppl.Documents.add	; creates  an empty document
	  $range = $oDoc.Range 			; Set range start/end at the end to the document
	  $range.Collapse($WdCollapseEnd)
	  $range.paste					; paste the clipboard
   EndIf
   $oDoc.Application.Visible = 1
Else
   ; This is the case in which MSWord is present and has one or more documents open
   Local $nDocs = $oWord.Documents.Count
   $nDoc = 1
   If $nDocs <> 01 Then
	  Local $docs = ""
	  For $i = 1 to $nDocs
		 consoleWrite($oWord.Documents($i).Name  & @CRLF)
		 $docs &= "|" & $i & "=" & $oWord.Documents($i).Name
	  Next
	  $form = "CMB,Document,,20,," & StringMid($docs,2)
	  $parms = formGen("Word Files",$form,-1,"",100,100)	; create a form to choose which document to process
	  If $parms.Item("fg_button") = "Cancel" Then Exit
	  $nDoc = $parms.Item("Document")
   EndIf
   $oDoc = $oWord.Documents($nDoc)
EndIf
$aFields = StringSplit("Nation|Title|Notes|Town|Deadline","|",2)
$itemCount = 0
$oParag = $oDoc.Paragraphs
$nParag = $oParag.count
For $paragraphCount = 1 To $nParag
   $parag = StringReplace($oParag($paragraphCount).Range.Text,chr(11),"")	; clear VT
   $aExtract = StringRegExp($parag, '^(.+): (.+)(Ref\..*) - City: (.+) - Deadline: (\d\d/\d\d/\d\d\d\d)', $STR_REGEXPARRAYGLOBALMATCH)
   If isArray($aExtract) Then
	  $itemCount += 1
	  $aExtract[4] = StringRegExpReplace($aExtract[4], '(\d{2})/(\d{2})/(\d{4})', '$3/$2/$1')	; date from dd/mm/yyyy to yyy/mm/dd
	  $data = ""
	  For $i = 0 To UBound($aExtract) - 1
		 $data &= "&" & $aFields[$i] & "=" & encode64($aExtract[$i])
	  Next
	  $aCategory = StringRegExp($aExtract[1], '.*in (.*)', $STR_REGEXPARRAYGLOBALMATCH)	; Category
	  If isArray($aCategory) Then $data &= "&Category=" & encode64($aCategory[0])	; extracts the study field
	  For $hLink In $oParag($paragraphCount).Range.Hyperlinks
		  $link = $hLink.Address
	  Next
	  $data &= "&Link=" & encode64($link)
	  ConsoleWrite(StringMid($data,2) & @CRLF)
	  $res = ajax($url,StringMid($data,2))
	  If $res <> 1 Then ConsoleWrite("--> " & $res & @CRLF)
   EndIf
Next
MsgBox(0,"",$itemCount & " Jobs")
Func ajax($url,$data)
   $ajax.open("POST", $url, true)	; synchronous !
   $ajax.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
   $ajax.send($data)
   Local $hTimer = TimerInit() ; Begin the timer and store in a variable.
   While TimerDiff($hTimer) < 10000
      If $ajax.readyState == 4 Then
		 If $ajax.status = 200 Then return $ajax.responseText
	  EndIf
	  Sleep(10)
   WEnd
   return "Timeout!"
EndFunc
Func encode64($in)
   $bin = 0
   $out = ""
   For $i = 1 to StringLen($in)
	  $bin = BitShift($bin,-8)
	  $bin += Asc(StringMid($in,$i,1))
	  If Mod($i,3) = 0 Then
		 $out &= encode6($bin)
		 $bin = 0
	  EndIf
   Next
   If Mod(StringLen($in),3) <> 0 Then $out &= encode6($bin,Mod(StringLen($in),3))
   return $out
EndFunc
Func encode6($bin,$l=3)
   If $l <> 3 Then $bin =  BitShift($bin,-8*(3-$l))
   $out = ""
   For $i=3 To 3-$l Step -1
	  $cod6 = BitShift($bin,$i*6)
	  $bin -= BitShift($cod6,-$i*6)
	 $out &= $base64[$cod6]
   Next
   return $out
EndFunc
Func displayDict($dict,$title="")
	Local $aDict[$dict.Count][2]
	$ak = $dict.Keys
	$av = $dict.Items
	For $i=0 to UBound($ak)-1
		$aDict[$i][0] = $ak[$i]
		$aDict[$i][1] = $av[$i]
	Next
	_ArrayDisplay($aDict,$title)
 EndFunc
Func HandleComError()	; This is a custom error handler
   $sHexNumber = Hex($oHandleComError.number, 8)
   MsgBox($MB_OK, "", "COM Error at line " & $oHandleComError.scriptline & @CRLF & _
            "Code is: " & $sHexNumber & " "  & $oHandleComError & " "  & $oHandleComError.windescription)
EndFunc   ;==>ErrFunc