#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ Example 6 Demonstrates all stuff within chrome to
;~ navigate html pages,
;~ find hyperlink,
;~ click hyperlink,
;~ find picture,
;~ click picture,    "name:=Search...; indexrelative:=2" means find an element with name = Search... but then just skip 2 elements further
;~ enter data in inputbox
;~
;~ Made a lot more comments and failure to show when an object is not retrieved/found the hierarchy of the tree is written to the console
;~ Lots of optimizations could be done by using the cachefunctions (less interprocess communication) but on my machine it runs at
;~ a very acceptable speed
;~ In top of script put the text in your local language of the operating system

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <debug.au3>

#include "UIAWrappers.au3"

#cs
;~ *** Standard code ***
#include "UIAWrappers.au3"
AutoItSetOption("MustDeclareVars", 1)

Local $oP3=_UIA_getObjectByFindAll($UIA_oDesktop, "Title:=Accessibility - Google Chrome;controltype:=UIA_WindowControlTypeId;class:=Chrome_WidgetWin_1", $treescope_children)
_UIA_Action($oP3,"setfocus")
Local $oP2=_UIA_getObjectByFindAll($oP3, "Title:=;controltype:=UIA_PaneControlTypeId;class:=Chrome_RenderWidgetHostHWND", $treescope_children)
_UIA_Action($oP2,"setfocus")
Local $oP1=_UIA_getObjectByFindAll($oP2, "Title:=;controltype:=UIA_CustomControlTypeId;class:=", $treescope_children)
Local $oP0=_UIA_getObjectByFindAll($oP1, "Title:=on;controltype:=UIA_HyperlinkControlTypeId;class:=", $treescope_children)
;~ First find the object in the parent before you can do something
;~$oUIElement=_UIA_getObjectByFindAll("on.mainwindow", "title:=on;ControlType:=UIA_TextControlTypeId", $treescope_subtree)
Local $oUIElement=_UIA_getObjectByFindAll($oP0, "title:=on;ControlType:=UIA_TextControlTypeId", $treescope_subtree)
_UIA_action($oUIElement,"click")
#ce

#AutoIt3Wrapper_UseX64=N  ;Should be used for stuff like tagpoint having right struct etc. when running on a 64 bits os

ConsoleWrite("Example constants please change text to english or other language to identify controls" & @CRLF)

;~ Make this language specific
;~ Const $cToolbarByName = "name:=Google Chrome Toolbar"
;~ local $cToolbarByName=""
;~ switch @OSLang
;~ 	case 0409
;~ 		$cToolbarByName="start"
;~ 	case 0413
;~ 		$cToolbarByName="name:=hoofd"
;~ 	case 1033
;~ 		$cToolbarByName="name:=head"
;~ 	case Else
;~ 		MsgBox($MB_SYSTEMMODAL, "Title", "Language unknown please extend script with right name of chrome toolbar and post it in thread", 3)
;~ EndSwitch
;~ $oChromeToolbar=_UIA_getFirstObjectOfElement($oChrome, $matchString, $treescope_subtree)


;~ Const $cToolbarByName = "helptext:=TopContainerView"
Const $cAddressBarByName = "name:=Adres- en zoekbalk"
;~ Const $cAddressBar = "helptext:=OmniboxViewViews"
;~ Const $cAddressBar = "controltype:=" & $UIA_EditControlTypeId

Const $cChromeNewTabByName = "name:=Nieuw tabblad"
Const $cDocument ="controltype:=Document"
;~ Title:=Accessibility.*Google Chrome;controltype:=UIA_WindowControlTypeId;class:=Chrome_WidgetWin_1

local $strChromeStartup="--force-renderer-accessibility"
local $strChromeExeFolder=@UserProfileDir & "\AppData\Local\Google\Chrome\Application\"
local $strChromeExe=$strChromeExeFolder & "chrome.exe "

