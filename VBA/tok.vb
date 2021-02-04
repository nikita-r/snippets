'·tok.vb

' tokenize a string
Public Function StrTok(str As String, delim As String, idx As Integer) As String
Dim arr() As String
On Error GoTo ErrorHandler
    arr = Split(str, delim)
    Select Case idx
    Case 0 To UBound(arr)
        StrTok = arr(idx)
    Case Is < 0
        StrTok = arr(UBound(arr) + 1 + idx)
  ' Case UBound(arr) + 1 ' return file extension
  '     StrTok = Split(arr(idx - 1), ".")(1)
    Case Else
        StrTok = ""
    End Select
Exit Function
ErrorHandler:
    StrTok = ""
End Function

' last token (delim="/") by means of an Excel formula
'=MID([@Col],FIND("*",SUBSTITUTE([@Col],"/","*",LEN([@Col])-LEN(SUBSTITUTE([@Col],"/",""))))+1,LEN([@Col]))

