$oExcel = ObjGet("", "Excel.Application")
MsgBox(1, "", $oExcel.ActiveWorkbook.FullName)