if not fileexists($strChromeExe) Then
	$strChromeExeFolder=@ProgramFilesDir & "\Google\Chrome\Application\"
	$strChromeExe=$strChromeExeFolder & "chrome.exe "
EndIf

;~ Start chrome
if fileexists($strChromeExe) Then
    if not processexists("chrome.exe") Then
        run($strChromeExe & $strChromeStartup,"", @SW_MAXIMIZE )
        ProcessWait("chrome.exe")
        ;~ Just to give some time to start
        sleep(10000)
    endif
Else
	if not processexists("chrome.exe") Then
		consolewrite("No clue where to find chrome on your system, please start manually:" & @CRLF )
		consolewrite($strChromeExe & $strChromeStartup & @CRLF)
	endif
EndIf

;~ Find the chrome window
local $oChrome = _UIA_getFirstObjectOfElement($UIA_oDesktop, "class:=Chrome_WidgetWin_1", $treescope_children)
If Not IsObj($oChrome) Then
	_UIA_DumpThemAll($UIA_oDesktop, $treescope_subtree)
	Exit
EndIf

;~ Make sure chrome is front window
$oChrome.setfocus()

If IsObj($oChrome) Then
	ConsoleWrite("Action 1 dummy step" & @CRLF)

;~  get the chrome toolbar
;~  $oChromeToolbar=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_ToolBarControlTypeId, $treescope_subtree)
;~ local 	$oChromeToolbar = _UIA_getFirstObjectOfElement($oChrome, $cToolbarByName, $treescope_subtree)
;~ 	If Not IsObj($oChromeToolbar) Then
;~ 		consolewrite("No toolbar found, dumping whole tree takes to long, check with simplespy.au3 or inspext.exe")
;~ 		exit
;~ 		_UIA_DumpThemAll($oChrome, $treescope_subtree)
;~ 	EndIf


	ConsoleWrite("Action 2" & @CRLF)
;~  get the addressbar
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"class:=Chrome_OmniboxView", $treescope_children) ;worked in chrome 28
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"controltype:=" & $UIA_EditControlTypeId , $treescope_subtree) ;works in chrome 29
;~  $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChromeToolbar,"name:=Adres- en zoekbalk"  , $treescope_children) ;works in chrome 29
;~ local 	$oChromeAddressBar = _UIA_getObjectByFindAll($oChromeToolbar, $cAddressBar, $treescope_subtree) ;works in chrome 42
;~ local $oChromeAddressBar=_UIA_getFirstObjectOfElement($oChrome,"title:=Adres- en zoekbalk"  , $treescope_subtree) ;works in chrome 65
local 	$oChromeAddressBar = _UIA_getObjectByFindAll($oChrome, $cAddressBarByName, $treescope_subtree) ;works in chrome 65

	If Not IsObj($oChromeAddressbar) Then
;~ 		_UIA_DumpThemAll($oChromeToolbar, $treescope_subtree)
	consolewrite("Look in log, most likely different language to recognize needed")
	EndIf

;~  $oValueP=_UIA_getpattern($oChromeAddressBar,$UIA_ValuePatternId)
;~  sleep(2000)

;~  get the value of the addressbar
;~  $myText=""
;~  $oValueP.CurrentValue($myText)
;~  consolewrite("address: " & $myText & @CRLF)

	ConsoleWrite("Action 3" & @CRLF)
;~ Get reference to the tabs
local 	$oChromeTabs = _UIA_getFirstObjectOfElement($oChrome, "controltype:=" & $UIA_TabControlTypeId, $treescope_subtree)
	If Not IsObj($oChromeTabs) Then
		_UIA_DumpThemAll($oChrome, $treescope_subtree)
	EndIf

;~ Lets open a new tab within chrome

	ConsoleWrite("Action 4" & @CRLF)
;~  $oChromeNewTab= _UIA_getFirstObjectOfElement($oChromeTabs,"controltype:=" & $UIA_ButtonControlTypeId, $treescope_subtree)
local 	$oChromeNewTab = _UIA_getObjectByFindAll($oChromeTabs, $cChromeNewTabByName, $treescope_subtree)
	If Not IsObj($oChromeNewTab) Then
		_UIA_DumpThemAll($oChromeTabs, $treescope_subtree)
	EndIf
	_UIA_action($oChromeNewtab, "leftclick")
	Sleep(500)

	ConsoleWrite("Action 4a" & @CRLF)
;~ 	$oChromeAddressBar = _UIA_getObjectByFindAll($oChromeToolbar, $cAddressBar, $treescope_subtree) ;works in chrome 42
$oChromeAddressBar = _UIA_getObjectByFindAll($oChrome, $cAddressBarByName, $treescope_subtree) ;works in chrome 65
	If Not IsObj($oChromeAddressbar) Then
;~ 		_UIA_DumpThemAll($oChromeToolbar, $treescope_subtree)
	consolewrite("Look in log, most likely different language to recognize needed")
	EndIf

local 	$t = StringSplit(_UIA_getPropertyValue($oChromeAddressBar, $UIA_BoundingRectanglePropertyId), ";")
	_UIA_DrawRect($t[1], $t[3] + $t[1], $t[2], $t[4] + $t[2])
	_UIA_action($oChromeAddressBar, "leftclick")

;~ _UIA_action($oChromeAddressBar,"leftclick")
	_UIA_action($oChromeAddressBar, "setvalue using keys", "chrome://accessibility/{ENTER}")


	#cs
		#include "UIAWrappers.au3"
		AutoItSetOption("MustDeclareVars", 1)

		Local $oP0=_UIA_getObjectByFindAll($UIA_oDesktop, "Title:=Accessibility - Google Chrome;controltype:=UIA_WindowControlTypeId;class:=Chrome_WidgetWin_1", $treescope_children)
		_UIA_Action($oP0,"setfocus")
		_UIA_setVar(".mainwindow","title:=;classname:=Chrome_RenderWidgetHostHWND")
		_UIA_action(".mainwindow","setfocus")
	#ce


	ConsoleWrite("Action 4b" & @CRLF)
;~ give some time to open website
	Sleep(2000)
;~ Local $oP3=_UIA_getObjectByFindAll($UIA_oDesktop, "Title:=Accessibility - Google Chrome;controltype:=UIA_WindowControlTypeId;class:=Chrome_WidgetWin_1", $treescope_children)

;~ 	_UIA_Action("Title:=Accessibility.*;controltype:=UIA_WindowControlTypeId;class:=Chrome_WidgetWin_1", "setfocus")

;~ _UIA_Action($oP0,"setfocus")
_UIA_setVar("RTI.SEARCHCONTEXT",$oChrome)
local 	$oDocument = _UIA_action($cDocument, "object")
_UIA_Action($oDocument, "setfocus")

;~ $oDocument=_UIA_getFirstObjectOfElement($oChrome,"controltype:=" & $UIA_DocumentControlTypeId , $treescope_subtree)
;~ $oDocument=_UIA_getFirstObjectOfElement($oChrome,"classname:=" & $UIA_DocumentControlTypeId , $treescope_subtree)

	If Not IsObj($oDocument) Then
		consolewrite("Sorry no document object found, dumping whole tree takes to long, check with simplespy.au3 or inspext.exe")
		exit
		_UIA_DumpThemAll($oChrome, $treescope_subtree)
	Else
		$t = StringSplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId), ";")
		_UIA_DrawRect($t[1], $t[3] + $t[1], $t[2], $t[4] + $t[2])
	EndIf

	Sleep(500)

	ConsoleWrite("Action 4c retrieve document after clicking a hyperlink" & @CRLF)
    local 	$oForumLink = _UIA_getObjectByFindAll($oDocument, "name:=((On)|(on)|(native.*true))", $treescope_subtree)     ;TODO: Fix for latest versions of chrome find text: native: true
	If Not IsObj($oForumLink) Then
		ConsoleWrite("*** Scripting will fail as accessibility is off ****")
		MsgBox(4096, "Accessibility warning", "Accessibility is turned off, put it on by clicking on Off after Global accessibility mode", 10)
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf

	ConsoleWrite("Action 4d" & @CRLF)
