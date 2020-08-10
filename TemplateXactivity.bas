B4A=true
Group=Templates
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
'
' This X-platform activity platform.
'
#Region  Documentation
	'
	' Name......: 
	' Release...: 
	' Date......: 16/10/19
	'
	' History
	' Date......: 16/10/19
	' Release...: -
	' Created by: D Morris
	' Details...: based on .
	'
	' History
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
#End Region  Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' Currently none
End Sub

Sub Globals
	'Private hc As hHelperClass		' This activity's helper class.
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'hc.Initialize(Activity)
End Sub

Sub Activity_Resume
	'hc.ResumeOp
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If Starter.DisconnectedCloseActivities Then
		Activity.Finish
	End If
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines

