B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' web start Change settings
'

#Region  Documentation
	'
	' Name......: ChangeSettings
	' Release...: 15
	' Date......: 05/08/20   
	'
	' History
	' Date......: 22/06/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Version 2 - 9 see v10.
	'
	' Date......: 07/02/20
	' Release...: 10
	' Overview..: New UI and Back button added to title bar.
	' Amendee...: D Morris.
	' Details...:  Mod: stdActionBar added and associated code.
	'				***Note: Back button in titlebar can't be supported - needs to know were it came from
	'							Fixed see v12.***
	'
	' Date......: 11/05/20
	' Release...: 11
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 16/05/20
	' Release...: 12
	' Overview..: Issue #0390 - no back arrow in title bar for Settings and Enter card activitues.
	' Amendee...: D Morris
	' Details...: Mod: Another attempt at using back but (found using Activity.Finish works).
	'			  Mod: Show location added to menu.
	'			  Mod: Show Customer ID renamed to ID information.
	'			  Removed: Clear account and Enter card options removed.
	'			    
	' Date......: 31/05/20
	' Release...: 13
	' Overview..: General cleanup.
	' Amendee...: D Morris.
	' Details...: Removed: mnuCardEntry_Click() - no longer required.
	'			    
	' Date......: 02/08/20
	' Release...: 14
	' Overview..: Bugfix: #0488 Settings back key problem.
	' Amendee...: D Morris.
	' Details...: Mod:  Activity_Keypress(), Activity_ActionBarHomeClick() - code to clean up before exit.
	'			    
	' Date......: 05/10/20
	' Release...: 15
	' Overview..: Mod: Support for new Change Settings.
	' Amendee...: D Morris
	' Details...: ModL Uses new hChangeSettings2 helper.
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
'	#IncludeTitle: False
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private bar As StdActionBar			' New title bar ' See note for v10
	Private frm As hChangeSettings2 	' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
	frm.SaveAllSettings
	frm.OnClose		' do any clean up required.
	Sleep(10) ' This appears necessary otherwise the keyboard can be left showing (DM 29/07/20).
	Activity.Finish 'See https://www.b4x.com/android/forum/threads/simulate-back-menu-search-button-clicks.14809/
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
'	frm.ReportNoChanges

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
	StartActivity(CheckAccountStatus)
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines


#End Region  Local Subroutines