;~ $oChromeNewTab= _UIA_getFirstObjectOfElement($oChromeTabs,"controltype:=" & $UIA_ButtonControlTypeId, $treescope_subtree)
	$oChromeNewTab = _UIA_getObjectByFindAll($oChromeTabs, $cChromeNewTabByName, $treescope_subtree)
	If Not IsObj($oChromeNewTab) Then
		_UIA_DumpThemAll($oChromeTabs, $treescope_subtree)
	EndIf
	_UIA_action($oChromeNewtab, "leftclick")
	Sleep(500)
	ConsoleWrite("Action 5" & @CRLF)
;~ 	$oChromeAddressBar = _UIA_getObjectByFindAll($oChromeToolbar, $cAddressBar, $treescope_subtree) ;works in chrome 42
	$oChromeAddressBar = _UIA_getObjectByFindAll($oChrome, $cAddressBarByName, $treescope_subtree) ;works in chrome 65

	If Not IsObj($oChromeAddressbar) Then
;~ 		_UIA_DumpThemAll($oChromeToolbar, $treescope_subtree)
	consolewrite("Look in log, most likely different language to recognize needed")
	EndIf

$t = StringSplit(_UIA_getPropertyValue($oChromeAddressBar, $UIA_BoundingRectanglePropertyId), ";")
	_UIA_DrawRect($t[1], $t[3] + $t[1], $t[2], $t[4] + $t[2])
	_UIA_action($oChromeAddressBar, "leftclick")
	_UIA_action($oChromeAddressBar, "setvalue using keys", "www.autoitscript.com/ {ENTER}")
	ConsoleWrite("Action 6" & @CRLF) ;~ give some time to open website
	Sleep(2000)
	$oDocument = _UIA_getFirstObjectOfElement($oChrome, "controltype:=" & $UIA_DocumentControlTypeId, $treescope_subtree)
	If Not IsObj($oDocument) Then
		_UIA_DumpThemAll($oChrome, $treescope_subtree)
	Else
		$t = StringSplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId), ";")
		_UIA_DrawRect($t[1], $t[3] + $t[1], $t[2], $t[4] + $t[2])
	EndIf
	Sleep(500)


	ConsoleWrite("Action 7 retrieve document after clicking a hyperlink" & @CRLF)
	$oForumLink = _UIA_getObjectByFindAll($oDocument, "name:=Forum", $treescope_subtree)
	If Not IsObj($oForumLink) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	Else
		_UIA_action($oForumLink, "invoke")
	EndIf
;~ 	Give some time to load, crucial as we do not have another way of syncing for chrome (yet)
	Sleep(5000)

;~ 	_UIA_setVar("global.debug.file",false)
	ConsoleWrite("Action 8 first refresh the document control" & @CRLF)
	$oDocument = _UIA_getFirstObjectOfElement($oChrome, "controltype:=" & $UIA_DocumentControlTypeId, $treescope_subtree)

	If Not IsObj($oDocument) Then
		_UIA_DumpThemAll($oChrome, $treescope_subtree)
	Else
		$t = StringSplit(_UIA_getPropertyValue($oDocument, $UIA_BoundingRectanglePropertyId), ";")
		_UIA_DrawRect($t[1], $t[3] + $t[1], $t[2], $t[4] + $t[2])

	EndIf

	;~ Now we get the searchfield
;~ 	_UIA_setVar("global.debug.file",false)
	ConsoleWrite("Action 8a focus document" & @CRLF)

	_UIA_action($oDocument, "focus")
	sleep(500)

