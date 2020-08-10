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
	' Release...: 1
	' Date......: 02/08/20   
	'
	' History
	' Date......: 02/08/20
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on ValidateCentreSelection_v9.
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
'	Private bar As StdActionBar					' New title bar
	Private hc As hValidateCentreSelection2		' This activity's helper class.
End Sub


' Back button pressed in title bar
Private Sub Activity_ActionBarHomeClick
	Activity.Finish
End Sub

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
	'#if CENTRE_LOGOS
'	Activity.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "drawing1.jpg", 100%x, 100%y, True))
	'#End If
End Sub

Sub Activity_Resume
'	Activity.Title = "Validate Centre"
'	modEposApp.InitializeStdActionBar(bar, "bar")
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

