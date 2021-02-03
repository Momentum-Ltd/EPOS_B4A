B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Handles change account information.
'
#Region  Documentation
	'
	' Name......: aChangeAccountInfo
	' Release...: 1
	' Date......: 30/01/21   
	'
	' History
	' Date......: 30/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on ChangeAccountInfo_v8 - renamed.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private bar As StdActionBar			' New title bar
	Private frm As hChangeAccountInfo 	' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
	frm.ReportNoChanges
'#if B4A
	StartActivity(aCheckAccountStatus)
'#else
'	frmCheckAccountStatus.show(True)
'#End If
End Sub

private Sub Activity_Create(FirstTime As Boolean)
	modEposApp.InitializeStdActionBar(bar, "bar")
	Activity.Title = "Edit Account"	' This appears necessary (setting in form designer don't work).
	frm.Initialize(Activity)
End Sub

' Back button - warn user no Account info changed.
private Sub Activity_Keypress(KeyCode As Int) As Boolean
	frm.ReportNoChanges
	Return False ' ensures backbutton works
End Sub

private Sub Activity_Pause (UserClosed As Boolean)
	frm.OnClose
End Sub

private Sub Activity_Resume
	frm.DisplayInfo
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines
' Main method
public Sub pChangeAccountInfo
		
End Sub

' Returns to caller.
public Sub GoBackToCaller
	Activity.Finish
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines


#End Region  Local Subroutines


