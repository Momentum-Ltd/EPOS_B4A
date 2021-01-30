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
	' Name......: aAbout
	' Release...: 1
	' Date......: 30/01/21   
	'
	' History
	' Date......: 30/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: Based pm About_v4 - renamed.
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


