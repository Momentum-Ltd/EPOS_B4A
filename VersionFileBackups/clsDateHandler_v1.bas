B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'
' Class to handle the processing of Date and Year entry.
'
#Region  Documentation
	'
	' Name......: clsDatehandler
	' Release...: 1
	' Date......: 20/11/20
	'
	' History
	' Date......: 20/11/20
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on code taken from hCardEntry_v16.
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Mandatory Subroutines & Data

Sub Class_Globals

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines


' Formats a Expiry Data string into MM/YY (year is last 2 digits).
' monthYear can be in format MMYY or MM/YY.
Public Sub FormatDateMMYY(monthYear As String) As String
	Dim tempDate As String = monthYear.Trim.Replace( "/", "")
	Dim processeedText As String = ""
	If tempDate.Length > 0 Then
		If tempDate.Length > 4 Then ' Truncate string down to 4 charactors?
			tempDate = tempDate.SubString2(0, 3)
		End If
		If tempDate.Length = 1 Then
			If tempDate.CompareTo("1") > 0 Then 'Month less than 10?
				processeedText = "0" & tempDate & "/" 
			Else
				processeedText = tempDate
			End If
		Else
			Dim indexEnd As Int = tempDate.Length - 1
			For charIndex = 0 To indexEnd
				If charIndex = 2 Then
					processeedText = processeedText & "/"
				End If
				processeedText = processeedText & tempDate.SubString2(charIndex, charIndex + 1)
			Next
		End If
	End If
	Return processeedText
End Sub


' Formats a Expiry Data string into MM/YYYY.
' monthYear can be in format MMYY or MM/20YY.
Public Sub FormatDateMMYYYY(monthYear As String) As String
	Dim tempDate As String = monthYear.Trim.Replace( "/20", "")
	Dim processeedText As String = ""
	If tempDate.Length > 0 Then
		If tempDate.Length > 4 Then ' Truncate string down to 4 charactors?
			tempDate = tempDate.SubString2(0, 3)
		End If
		If tempDate.Length = 1 Then
			If tempDate.CompareTo("1") > 0 Then 'Month less than 10?
				processeedText = "0" & tempDate & "/20" 
			Else
				processeedText = tempDate
			End If
		Else
			Dim indexEnd As Int = tempDate.Length - 1
			For charIndex = 0 To indexEnd
				If charIndex = 2 Then
					processeedText = processeedText & "/20"
				End If
				processeedText = processeedText & tempDate.SubString2(charIndex, charIndex + 1)
			Next
		End If
	End If
	Return processeedText
End Sub

' Handler for the user's text view format MM/YY (Insert in the caller's Event handler).
Public Sub Handler_TextChanged_MMYY(viewObj As B4XFloatTextField, old As String, new As String)
#if B4i	' See https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/
	Sleep(0)	' Ensure the new value is ok
#end if
	' So cursor can be positioned correctly see https://www.b4x.com/android/forum/threads/b4xfloattextfield-filter-characters-allowed.114681/
#if B4A
	Dim et As EditText = viewObj.TextField
#else ' B4i
	Dim et As TextField = viewObj.TextField
#end if
	If old.Length > new.Length Then
		Dim x As String = FormatDateMMYY(new)
		If new.Length = 2 Then ' backspace over "/"?
			x = x.SubString2(0, new.Length - 1)
			If x <> new Then
				viewObj.Text = x
				If x.Length > 0 Then
					et.SetSelection(x.Length, 0)
				End If
			End If
		End If
	else If new.Length = 2 Then ' Insert "/"?
		Dim x As String = FormatDateMMYY(new)
		viewObj.Text = new & "/"
		et.SetSelection(3, 0)
	else if new.Length > 5 Then
		viewObj.Text = new.SubString2(0, 5)
		et.SetSelection(5, 0)
	else if new.Length = 1 Then
		If new.CompareTo("1") > 0 Then 'Do we need to reformat?
			viewObj.Text = FormatDateMMYY(new)
			et.SetSelection(3,0)
		End If
	End If
End Sub

' Handler for the user's text view format MM/YYYY (Insert in the caller's Event handler).
Public Sub Handler_TextChanged_MMYYYY(viewObj As B4XFloatTextField, old As String, new As String)
#if B4i	' See https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/
	Sleep(0)	' Ensure the new value is ok
#end if
	' So cursor can be positioned correctly see https://www.b4x.com/android/forum/threads/b4xfloattextfield-filter-characters-allowed.114681/
#if B4A
	Dim et As EditText = viewObj.TextField
#else ' B4i
	Dim et As TextField = viewObj.TextField
#end if
	If old.Length > new.Length Then
		Dim x As String = FormatDateMMYYYY(new)
		If new.Length = 4 Then ' backspace over "/20"?
			x = x.SubString2(0, new.Length - 3)
			If x <> new Then
				viewObj.Text = x
				If x.Length > 0 Then
					et.SetSelection(x.Length, 0)
				End If
			End If
		End If
	else If new.Length = 2 Then ' Insert "/20"?
		viewObj.Text = new & "/20"
		et.SetSelection(5, 0)
	else if new.Length > 7 Then
		viewObj.Text = new.SubString2(0, 7)
		et.SetSelection(7, 0)
	else if new.Length = 1 Then
		If new.CompareTo("1") > 0 Then 'Do we need to reformat?
			viewObj.Text = FormatDateMMYYYY(new)
			et.SetSelection(5,0)
		End If
	End If
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines