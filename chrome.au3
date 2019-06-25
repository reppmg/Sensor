
   Sleep( 1000 )
AutoItSetOption("WinTitleMatchMode", 2)

$handle = WinGetHandle("[CLASS:Chrome_WindowImpl_0; TITLE:Getting the current chrome url]")

If @error Then
    MsgBox(4096, "Error", "Could not find the correct window")
Else
    ; alert the present url
    MsgBox(4096, "", ControlgetText($handle, "", "Chrome_AutocompleteEditView1" ))

    ;n redirect the browser
    ControlSetText ($handle, "", "Chrome_AutocompleteEditView1", "http://alterlife.org/")
    ControlSend ($handle, "", "Chrome_AutocompleteEditView1", "{enter}")
    MsgBox(4096, "Error", "The browser has been redirected to http://alterlife.org/.")
EndIf