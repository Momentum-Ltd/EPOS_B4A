B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a template for Classes
'

#Region  Documentation
	'
	' Name......: clsReportErrors
	' Release...: 1
	' Date......: 01/12/19
	'
	' History
	' Date......: 01/12/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking.
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
	Private externalFolder As String
	Private runtimePerms As RuntimePermissions 	' Object which handles runtime permissions (used when getting .externalFolder).
	Private phoneDetails As Phone 				' Object which stores the details of the phone on which the app is running.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

	externalFolder = runtimePerms.GetSafeDirDefaultExternal("eposLogs") ' This should happen as early as possible (for exceptions)

End Sub

' Write a report to the specified log file.
Public Sub LogReport(LogFileName As String, logText As String)
	AppendToExtLog(LogFileName, logText)
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

' Appends the specified text to the specified externally-accessible log file (creating it if it doesn't already exist).
' The log files can be found in the phone's Internal Storage > Android > data > arena.Epos > files > eposLogs directory.
Private Sub AppendToExtLog(fileName As String, textToAppend As String)
	Dim logStrToSave As String = ""	' Get the previous text from the existing file so that it won't be overwritten
	If File.Exists(externalFolder, fileName) Then 
		logStrToSave = File.ReadString(externalFolder, fileName)
	End If
	If logStrToSave <> "" Then 
		logStrToSave = logStrToSave & CRLF & CRLF & "--------------------------------" & CRLF & CRLF
	End If
	DateTime.DateFormat = "HH:mm:ss yyyy/MM/dd"
	Dim timeDateStr As String = DateTime.Date(DateTime.Now).Replace(" ", " , on ")
	logStrToSave = logStrToSave & "Log report for " & Application.LabelName & " v" & Application.VersionName & " running on a  " & _
					"phone using Android SDK " & phoneDetails.SdkVersion & CRLF & "Logged at " & timeDateStr & CRLF & textToAppend
	File.WriteString(externalFolder, fileName, logStrToSave) ' Save the whole text to the file
	Log("The following text was saved to the " & fileName & " log file:" & CRLF & textToAppend) ' For test purposes
End Sub
#End Region  Local Subroutines
