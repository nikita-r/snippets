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

' concatenate tail tokens
Public Function StrTokTail(str As String, delim As String, idx As Integer) As String
Dim arr() As String
On Error GoTo ErrorHandler
    arr = Split(str, delim)
    If idx < 0 Then idx = UBound(arr) + 1 + idx
    StrTokTail = arr(idx)
    For idx = idx + 1 To UBound(arr)
        StrTokTail = StrTokTail + delim + arr(idx)
    Next
Exit Function
ErrorHandler:
    StrTokTail = ""
End Function

' concatenate head tokens
Public Function StrTokHead(str As String, delim As String, idx As Integer) As String
Dim arr() As String
On Error GoTo ErrorHandler
    arr = Split(str, delim)
    If idx < 0 Then idx = UBound(arr) + 1 + idx
    StrTokHead = arr(idx)
    For idx = idx - 1 To 0 Step -1
        StrTokHead = arr(idx) + delim + StrTokHead
    Next
Exit Function
ErrorHandler:
    StrTokHead = ""
End Function

