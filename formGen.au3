; =======================================================================================
; Title .........: Form Handler
; Description ...: Form generator
; Requirement(s).: Autoit v3.3.14.2
; Author(s) .....: Giovanni Rossati (El Condor)
; Version........: 0.6.0
; Date...........: 4 March 2016
; =======================================================================================
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <WindowsConstants.au3>
#Include <Array.au3>
Global Const $FHSS_SUNKEN = 0x1000
Global Const $SS_CENTER = 0x01
;Global Const $DTS_SHORTDATEFORMAT = 0
;Global Const $DTS_LONGDATEFORMAT = 4
;Global Const $DTS_TIMEFORMAT = 9
Func formGen($title,$records,$GUI=-1,$cBack="",$GUILeft=-1,$GUITop=-1)
   If $GUILeft = -1 Then $GUILeft = ($GUI=-1)? 100:0
   If $GUITop = -1 Then $GUITop = ($GUI=-1)?100:0
   If $cBack = "" Then $cBack="DoNothing"
   Global $esc = false
   Global $fhaRecords = StringRegExp($records,"([^;]+);?",3) ; array splitted by ; without empty
   $width = 0		; buttons space
   $widthLab = 0
   Const $editSize = 50
   Global $buttonWidth = 60
   $aButtons = StringSplit("","!",2)	; create array for handle buttons (trick for create and insert first item)
   Global $fhDict = ObjCreate("Scripting.Dictionary")   ; Create a Scripting Dictionary
   Global $fhDictW = ObjCreate("Scripting.Dictionary")   ; Create a widget Scripting Dictionary (name -> ID)
   Global $fhDictWID = ObjCreate("Scripting.Dictionary")   ; Create a widget Scripting Dictionary (ID -> name)
   Global $fhDictCRef = ObjCreate("Scripting.Dictionary")   ; Create a widget cross Reference Scripting Dictionary
   Global $fhControlsDict = ObjCreate("Scripting.Dictionary")   ; Create a Scripting Dictionary for ControlSend
   Global $fhAfterDict = ObjCreate("Scripting.Dictionary")   ; Create a Scripting Dictionary for ControlSend
   $nWidgets = 0
   Local $convertType[] = ["TEXT","T","PSW","P","FILE","F","SLIDER","S","RDB","R","COMMENT","C","CONTROL","CHECK"]
   $convertTypeDict = ObjCreate("Scripting.Dictionary")
   For $i = 0 To UBound($convertType)-2 Step 2
	  $convertTypeDict.Add($convertType[$i],$convertType[$i+1])
   Next
   For $iControls=0 To UBound($fhaRecords)-1		; control size and parameters arrangement (Type upper, Label missing, split key value, deMask)
	  If StringLeft($fhaRecords[$iControls],2) = "//" Then ContinueLoop		; comment
	  $aEl = StringSplit($fhaRecords[$iControls] & ",,,,,,,",",",2)
	  For $i=4 to UBound($aEl) -1
		 $aEl[$i] = deMask($aEl[$i])
	  Next
	  $aEl[0] = StringUpper($aEl[0])		; uppercase type
	  if $convertTypeDict.Exists($aEl[0]) Then $aEl[0] = $convertTypeDict.Item($aEl[0])
	  If ($aEl[0] == "CHECK") Then
		 For $i = 2 to UBound($aEl)-1
			If $aEl[$i] <> "" Then addControl($aEl[1],$aEl[$i])
		 Next
		 ContinueLoop
	  EndIf
	  If ($aEl[0] == "AFTER") Then
		 $fhAfterDict.Item($aEl[1]) = $aEl[2]
		 ContinueLoop
	  EndIf
	  If ($aEl[0] == "REQUIRED") Then
		 For $i = 1 to UBound($aEl)-1
			If $aEl[$i] <> "" Then addControl($aEl[$i],"required")
		 Next
		 ContinueLoop
	  EndIf
	  Switch $aEl[0]
		  Case "CMB","CMT","R","BL"
			  $aEl[5] = splitKeyValue($aEl[5],$aEl[1],$aEl[4])	; for split key and value of combo, button list and radiobuttons
		  Case "S"
			  If $aEl[5] = "" Then $aEl[5] = "0 100"		; slider default range
	  EndSwitch
	  if Number($aEl[3]) = 0 Then $aEl[3] = (StringLen($aEl[4]) > 0) ? StringLen($aEl[4]) : 20	; length
	  $aEl[2] = ($aEl[2] = "")?$aEl[1]:deMask($aEl[2])	; if no label label = name
	  If $aEl[0] = "" Or $aEl[0] = "M" Then $aEl[0] = "T" & $aEl[0]	; text default
	  If $aEl[0] <> "C" and StringLen($aEl[2]) > StringLen($widthLab) Then $widthLab = $aEl[2]	; not for comments
	  If 8*$aEl[3] > $width Then $width = 8*$aEl[3]	; field width
	  If StringInStr(",B,BL,CKB,CMB,CMT,C,F,D,DATE,N,P,R,S,T,TIME,U,X,",$aEl[0]) = 0 Then
		 $aEl[2] = $aEl[0] & " unknown type"
		 $aEl[0] = "C"	; type error = comment with error
		 $aEl[5] = "ff0000"		; color
	  Endif
	  $fhaRecords[$nWidgets] = $aEl
	  $nWidgets = $nWidgets + 1
   Next
   ReDim $fhaRecords[$nWidgets]
   If $GUI = -1 Then
	  $frmGen = GUICreate($title, -1,-1, $GUILeft, $GUITop)
   Else
	  $optOrig = Opt("PixelCoordMode", 2) ; 1=absolute, 0=relative, 2=clientLocal
		Local $var = PixelGetColor(0,  0)
		Opt("PixelCoordMode", $optOrig)		; restore opt
		Local $size = WinGetClientSize("[active]")
		$frmGen = GUICreate($title, $size[0]-$GUILeft,$size[1]-$GUITop, $GUILeft, $GUITop,$WS_CHILD,Default,$GUI)
		GUISetBkColor($var)
	EndIf
	AutoItSetOption("GUIResizeMode",$GUI_DOCKALL)	;  block scaling
	GUISetState(@SW_SHOW)
	$hidden = GUICtrlCreateLabel($widthLab & " ",10,0,-1,-1)	; invisible control for take value of button clicked
	GUICtrlSetState(-1,$GUI_HIDE)
	$aCoords = ControlGetPos("[ACTIVE]","",$hidden)
	$widthLab = $aCoords[2] * 1.25		; for label are bold
	If $width >  $editSize * 8 Then $width =  $editSize * 8	; field too long
	$totalWidth = (($width+$widthLab) > 150)? $width+$widthLab+50:200		; minimum width
	$deltaY = 27		; space betweeen controls
	$left = 10
	$top = 22
	$WidgetTypes = 0x00		; for handle buttons 0x02 = Buttons, 0x04 = data controls, 0x00 = Unmodifiable & Comments
   For $i=0 To $nWidgets -1		; create form ***********************************************************
	  $aEl = $fhaRecords[$i]
	  $ctrl = $aEl[0]
	  If StringInStr("BLUC",$aEl[0]) = 0 Then $WidgetTypes = BitOR($WidgetTypes,0x04)	; must contains Cancel button if not Button, Undefined or Comment
	  If StringLeft($ctrl,1) = "B" Then		; buttons field
		 If $ctrl = "BL" Then	; button List
			$WidgetTypes = BitOR($WidgetTypes,0x02)
			$aList = StringSplit($aEl[5],"|",2)
			For $j = 0 To UBound($aList) -1
			   $fhDictW.Item($aEl[1] & $aList[$j]) = GUICtrlCreateButton($aEl[2], $left,$top,$buttonWidth)
			   GUICtrlCreateLabel($aList[$j], $widthLab+20,$top+5,8*$aEl[3])
			   $fhDictCRef.Item($aEl[1] & $aList[$j]) = $i
			   $top = $top + $deltaY
			Next
		 Else
			If $fhAfterDict.Exists($aEl[1]) Then
			   $aCoords = ControlGetPos("[ACTIVE]","",$fhDictW.Item($fhAfterDict.Item($aEl[1])))
			   $ButtonPos = $aCoords[0] + $aCoords[2] + 5
			   $fhDictW.Item($aEl[1]) = GUICtrlCreateButton($aEl[2],$ButtonPos,$aCoords[1] -2,$buttonWidth)
			   If $ButtonPos + $buttonWidth + 10 > $totalWidth Then $totalWidth = $ButtonPos + $buttonWidth + 10
			Else
			   $WidgetTypes = BitOR($WidgetTypes,0x02)
			   ArrayAdd($aButtons,array($ctrl, $aEl[1], $aEl[2]))
			EndIf
		 EndIf
	  Else
		 If $ctrl = "C" Then
			 $aEl[6] = GUICtrlCreateLabel(((stringlen($aEl[2]) > 1)? $aEl[2]:repeatString($aEl[2],$widthLab+$width/8)), $left, $top,$totalWidth-2*$left)	; comments
			 if StringLen($aEl[5]) > 3 Then GUICtrlSetColor($aEl[6], Dec($aEl[5]))
		 Else
			 $aEl[6] = GUICtrlCreateLabel($aEl[2], $left, $top+2,$widthLab,-1)	; $aEl[6] ID Label
		 EndIf
		 GUICtrlSetFont(-1, 9,650)
		 If $ctrl = "CKB" Then
			$fhDictW.Item($aEl[1]) = GUICtrlCreateCheckbox(" " & (($aEl[5] = "")?"  ":$aEl[5]),$widthLab+15,$top)
		 Elseif $ctrl = "CMB" Or $ctrl = "CMT"  Then
			$fhDictW.Item($aEl[1]) = GUICtrlCreateCombo("",$widthLab+15,$top,8*$aEl[3],-1,($ctrl = "CMB")?$CBS_DROPDOWNLIST:$CBS_DROPDOWN)
		 ElseIf $ctrl = "U" Then	; unmodifiable field
			$fhDictW.Item($aEl[1]) = GUICtrlCreateLabel($aEl[4], $widthLab+15,$top,Min($aEl[3], $editSize)*8,$deltaY+0.5*$deltaY*(Ceiling($aEl[3]/$editSize)-1)-2,$FHSS_SUNKEN)
		 ElseIf $ctrl = "R" Then	; Radio buttons
			$aList = StringSplit($aEl[5],"|",2)
			$wRadio = $widthLab+15
			$fhDictW.Item($aEl[1]) = GUICtrlCreateEdit("",10,0,-1,-1) 	; for put the value of radiobutton checked
			GUICtrlSetState(-1,$GUI_HIDE)
			GUIStartGroup()
			For $j = 0 To UBound($aList) -1
				 $IDRadio = GUICtrlCreateRadio($aList[$j],$wRadio,$top)
				 $fhDictW.add($aEl[1] & $aList[$j],$IDRadio)		; name & value -> ID
				 if $aEl[4] = $aList[$j] Then $fhDict.Item($aEl[1]) = $IDRadio
				 $aCoords = ControlGetPos("[ACTIVE]","",$IDRadio)
				 $wRadio += $aCoords[2] + 10
				 $fhDictCRef.Item($aEl[1] & $aList[$j]) = $i
			Next
		 ElseIf $ctrl = "S" Then	; Slider
			   $fhDictW.Item($aEl[1]) = GUICtrlCreateSlider($widthLab+15,$top, $aEl[3]*8, 20)
			   $aEl[8] = GUICtrlCreateLabel("",$widthLab+$aEl[3]*8+20,$top,40,20,BitOR($FHSS_SUNKEN,$ES_RIGHT))
			   $aLim = StringRegExp($aEl[5],'[-+]?[0-9]+\.?[0-9]*', 3)
			   $delta = abs($aLim[1]-$aLim[0])
			   $aEl[7] = ($delta > 99) ? 0 : ($delta > 10) ? floor(log10($delta)) : abs(floor(log10($delta)))+2	; decimals
			ElseIf $ctrl = "DATE" Then	; Date
			   $fhDictW.Item($aEl[1]) = GUICtrlCreateDate($aEL[4], $widthLab+15,$top, $aEl[3]*8, 20,$DTS_SHORTDATEFORMAT)
			ElseIf $ctrl = "TIME" Then	; Time
			   $fhDictW.Item($aEl[1]) = GUICtrlCreateDate($aEL[4], $widthLab+15,$top, $aEl[3]*8, 20,$DTS_TIMEFORMAT)
			ElseIf $ctrl <> "C" Then
			   $style = ($aEl[3] > 50)?bitOr($ES_WANTRETURN,$WS_VSCROLL,$ES_MULTILINE,$ES_AUTOVSCROLL):$ES_AUTOHSCROLL
			   If $ctrl = "N" Then
				  If $aEl[5] = "" Then
					 $style = bitOR($ES_NUMBER,$ES_RIGHT,$style)
				  Else
					 $tst = StringRegExpReplace ($aEl[5], "\.(\d+)$", "(\\.\\d{1,$1})?" ) ; possible decimals
					 $tst = StringRegExpReplace ($tst, "(\d+)", "\\d{1,$1}" ,1) ; integers
					 $tst = StringRegExpReplace ($tst, "^[Ss]", "[-+]?" )	; possible sign
					 addControl($aEl[1],"pattern=^" & $tst & "$")
				  EndIf
			   EndIf
			   If $ctrl = "P" Then $style = bitOR($ES_PASSWORD,$style)
			   $fhDictW.Item($aEl[1]) = GUICtrlCreateInput($aEl[4],$widthLab+15,$top,Min($aEl[3], $editSize)*8,$deltaY+0.5*$deltaY*(Ceiling($aEl[3]/$editSize)-1)-5, bitOR($style,$FHSS_SUNKEN))
			   if StringInStr("FDX",$ctrl) > 0 Then		; File, Directory and eXtended
				  $fhDictWID.Item(GUICtrlCreateButton(" ... ",$totalWidth -30, $top,-1,$deltaY-5)) = $aEl[1]
			   EndIf
			EndIf
			$top = $top + $deltaY + $deltaY * 0.5*(Ceiling(($aEl[3])/$editSize)-1)	; for textarea
	  EndIf
	  $fhaRecords[$i] = $aEl	; restore
	  $fhDictCRef($aEl[1]) = $i
   NEXT
   ; handle final buttons
   If  UBound($fhaRecords) <> 1 Or $aEl[0] <> "CMB" Then	; only combo box no Ok and Reset
	  If BitAND($WidgetTypes,0x02) = 0x00 Then
		 ArrayAdd($aButtons, array("BO","fg_Ok","Ok"))
		 $fhDictCRef.Item("fg_Ok") = arrayAdd($fhaRecords,StringSplit("BO,fg_Ok,Ok,,,,", "," ,2))
	  EndIf
	  If BitAND($WidgetTypes,0x04) = 0x04 Then
		 ArrayAdd($aButtons, array("BR","fg_Reset","Reset"))
		 $fhDictCRef.Item("fg_Reset") = arrayAdd($fhaRecords,StringSplit("BR,fg_Reset,Reset,,,,", ",", 2))
	  EndIf
	  If $WidgetTypes <> 0x00 Then
		 ArrayAdd($aButtons, array("BI","fg_Cancel","Cancel"))
		 $fhDictCRef.Item("fg_Cancel") = arrayAdd($fhaRecords,StringSplit("BI,fg_Cancel,Cancel,,,,", ",", 2))
	  EndIf
   EndIf
   $leftBtn = ($totalWidth - (($buttonWidth + 5) * (UBound($aButtons)-1)-5)) / 2
   For $i = 1 To UBound($aButtons) - 1
	  $aBtn = $aButtons[$i]
	  $btn = GUICtrlCreateButton($aBtn[2], $leftBtn + ($buttonWidth + 5) * ($i-1), $top+7, $buttonWidth)
	  $fhDictW.Item($aBtn[1]) = $btn		; name
   Next
   $aDictW = $fhDictW.Keys
   For $i = 0 to UBound($aDictW) - 1		; key = name, value = ID
	  $fhDictWID.Item($fhDictW.Item($aDictW[$i])) = $aDictW[$i]
   Next
   setDefaults($fhaRecords,$cBack)		; set defaults values
   HotKeySet("{ESC}", "handleKeys")
   If $GUI = -1 Then
	  WinMove("[ACTIVE]","", Default,Default,$totalWidth,$top+80)	; resize window
   Else
	  GUICtrlCreateLabel($title,0,2,$totalWidth,20,$SS_CENTER)
	  GUICtrlSetFont(-1,10,600)
   EndIf
   While 1	; Start event loop
	  $Msgb = GUIGetMsg()
	  If $esc Then $msgb = $GUI_EVENT_CLOSE
	  If $fhDictWID.Exists($msgB) Then
		 $aEl = $fhaRecords[$fhDictCRef.Item($fhDictWID.Item($msgB))]
		 If $aEl[0] = "BI" Then			; Ignore
			 $msgb = $GUI_EVENT_CLOSE
		 ElseIf $aEl[0] = "BR" Then		; Reset
			SetDefaults($fhaRecords,$cBack)
		 ElseIf $aEl[0] = "BO" Or $aEl[0] = "B" Then		; OK 0r Personalized Ok
			If $aEl[5] <> "" Then
			   Call($aEl[5],GetData($aEl[1] & "," & $fhDictWID.Item($msgB),$cBack))		; CallBack
			Else
			   $ret = GetData("," & (($aEl[4] <> "") ? $aEl[4]: $aEl[2]),$cBack)
			   If $ret <> 1 Then ExitLoop	; 1 is return code of MsgBox
			EndIf
		 ElseIf $aEl[0] = "BL" Then
			$ret = GetData($aEl[1] & "," & $fhDict.Item($fhDictWID.Item($msgB)),$cBack)
			ExitLoop
		 ElseIf StringInStr("FDX",$aEl[0]) > 0 Then
			If $aEl[0] = "F" Then
			   $risp = FileOpenDialog("Choose file", ($aEl[4] = "") ? @DocumentsCommonDir:$aEl[4], ($aEl[5] = "") ? "All (*.*)" :$aEl[5])
			ElseIf $aEl[0] = "D" Then
			   $risp = FileSelectFolder("Choose folder","$initDir",1+4,$aEl[4])	; Create Folder and Edit
			ElseIf $aEl[0] = "X" Then
			   $risp = Call($aEl[5],$aEl[0])
			EndIf
			If $risp <> "" Then GUICtrlSetData($fhDictW.Item($aEl[1]),$risp)
		 ElseIf $aEl[0] = "R" Then
			If BitAND(GUICtrlRead($msgb),$GUI_CHECKED) = $GUI_CHECKED Then GUICtrlSetData($fhdictW.Item($aEl[1]),$msgB)
		 ElseIf $aEl[0] = "S" Then		; Slider
			$aLim = StringRegExp($aEl[5],'[-+]?[0-9]+\.?[0-9]*', 3)
			GUICtrlSetData($aEl[8],StringFormat("%." & $aEl[7] & "f",$aLim[0]+GUICtrlRead($msgb)*($aLim[1]-$aLim[0])/100))
		 ElseIf $aEl[0] = "CMB" And UBound($fhaRecords) = 1 Then	; exit if only one combo box
			$ret = GetData("," & (($aEl[4] <> "") ? $aEl[4]: $aEl[2]),$cBack)
			ExitLoop
		 Else
			$error = checkData($aEl,GUICtrlRead(widgetID($aEl[1])))
			If $error <> "" Then msgbox(0,$aEl[1],$error,2)
		 EndIf
	  EndIf
	  If $msgB = $GUI_EVENT_CLOSE Then ExitLoop
	  Call($cBack,$msgB)
   Wend
   GUIDelete($frmGen)
   If $msgB = $GUI_EVENT_CLOSE Then $ret = GetData(",Cancel",$cBack)
   Call($cBack,-3)
   Return $ret
