B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Web Start Validate correct centre selected.
'
#Region  Documentation
	'
	' Name......: ValidateCentreSelection
	' Release...: 9
	' Date......: 03/06/20   
	'
	' History
	' Date......: 07/07/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 28/07/19
	' Release...: 2
	' Overview..: Started support for X - Platform  
	' Amendee...: D Morris
	' Details...: Mod: lExitBackToSelectCentre() - calls pXSelectPlayCentre.
		'
	' Date......: 30/07/19
	' Release...: 3
	' Overview..: Bugfix: tmrConnectToCentreTimout in wrong place.
	' Amendee...: D Morris 
	' Details...: Bugfix: tmrConnectToCentreTimout moved to Process_Globals.
	'				 Mod: lStartSignOnToCentre() will now invoke Connection form if Web only disabled. 
	'
	' Date......: 03/08/19
	' Release...: 4
	' Overview..: Work on X-platform.
	' Amendee...: D Morris
	' Details...:   Mod: code moved to helper class.
	'
	' Date......: 13/10/19
	' Release...: 5
	' Overview..: Name changes.
	' Amendee...: D Morris
	' Details...: Mod: pConnectToServerResponse -> ConnectToServerResponse.
	'
	' Date......: 01/12/19
	' Release...: 6
	' Overview..: Support for handling response to Open Tab confirmation.
	' Amendee...: D Morris.
	' Details...: Added: OpenTabConfirmResponse().
	'
	' Date......: 11/05/20
	' Release...: 7
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 16/05/20
	' Release...: 8
	' Overview..: Now supports back button.
	' Amendee...: D Morris 
	' Details...:   Added: StdActionBar and associated code.
	'
	' Date......: 03/06/20
	' Release...: 9
	' Overview..: Issue #0175 - work improving signon.
	' Amendee...: D Morris.
	' Details...: Mod: ConnectToServerResponse() new paramenter added for centreSignonOk.
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
	#IncludeTitle: True
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private bar As StdActionBar					' New title bar
	Private hc As hValidateCentreSelection		' This activity's helper class.
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
	Activity.Title = "Validate Centre"	
	modEposApp.InitializeStdActionBar(bar, "bar")
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
