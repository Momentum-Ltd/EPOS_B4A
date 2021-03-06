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
	' Release...: 5
	' Date......: 30/01/21
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
	' Date......: 11/11/20
	' Release...: 4
	' Overview..: Bugfix #0551 (Android tablets) Select centre screen unable to select the menu option.
	' Amendee...: D morris
	' Details...: Mod: Changed to using B4AListTemplate - This is a issue with Android see https://www.b4x.com/android/forum/threads/problem-with-openmenu-on-android-v5-1.124423/
	'				
	' Date......: 30/01/21
	' Release...: 5
	' Overview..: Maintenance - 'p' and 'l' prefixes removed.
	' Amendee...: D Morris
	' Details...: Mod: SelectMenuItem() 'l' prefixes removed.
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
	
	' For the option menu 
	Private Dialog As B4XDialog 				'ignore
	Private menuOptions As B4XListTemplate
'	Private Base As B4XView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
	' Setup menu button
'	Activity.Title = "Select centre"	' This appears necessary (setting in form designer don't work).

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
	Wait for (CheckPermission) complete(result As Boolean)
	hc.StartLocationUpdates
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	hc.Onclose
End Sub


#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Is Select Play Centre Screen visible?
Public Sub IsVisible As Boolean
	Return (IsPaused(Me) = False)
End Sub

' Show the Account menu
Public Sub ShowMenu
	CreateMenuTemplate
	Wait for (Dialog.ShowTemplate(menuOptions, "", "", "CANCEL")) complete(result As Int)
	If result = xui.DialogResponse_Positive Then
		SelectMenuItem(menuOptions.SelectedItem)
	End If
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

' Creates the menu options template (See C:\Projects\B4A_Dev\TestMenu for example of usage).
Private Sub CreateMenuTemplate
'	Base = Activity
'	Dialog.Initialize (Base)
	Dialog.Initialize(Activity)
	Dialog.Title = "Select option"
	menuOptions.Initialize
	menuOptions.Options = Array("Edit Account", "Settings", "New Account", _
									"Remove Account", "Show Location","About" )
	menuOptions.AllowMultiSelection = False
	menuOptions.MultiSelectionMinimum = 1
End Sub

' Handle a menu items
private Sub SelectMenuItem(item As String)
	Select item
		Case "About"
			StartActivity(aAbout)
		Case "Edit Account"
			hc.ChangeAccountInfo
		Case "New Account"
			hc.NewAccount
		Case "Remove Account"
			hc.ClearAccount
		Case "Settings"
			hc.ChangeSettings
		Case "Show Location"
			hc.ShowLocation
	End Select
End Sub
#End Region  Local Subroutines