EndFunc
Func GetData($btn,$cBack="DoNothing")	; $btn = fieldname,value
   $fhReturn = ObjCreate("Scripting.Dictionary")
   Local $aBtn = StringSplit($btn,",",2)
   $errors = ""
   If $aBtn[1] = "Cancel" Then
	  $fhReturn.Item("fg_button") = "Cancel"
	  return $fhReturn
   EndIf
   Call($cBack,-2)		; get data
   For $i=0 To UBound($fhaRecords)-1
	  $aEl = $fhaRecords[$i]
	  If StringLeft($aEl[0],1) = "B" Then
		 If $aEl[1] = $aBtn[0] Then $fhReturn.Item($aEl[1]) = $aBtn[1]
	  Else
		 If $aEl[0] = "S" Then
			$fhReturn.Item($aEl[1]) = GUICtrlRead($aEl[8])
		 ElseIf $aEl[0] = "R" Then
			$fhReturn.Item($aEl[1]) = $fhDict.Item($fhDictWID.Item(Number(GUICtrlRead(widgetID($aEl[1])))))
		 Else
			$fhReturn.Item($aEl[1]) = GUICtrlRead(widgetID($aEl[1]))		; not for buttons
			If $aEl[0] = "CMB" Or $aEl[0] = "CMT" Then
