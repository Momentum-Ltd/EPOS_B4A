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
	' Name......: QueryNewInstall
	' Release...: 7
	' Date......: 22/07/20   
	'
	' History
	' Date......: 22/06/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 01/07/19
	' Release...: 2
	' Overview..: More code added to make the activity work.
	' Amendee...: D Morris
	' Details...: Added: Support to call Create new account and move account.
		'
	' Date......: 03/08/19
	' Release...: 3
	' Overview..: Work on X-platform.
	' Amendee...: D Morris
	' Details...:   Mod: code moved to helper class.
	'
	' Date......: 11/05/20
	' Release...: 4
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 16/05/20
	' Release...: 5
	' Overview..: Issue #0390 - No back arrow in title bar for Settings and Enter card activitues.
	' Amendee...: D Morris
	' Details...:  Mod: #IncludeTitle: now set to true.
	'			   Added: StdActionBar.
	'			   Mod: Activity_Resume() - hides/shows back button.
	'
	' Date......: 09/07/20
	' Release...: 6
	' Overview..: Bugfix: Back button not going to restart.
	' Amendee...: D Morris.
	' Details...: Bugfix: Activity_ActionBarHomeClick().
	'
	' Date......: 22/07/20
	' Release...: 7
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
	#IncludeTitle: false
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
 '   Private bar As StdActionBar			' Title bar
	Private hc As hQueryNewInstall 		' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
#if B4A
	StartActivity(CheckAccountStatus)
#else
	frmCheckAccountStatus.show(True)
#End If
End Sub

Sub Activity_Create(FirstTime As Boolean)
'	modEposApp.InitializeStdActionBar(bar, "bar")
'	Activity.Title = "Account"
	hc.Initialize(Activity)
End Sub

Sub Activity_Resume
'	If Starter.customerInfoAvailable = False Then ' Only show back button if customer information available.
''		modEposApp.InitializeStdActionBar(bar, "bar")	
'	End If
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


