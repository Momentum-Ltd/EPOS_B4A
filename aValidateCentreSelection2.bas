B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=10
@EndOfDesignText@
'
' Validate the correct centre has been selected.
'
#Region  Documentation
	'
	' Name......: aValidateCentreSelection2
	' Release...: 1
	' Date......: 30/01/21   
	'
	' History
	' Date......: 30/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on ValidateCentreSelection2_v3 - renamed.
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