;			   If $fhDict.Exists($aEl[1] & $aReturn[$i][1]) Then $fhReturn.Item($aEl[1]) = $fhDict.Item($aEl[1] & $aReturn[$i][1])
			   If $fhDict.Exists($aEl[1] & GUICtrlRead(widgetID($aEl[1]))) Then $fhReturn.Item($aEl[1]) = $fhDict.Item($aEl[1] & GUICtrlRead(widgetID($aEl[1])))
			EndIf
		 EndIf
	  EndIf
	  ; errors Control
	  $error = checkData($aEl,$fhReturn.Item($aEl[1]))
	  If $error <> "" Then $errors &= @LF & $aEl[2] & $error
   Next
   If $errors <> "" Then return MsgBox(0,"Form Generator Warning",$errors)
   $fhReturn.Item("fg_button") = $aBtn[1]
   Return $fhReturn
EndFunc
Func checkData($aEl,$field)
   If Not $fhControlsDict.Exists($aEl[1]) Then Return ""
   $error = ""
   GUICtrlSetColor($aEl[6], 0x000000) ; Black
   $controls = $fhControlsDict.item($aEl[1])
   For $i = 1 to UBound($controls) -1		; the first item is empty
	  $k = StringInStr($controls[$i],"=")
	  $ctrl = ($k > 0) ? StringLeft(StringUpper($controls[$i]),$k-1)  : StringUpper($controls[$i])
	  $parm = ($k > 0) ? StringMid($controls[$i],$k+1)  : ""
	  If StringRegExp($field,"^\s*$") <> 0 Then
		 If $ctrl = "REQUIRED" Then
			$error = " Lack of data"
			ExitLoop
		 EndIf
	  Else
		 Switch $ctrl
			Case "MAIL"
			   If StringRegExp($field, "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$") = 0 Then $error = $error & " Incorrect mail address"
			Case "PATTERN"
			   If StringRegExp($field, $parm) = 0 Then $error = $error & " Incorrect pattern"
			Case "MIN"
			   if Number($field) < Number($parm) Then $error = $error & " Value lesser"
			Case "MAX"
			   if Number($field) > Number($parm) Then $error = $error & " Value greater"
		 EndSwitch
	  EndIf
   Next
   If $error <> "" Then GUICtrlSetColor($aEl[6], 0xff0000) ; Red
   return $error
