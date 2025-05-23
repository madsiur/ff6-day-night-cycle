Sub Maps
    Dim oSheet As Object
    Dim oCell As Object
    Dim i As Integer
    Dim rowIndex As Integer
    Dim fileAccess As Object
    Dim fileOut1 As Object
    Dim fileOut2 As Object
    Dim basePath As String

    basePath = GetParentDirectory(GetParentDirectory(ThisComponent.URL))
    fileAccess = createUnoService("com.sun.star.ucb.SimpleFileAccess")

    fileOut1 = fileAccess.openFileWrite(basePath & "/asm/data/map_enable.bin")
    fileOut2 = fileAccess.openFileWrite(basePath & "/asm/data/map_active.bin")

    oSheet = ThisComponent.Sheets(0)

    For i = 0 To 51
        rowIndex = 9 + i * 8
        WriteByte fileOut1, oSheet.getCellByPosition(6, rowIndex), rowIndex + 1, "G"
        WriteByte fileOut2, oSheet.getCellByPosition(8, rowIndex), rowIndex + 1, "I"
    Next i

    fileOut1.closeOutput()
    fileOut2.closeOutput()
    MsgBox "Maps binary files written successfully."
End Sub

Sub Backgrounds
    Dim oSheet As Object
    Dim oCell As Object
    Dim i As Integer
    Dim rowIndex As Integer
    Dim fileAccess As Object
    Dim fileOut1 As Object
    Dim fileOut2 As Object
    Dim basePath As String

    basePath = GetParentDirectory(GetParentDirectory(ThisComponent.URL))
    fileAccess = createUnoService("com.sun.star.ucb.SimpleFileAccess")

    fileOut1 = fileAccess.openFileWrite(basePath & "/asm/data/bg_enable.bin")
    fileOut2 = fileAccess.openFileWrite(basePath & "/asm/data/bg_palette_id.bin")

    oSheet = ThisComponent.Sheets(1)

    For i = 0 To 6
        rowIndex = 9 + i * 8
        WriteByte fileOut1, oSheet.getCellByPosition(6, rowIndex), rowIndex + 1, "G"
    Next i
    
    fileOut1.closeOutput()
    
    For i = 0 To 54
        rowIndex = 2 + i
        WriteByte fileOut2, oSheet.getCellByPosition(4, rowIndex), rowIndex + 1, "E"
    Next i
   
    fileOut2.closeOutput()
    
    MsgBox "Battle backgrounds binary files written successfully."
End Sub

Sub Events
    Dim oSheet As Object
    Dim oCell As Object
    Dim i As Integer
    Dim rowIndex As Integer
    Dim fileAccess As Object
    Dim fileOut1 As Object
    Dim basePath As String

    basePath = GetParentDirectory(GetParentDirectory(ThisComponent.URL))
    fileAccess = createUnoService("com.sun.star.ucb.SimpleFileAccess")

    fileOut1 = fileAccess.openFileWrite(basePath & "/asm/data/world_events.bin")

    oSheet = ThisComponent.Sheets(2)

    For i = 0 To 3
        rowIndex = 9 + i * 8
        WriteByte fileOut1, oSheet.getCellByPosition(5, rowIndex), rowIndex + 1, "F"
    Next i
    
    fileOut1.closeOutput()
    
    MsgBox "World map events binary file written successfully."
End Sub

Function GetParentDirectory(path As String) As String
    Dim i As Integer
    For i = Len(path) To 1 Step -1
        If Mid$(path, i, 1) = "/" Then
            GetParentDirectory = Left$(path, i - 1)
            Exit Function
        End If
    Next i
    GetParentDirectory = path ' fallback: return unchanged
End Function

Sub WriteByte(fileOut As Object, oCell As Object, rowNum As Integer, colLetter As String)
    Dim value As Integer
    value = oCell.Value
    If value < 0 Or value > 255 Then
        MsgBox "Invalid value in " & colLetter & rowNum
        fileOut.closeOutput()
        End
    End If

    Dim byteArray(0) As Byte
    byteArray(0) = value
    fileOut.writeBytes(byteArray)
End Sub