;~ 	As search box is tricky to find just another link in between to see what works
	$oForumLink = _UIA_getObjectByFindAll($oDocument, "name:=Announcements and Site News", $treescope_subtree)
	If Not IsObj($oForumLink) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	Else
		_UIA_action($oForumLink, "highlight")
	EndIf
	Sleep(500)

;~ 	Tricky finding due to dots and its not sure Search text is really exposed
	local 	$oEdtSearchForum = _UIA_getObjectByFindAll($oDocument, "controltype:=Edit;name:=Search...", $treescope_subtree)
	If Not IsObj($oEdtSearchForum) Then
		ConsoleWrite("Action 8a NOTHING FOUND" & @CRLF)
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf
;~ 	_UIA_action($oEdtSearchForum, "mousemove")
;~ 	sleep(2000)

	_UIA_action($oEdtSearchForum, "highlight")
	sleep(500)
	_UIA_action($oEdtSearchForum, "focus")
	sleep(500)
;~ 	_UIA_action($oEdtSearchForum, "setvalue using keys", "Hello") ; {ENTER}")
	_UIA_action($oEdtSearchForum, "setvalue using keys", "Chrome is designed to resist automation in a web page") ; {ENTER}")
	Sleep(500)
;~ 	Exit

;~ Now we press the button, see relative syntax used as the button seems not to have a name its just 1 objects further then search field
;~ 	local 	$oBtnSearch = _UIA_getObjectByFindAll($oDocument, "controltype:=Edit;name:=Search...;indexrelative:=1", $treescope_subtree)
	local 	$oBtnSearch = _UIA_getObjectByFindAll($oDocument, "controltype:=Edit;name:=Search...;indexrelative:=1", $treescope_subtree)

	If Not IsObj($oBtnSearch) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf
;~ 	$t = StringSplit(_UIA_getPropertyValue($oBtnSearch, $UIA_BoundingRectanglePropertyId), ";")
;~ 	_UIA_DrawRect($t[1], $t[3] + $t[1], $t[2], $t[4] + $t[2])
;~ 	Sleep(500)
;~ 	_UIA_action($oBtnSearch, "invoke") Chrome is inconsistent on invoke
	_UIA_action($oBtnSearch, "highlight")
	_UIA_action($oBtnSearch, "click")
	Sleep(2000)

consolewrite("Action 9 first refresh the document control" & @CRLF)
	$oDocument = _UIA_getFirstObjectOfElement($oChrome, "controltype:=" & $UIA_DocumentControlTypeId, $treescope_subtree)
	If Not IsObj($oDocument) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf
	local 	$oHyperlink = _UIA_getObjectByFindAll($oDocument, "name:=controlsend doesn't work", $treescope_subtree)
	If Not IsObj($oHyperlink) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf
	Sleep(1000)
;~ 	_UIA_action($oHyperlink, "invoke")
	_UIA_action($oHyperlink, "click",20,5)
	Sleep(2000)

consolewrite("Action 10 just find some text to validate" & @CRLF)
	$oDocument = _UIA_getFirstObjectOfElement($oChrome, "controltype:=" & $UIA_DocumentControlTypeId, $treescope_subtree)
	If Not IsObj($oDocument) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf
	local 	$oTextToCheck = _UIA_getObjectByFindAll($oDocument, "name:=.*automated with ui automation.*", $treescope_subtree)
	If Not IsObj($oTextToCheck) Then
		_UIA_DumpThemAll($oDocument, $treescope_subtree)
	EndIf
	Sleep(1000)
;~ 	_UIA_action($oTextToCheck, "invoke")
	_UIA_action($oTextToCheck, "highlight")
	consolewrite(_UIA_action($oTextToCheck, "property", "title"))
	local $tResult=_UIA_action($oTextToCheck, "getvalue")
	consolewrite($tresult)

	Sleep(2000)

EndIf
Exit