EndFunc
Func SetDefaults($a,$cBack)
   Call($cBack,-1)		; initial handler
   For $i=0 To UBound($a)-1
	  $aEl = $a[$i]
	  $ctrlID = $fhDictW.Item($aEl[1])
	  If $aEl[0] = "CKB" Then GUICtrlSetState($ctrlID, ($aEl[4] = "1")? $GUI_CHECKED : $GUI_UNCHECKED)
	  If $aEl[0] = "CMB" Or $aEl[0] = "CMT"  Then GUICtrlSetData($ctrlID, "|" & $aEl[5],$aEl[4])
	  If $aEl[0] = "R" Then
		 If $aEl[4] <> "" Then
			GUICtrlSetState($fhDictW.Item($aEl[1] & $aEl[4]), $GUI_CHECKED)
			GUICtrlSetData($ctrlid,$fhDictW.Item($aEl[1] & $aEl[4]))
		 Else
			If GUICtrlRead($ctrlID) <> "" Then GUICtrlSetState(GUICtrlRead($ctrlID), $GUI_UNCHECKED)
			GUICtrlSetData($ctrlid,0)
		 EndIf
	  EndIf
	  If $aEl[0] = "S" Then
		 $aLim = StringRegExp($aEl[5],'[-+]?[0-9]+\.?[0-9]*', 3)
		 GUICtrlSetData($aEl[8],StringFormat("%." & $aEl[7] & "f",$aEl[4]))
		 GUICtrlSetData($ctrlID,($aEl[4]-$aLim[0])*100/($aLim[1]-$aLim[0]))
	  EndIf
	  If StringInStr("DTFNPXDATETIME",$aEl[0]) > 0 Then GUICtrlSetData($ctrlID,$aEl[4])	; type D, T, F, N, P, S, X,DATE, TIME
   Next
EndFunc
Func addControl($el,$ctrl)
   Local $aControls[] = []
   If $fhControlsDict.Exists($el) Then $aControls = $fhControlsDict.Item($el)
   _ArrayAdd($aControls,$ctrl)
   $fhControlsDict.Item($el) = $aControls
EndFunc
Func splitKeyValue($data, $fieldName, byRef $default)
   $array = StringSplit($data,"|",2)
   For $j = 0 to UBound($array) -1
	  $a = StringSplit($array[$j],"=",2)
	  $array[$j] = $a[0]
	  If UBound($a) = 2 Then $array[$j] = $a[1]
	  If $default = $a[0] Then $default = $array[$j]	; default is what is viewed
	  $fhDict.item($fieldName & $array[$j]) = $a[0]
   Next
   Return ArrayToString($array,"|")
EndFunc
Func handleKeys()
   $esc = true
EndFunc
Func mask($data)	; mask  comma and semicolon
   $data = StringReplace($data,",","\44")
   Return StringReplace($data,";","\59")
EndFunc
Func deMask($data)
	$data = StringReplace($data,"\44",",")
	Return StringReplace($data,"\59",";")
 EndFunc
Func DoNothing()
EndFunc
Func widgetID($fieldName)	; return the control ID
	Return ($fhDictW.Exists($fieldName)) ? $fhDictW.Item($fieldName) : 0
