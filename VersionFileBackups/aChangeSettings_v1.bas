B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Handles the change settings
'
#Region  Documentation
	'
	' Name......: aChangeSettings
	' Release...: 1
	' Date......: 30/01/21   
	'
	' History
	' Date......: 30/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on ChangeSettings_v16 - renamed to aChangeSettings.
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
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private bar As StdActionBar			' Title bar 
	Private frm As hChangeSettings2 	' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
	frm.SaveAllSettings
	frm.OnClose			' do any clean up required.
	Sleep(10) 			' This appears necessary otherwise the keyboard can be left showing (DM 29/07/20).
	Activity.Finish 	'See https://www.b4x.com/android/forum/threads/simulate-back-menu-search-button-clicks.14809/
End Sub

Sub Activity_Create(FirstTime As Boolean)
	frm.Initialize(Activity)
	Activity.Title = "Settings"	' This appears necessary (setting in form designer don't work).
	Activity.AddMenuItem("ID information", "mnuIdInformation")
	Activity.AddMenuItem("Show FCM Token", "mnuShowFcmToken")	
	Activity.AddMenuItem("Show Location", "mnuShowLocation")
End Sub

' Back button - warn user no settings changed.
Sub Activity_Keypress(KeyCode As Int) As Boolean
	frm.SaveAllSettings
	frm.OnClose		' do any clean up required.
	Return False ' ensures backbutton works
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	frm.OnClose
End Sub

Sub Activity_Resume
	modEposApp.InitializeStdActionBar(bar, "bar") ' See note for v10
	frm.DisplayCurrentSettings
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Menu option to show customer ID
Private Sub mnuIdInformation_CLick
	frm.ShowCustomerId
End Sub

' Menu option to shown FCM Token 
Private Sub mnuShowFcmToken_Click
	frm.ShowFcmToken
End Sub

Private Sub mnuShowLocation_Click
	frm.ShowLocation
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Fully closes (kills) this activity, returning to the Check account status activity.
public Sub CloseActivity
	StartActivity(aCheckAccountStatus)
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines


#End Region  Local Subroutines


