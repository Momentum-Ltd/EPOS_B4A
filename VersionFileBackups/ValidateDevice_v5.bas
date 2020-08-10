B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Activity handle Validate the Device
'
#Region  Documentation
	'
	' Name......: ValidateDevice
	' Release...: 5
	' Date......: 22/07/20   
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
	' Date......: 03/05/20
	' Release...: 3
	' Overview..: Added: #381 - Reveal passwords.	
	' Amendee...: D Morris
	' Details...: Mod: Title bar added.
	'
	' Date......: 11/05/20
	' Release...: 4
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 22/07/20
	' Release...: 5
	' Overview..: New UI startup.
	' Amendee...: D Morris
	' Details...: Mod: Title bar removed.
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
	#IncludeTitle: False
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private hc As hValidateDevice			' This activity's helper class.
End Sub

Private Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)	
End Sub

' Back button 
Private Sub Activity_Keypress(KeyCode As Int) As Boolean
	Return False ' ensures backbutton works
End Sub

Private Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
End Sub

Private Sub Activity_Resume
	hc.Resume
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines
'' Returns to caller.
public Sub GoBackToCaller
	Activity.Finish
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines

