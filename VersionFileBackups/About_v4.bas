B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' This activity provides general information about this App 
'

#Region  Documentation
	'
	' Name......: About
	' Release...: 4
	' Date......: 26/11/20   
	'
	' History
	' Date......: 01/07/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 03/08/19
	' Release...: 2
	' Overview..: Work on X-platform.
	' Amendee...: D Morris
	' Details...:   Mod: code moved to helper class.
	'
	' Date......: 11/05/20
	' Release...: 3
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 26/11/20
	' Release...: 4
	' Overview..: Support for public IsVisible().
	' Amendee...: D Morris
	' Details...: Added: IsVisible() added.
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
	Private hc As hAbout 				'	 This activity's helper class.
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
' Is About Screen visible?
Public Sub IsVisible As Boolean
	Return (IsPaused(Me) = False)
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines


