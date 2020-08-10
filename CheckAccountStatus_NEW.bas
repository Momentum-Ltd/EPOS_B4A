B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Web Startup - Checks the user account status then invokes the appropriate tasks.
'
#Region  Documentation
	'
	' Name......: CheckAccountStatus
	' Release...: 8-
	' Date......: 12/07/20    
	'
	' History
	' Date......: 22/06/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking.
	'
	' Date......: 01/07/19  
	' Release...: 2
	' Overview..: Support for activate account and new account. 
	' Amendee...: D Morris
	' Details...: Mod: Retry button removed
	'			  Mod: Registered account msgbox now has option to resend activate email, new account or retry.
	'
	' Date......: 03/07/19
	' Release...: 3
	' Overview..: Bugfix:
	' Amendee...: D Morris
	' Details...: Bugfix: lCheckWebAccount() job.release moved after the error report.
	'				 Mod: lCheckWebAccount() Improved operation when customerId not found on Server.
	'
	' Date......: 04/07/19
	' Release...: 4
	' Overview..: #region moved to correct place - no code changed.
	' Amendee...: D Morris
	' Details...: Mod: #End Region  Mandatory Subroutines & Data moved to correct place.
	'
	' Date......: 28/07/19
	' Release...: 5
	' Overview..: Support for X platform operation (and software restructed). 
	' Amendee...: D Morris
	' Details...: Mod: tmrMinimumDisplayPeriod_tick() and lCheckWebAccount().
		'
	' Date......: 02/08/19
	' Release...: 6
	' Overview..: More work on x-platform operation.
	' Amendee...: D Morris
	' Details...:  Mod: Code moved to helper class hCheckAccountStatus.
	'
	' Date......: 17/10/19
	' Release...: 7
	' Overview..: General tidy-up. 
	' Amendee...: D Morris
	' Details...:  Mod: Commented out code removed.
	'
	' Date......: 11/05/20
	' Release...: 8
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 
	' Release...: 
	' Overview..: Investigation into GPS problem. 
	' Amendee...: D Morris.
	' Details...:   Mod: Activity_Create(), 
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
	#IncludeTitle: False
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
		Private xui As XUI
End Sub

Sub Globals
	' Added for x-platform
	Private hc As hCheckAccountStatus ' This activity's helper class.
End Sub


#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
End Sub

Sub Activity_Resume
'	SelectCentre
	hc.pCheckAccountStatus
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' This should be called to ensure Activity_Create is run next time other Activity_Resume is run
' See https://www.b4x.com/android/forum/threads/activity-finish-problem.87037/
public Sub DistroyActivity()
	Activity.Finish
End Sub

' Recreates (restart) this activity.
' Code taken from https://www.b4x.com/android/forum/threads/start-activity-from-the-same-activity.52347/#post-327832
Public Sub RecreateActivity
	Log("RecreateActivity called")
	Dim JavaObject1 As JavaObject
	JavaObject1.InitializeContext
	JavaObject1.RunMethod("NativeRecreateActivity", Null)
End Sub

#If JAVA
public void NativeRecreateActivity(){
    this.recreate();
}
#End If

#End Region  Public Subroutines

#Region  Local Subroutines

'Private Sub SelectCentre
''	Log("Checking fine location permission...")
'	Dim perms As RuntimePermissions'
'	If perms.Check(perms.PERMISSION_ACCESS_FINE_LOCATION) = False Then
'		Dim msg As String = "This App will ask permission to use your device's location." & CRLF & _
'		"This information is used within the App to find local centres or to check you are in the centre." & CRLF & _
'		"It is not disclosed to any third parties!" & CRLF & CRLF & _
'		"THE APP CANNOT RUN WITHOUT YOU ALLOWING LOCATION"
'		xui.MsgboxAsync( msg, "Location permission")
'		wait for MsgBox_result(resultPermission As Int)
'	End If
'	perms.CheckAndRequest(perms.PERMISSION_ACCESS_FINE_LOCATION)
'	Wait For Activity_PermissionResult(permission As String, result As Boolean)
'	If result Then ' Permission has been granted to use the location services
'		Log("Fine location permission OK. Connecting to location services...")
''		StartLocationService
''		mLocator.Connect ' This will then be handled in either mLocator_ConnectionSuccess() or mLocator_ConnectionFailed()
'		hc.pCheckAccountStatus
'	Else ' Location permission has been denied
'		xui.MsgboxAsync("The fine location permission has been denied. All centres will now be displayed.", "Cannot Get Location")
''		DisplayAllCentres
'	End If
'End Sub
#End Region  Local Subroutines


