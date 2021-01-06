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
	' Release...: 9
	' Date......: 15/12/20    
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
	' Date......: 15/12/20
	' Release...: 9
	' Overview..: Bugfix: Check account not timing correctly when restarted. 
	' Amendee...: D Morris
	' Details...: Mod: mPage_Appear() pCheckAccountStatus() renamed to StartCheckAccount().
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
	hc.StartCheckAccount
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' This should be called to ensure Activity_Create is run next time another Activity_Resume is run
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


#End Region  Local Subroutines


