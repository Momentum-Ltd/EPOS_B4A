B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=10
@EndOfDesignText@
'
' Web Start Validate correct centre selected.
'
#Region  Documentation
	'
	' Name......: ValidateCentreSelection2
	' Release...: 3
	' Date......: 02/10/20   
	'
	' History
	' Date......: 02/08/20
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on ValidateCentreSelection_v9.
	'
	' Date......: 08/08/20
	' Release...: 2
	' Overview..: Old commented out code removed. 
	' Amendee...: D Morris
	' Details...: Mod: No code changed.
	'		
	' Date......: 02/10/20
	' Release...: 3
	' Overview..: Bugfix: #0500 - Validate Centre screen not showing picture after communication timeout.
	' Amendee...: D Morris
	' Details...: Mod: Activity_Resume() refreshes to page.
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
	Private hc As hValidateCentreSelection2		' This activity's helper class.
End Sub


' Back button pressed in title bar
Private Sub Activity_ActionBarHomeClick
	Activity.Finish
End Sub

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)		
End Sub

Sub Activity_Resume
	' This line causes problems by call ValidateSelection twice - however if removed the image is missing
	'		after the Centre WebSite is shown.
	ValidateSelection(Starter.selectedCentreLocationRec) ' Calls this to refresh the page with Centre info.
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Validate Centre selection
Public Sub ValidateSelection(centreDetails As clsEposWebCentreLocationRec)
	hc.MainValidateCentreSelection(centreDetails)
End Sub

' Handles a response to the Sign-on (Connect to centre) sent with pValidateCentreSelect().
'  Invoked when starter receives the response.
Public Sub ConnectToServerResponse(centreSignonOk As Boolean)
	hc.HandleConnectToServerResponse(centreSignonOk)
End Sub

' Handles response to Open Tab confirm message. 
Public Sub OpenTabConfirmResponse
	hc.HandleOpenTabConfirmResponse
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines

