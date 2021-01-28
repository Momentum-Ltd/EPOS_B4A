B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Web startup Query New Installation.
'

#Region  Documentation
	'
	' Name......: aQueryNewInstall
	' Release...: 1
	' Date......: 28/01/21   
	'
	' History
	' Date......: 28/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on QueryNewInstall_v8 with new name.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Activity Attributes 
	#FullScreen: true
	#IncludeTitle: false
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private hc As hQueryNewInstall 		' This activity's helper class.
End Sub

'Back button pressed.
private Sub Activity_ActionBarHomeClick
	StartActivity(aCheckAccountStatus)
End Sub

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
End Sub

Sub Activity_Resume
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines


