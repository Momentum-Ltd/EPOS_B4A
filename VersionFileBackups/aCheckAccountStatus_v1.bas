B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Checks the user account status then invokes the appropriate tasks.
'
#Region  Documentation
	'
	' Name......: CheckAccountStatus
	' Release...: 1
	' Date......: 23/01/21    
	'
	' History
	' Date......: 23/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: As CheckAccountStatus_v9. Renamed to aCheckAccountStatus.
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

'' This should be called to ensure Activity_Create is run next time another Activity_Resume is run
'' See https://www.b4x.com/android/forum/threads/activity-finish-problem.87037/
'public Sub DistroyActivity()
'	Activity.Finish
'End Sub

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


