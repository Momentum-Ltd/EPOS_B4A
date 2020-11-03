B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=10
@EndOfDesignText@
'
' Select Play Centre 3 (version to support New UI)
'

#Region  Documentation
	'
	' Name......: aSelectPlayCentre3
	' Release...: 3
	' Date......: 02/11/20
	'
	' History
	' Date......: 02/08/20
	' Release...: 1
	' Created by: D Morris.
	' Details...: based on xSelectPlayCentre2_v2.
	'	
	' Date......: 15/10/20
	' Release...: 2
	' Overview..: Support to indicate page is visible. 
	' Amendee...: D Morris
	' Details...: Added: IsVisible().
	'				
	' Date......: 02/11/20
	' Release...: 3
	' Overview..: Improved display centre list operation.
	' Amendee...: D Morris
	' Details...: Mod: Activity_Resume().
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
	#IncludeTitle: false
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private xui As XUI							'ignore (to remove warning) -  Required for X platform operation.
	Private hc As hSelectPlayCentre3 			' This activity's helper class.
End Sub

Sub Activity_Create(FirstTime As Boolean)


	hc.Initialize(Activity)
	' Setup menu button
	Activity.Title = "Select centre"	' This appears necessary (setting in form designer don't work).
	Activity.AddMenuItem("Edit Account", "mnuChangeAccountInfo")
	Activity.AddMenuItem("Settings", "mnuChangeSettings")
	Activity.AddMenuItem("New account", "mnuNewAccount")
	Activity.AddMenuItem("Remove Account", "mnuRemoveAccount")
	Activity.AddMenuItem("Show Location", "mnuShowLocation")
	Activity.AddMenuItem("About", "mnuAbout")
	' Setup refresh button
	Activity.AddMenuItem3("", "refresh", xui.LoadBitmapResize(File.DirAssets, "ic_cached_white_24dp.png", 32dip, 32dip, True), True)
End Sub

' Inhibit back button.
Sub Activity_Keypress(KeyCode As Int) As Boolean
	Dim rtnValue As Boolean = False ' Initialised to False, as that will allow the event to continue
	
	' Prevent 'Back' softbutton, from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
	If KeyCode = KeyCodes.KEYCODE_BACK Then ' The 'Back' softbutton was pressed,
		rtnValue = True ' Returning true consumes the event, preventing the 'Back' action
	End If
	Return rtnValue
End Sub

Sub Activity_Resume
	Log("StartPlayCentre - Activity_Resume run!")
' Insert for old system	
	Wait for (CheckPermission) complete(result As Boolean)
'	hc.SelectCentre(result)

' Insert for new system
	hc.StartLocationUpdates

End Sub

Sub Activity_Pause (UserClosed As Boolean)
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

' Hendle refresh list title bar item.
Private Sub refresh_Click
	hc.Refresh
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Is Select Play Centre Screen visible?
Public Sub IsVisible As Boolean
	Return (IsPaused(Me) = False)
End Sub

' Show the Account menu
Public Sub ShowMenu
	Activity.OpenMenu	
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Check Location Permission
' Returns true of permission available.
' NOTE: Needs to be activity see .
Private Sub CheckPermission As ResumableSub
	Log("Checking fine location permission...")
	Dim perms As RuntimePermissions'
	If perms.Check(perms.PERMISSION_ACCESS_FINE_LOCATION) = False Then
		Dim msg As String = "This App will ask permission to use your device's location." & CRLF & _
		"This information is used within the App to find local centres or to check you are in the centre." & CRLF & _
		"It is not disclosed to any third parties!" & CRLF & CRLF & _
		"THE APP CANNOT RUN WITHOUT YOU ALLOWING LOCATION"
		
		' To programmatically display settings form see https://www.b4x.com/android/forum/threads/settings-screen-actions-using-intent.19339/		
		
		xui.MsgboxAsync( msg, "Location permission")
		wait for MsgBox_result(resultPermission As Int)
	End If
	perms.CheckAndRequest(perms.PERMISSION_ACCESS_FINE_LOCATION)
	Wait For Activity_PermissionResult(permission As String, result As Boolean)
	Return result
End Sub
#End Region  Local Subroutines




