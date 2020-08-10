B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Activity to Create a new user account (will will only request and store the 
'	minimum required to enable a user to create an account.
'

#Region  Documentation
	'
	' Name......: CreateAccount
	' Release...: 6
	' Date......: 11/05/20   
	'
	' History
	' Date......: 07/07/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking (code taken from CustomerInfo).
		'
	' Date......: 30/0719
	' Release...: 2
	' Overview..: Account accepted message improved.
	' Amendee...: D Morris
	' Details...: Mod: lSubmitNewCustomer() message changed.
	'			  Mod: lblPrivacyPolicy_Click() now used ModEposApp.ShowPrivacyPolicy().
	'			  Removed: lCheckEmailFormat() now use ModEposApp.CheckEmailFormat() code changed in lCreateAccount().
	'
	' Date......: 03/08/19
	' Release...: 3
	' Overview..: Work on X-platform.
	' Amendee...: D Morris
	' Details...:   Mod: code moved to helper class.
		'
	' Date......: 07/08/19
	' Release...: 4
	' Overview..: Bugfix: Wrong screen shown. 
	' Amendee...: D Morris
	' Details...:  Bugfix: Now calls correct helper.
	'
	' Date......: 03/05/20
	' Release...: 5
	' Overview..: Added: #381 - Revail passwords.	
	' Amendee...: D Morris
	' Details...: Mod: Support for StdActionBar and title.
	'
	' Date......: 11/05/20
	' Release...: 6
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
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
	Private bar As StdActionBar			' New title bar
	Private hc As hCreateAccount 		' This activity's helper class.	
End Sub

Private Sub Activity_Create(FirstTime As Boolean)
	modEposApp.InitializeStdActionBar(bar, "bar")
	Activity.Title = "Create New Account"	' This appears necessary (setting in form designer don't work).
	hc.Initialize(Activity)
End Sub


'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
'	frm.ReportNoChanges
#if B4A
	StartActivity(QueryNewInstall)
#else
	frmQueryNewInstalls.show(True)
#End If
End Sub

' Back button 
Private Sub Activity_Keypress(KeyCode As Int) As Boolean
	Return False ' ensures backbutton works
End Sub

Private Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
End Sub

Private Sub Activity_Resume

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

#End Region  Public Subroutines
' Returns to caller.
public Sub GoBackToCaller
	Activity.Finish
End Sub
#Region  Local Subroutines

#End Region  Local Subroutines