EndFunc
Func repeatString($sString, $iRepeatCount)
	Local $sResult = ""
	While $iRepeatCount > 1
		If BitAND($iRepeatCount, 1) Then $sResult &= $sString
		$sString &= $sString
		$iRepeatCount = BitShift($iRepeatCount, 1)
	WEnd
   Return $sString & $sResult
EndFunc   ;==>_StringRepeat
Func ArrayAdd(ByRef $avArray, $vValue)
   ReDim $avArray[UBound($avArray)+1]
   $avArray[UBound($avArray)-1] = $vValue
   return UBound($avArray)-1	; retun the index
EndFunc  ;==> ArrayAdd
Func array($a,$b,$c)
   Local $arr[3] = [$a,$b,$c]
   return $arr
EndFunc
Func arrayToString(Const ByRef $avArray, $sDelim = "|")
	$sResult = ""
	For $i = 0 To  UBound($avArray) -1
		$sResult &= $avArray[$i] & $sDelim
	Next
	Return StringTrimRight($sResult, StringLen($sDelim))
EndFunc   ;==> arrayToString
Func Min($nNum1, $nNum2)
   Return ($nNum1 > $nNum2) ? $nNum2: $nNum1
EndFunc   ;==>Min
Func Log10($fNb)
    Return Log($fNb) / Log(10) ; 10 is the base
EndFunc   ;==>Log10