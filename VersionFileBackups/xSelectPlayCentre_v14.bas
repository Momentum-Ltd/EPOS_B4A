B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.3
@EndOfDesignText@
'
' Web Start Select Play Centre (X platform version)
'

#Region  Documentation
	'
	' Name......: xSelectPlayCentre
	' Release...: 14
	' Date......: 16/05/20   
	'
	' History
	' Date......: 28/07/19
	' Release...: 1
	' Created by: D Morris.
	' Details...: X platform version. (based on SelectPlayCentre_v3)
	'
	' Versions 2 - 8 see v10.
	'
	' Date......: 21/11/19
	' Release...: 9
	' Overview..: Support for testMode as part of settings.
	' Amendee...: D Morris
	' Details...:  Mod: Back button operation.
	'
	' Date......: 21/12/19
	' Release...: 10
	' Overview..: Bugfix: #0180 - try keeping GPS enabled, Added #0231 - Display location. 
	' Amendee...: D Morris
	' Details...:    Mod: Activity_Pause() - code to call LocationDeviceOff() removed.
	'			   Added: Show Location menu option
	'
	' Date......: 30/12/19
	' Release...: 11
	' Overview..: Back button operation improved
	' Amendee...: D Morris
	' Details...:  Mod: Activity_Keypress() reference to test mode removed (introduced at v9 - not sure why).
	'
	' Date......: 03/05/20
	' Release...: 12
	' Overview..: Menu option changed. 
	' Amendee...: D Morris
	' Details...:  Mod: Activity_Create() option now Edit Account.
	'
	' Date......: 11/05/20
	' Release...: 13
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 16/05/20
	' Release...: 14
	' Overview..: Issue #0390 - No back arrow in title bar for Settings and Enter card activitues.
	'		      Mod: Menu options changed
	' Amendee...: D Morris
	' Details...:  Mod: Card entry Menu options changed to remove account.
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
	#IncludeTitle: true
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	
	Private hc As hSelectPlayCentre ' This activity's helper class.
End Sub

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
	Activity.Title = "Select centre"	' This appears necessary (setting in form designer don't work).
	Activity.AddMenuItem("Edit Account", "mnuChangeAccountInfo")
	Activity.AddMenuItem("Settings", "mnuChangeSettings")
	Activity.AddMenuItem("New account", "mnuNewAccount")
	Activity.AddMenuItem("Remove Account", "mnuRemoveAccount")
	Activity.AddMenuItem("Show Location", "mnuShowLocation")
	Activity.AddMenuItem("About", "mnuAbout")
End Sub

' Inhibit back button.
Sub Activity_Keypress(KeyCode As Int) As Boolean
	Dim rtnValue As Boolean = False ' Initialised to False, as that will allow the event to continue
	
	' Prevent 'Back' softbutton, from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
'	If KeyCode = KeyCodes.KEYCODE_BACK And Not(Starter.settings.testMode) Then ' The 'Back' softbutton was pressed, and not test mode
	If KeyCode = KeyCodes.KEYCODE_BACK Then ' The 'Back' softbutton was pressed,
		rtnValue = True ' Returning true consumes the event, preventing the 'Back' action
	End If
	
	Return rtnValue
End Sub

Sub Activity_Resume
	Log("StartPlayCentre - Activity_Resume run!")
	hc.SelectCentre
End Sub

Sub Activity_Pause (UserClosed As Boolean)
'	If mClosingActivity Then Activity.Finish
'	hc.LocationDeviceOFF - removed see bugfix #0180.
	hc.Onclose
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles menu option About.
Private Sub mnuAbout_Click
	StartActivity(About)
End Sub

' Handles menu option Change Customer information
Private Sub mnuChangeAccountInfo_Click
	hc.IChangeAccountInfo
End Sub

' Handles menu option Settings
Private Sub mnuChangeSettings_Click
	hc.lChangeSettings
End Sub

' Handles menu option New Account
Private Sub mnuNewAccount_Click
'	StartActivity(QueryNewInstall)
	hc.NewAccount
End Sub

' Handles menu option to remove/clear account.
Private Sub mnuRemoveAccount_Click()
	hc.ClearAccount
End Sub

' Handles menu option to show location
Private Sub mnuShowLocation_Click
	hc.ShowLocation
End Sub
#End Region  Event Handlers

#Region  Public Subroutines

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines


