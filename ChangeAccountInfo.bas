B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Web Start - Change account information.
'
#Region  Documentation
	'
	' Name......: ChangeAccountInfo
	' Release...: 8
	' Date......: 23/05/20   
	'
	' History
	' Date......: 22/06/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 01/07/19  
	' Release...: 2
	' Overview..: Bugfix entering information and check if name is entered. 
	' Amendee...: D Morris
	' Details...: Bugfix: Now display correct prompts for entered information.
		'
	' Date......: 04/07/19
	' Release...: 3
	' Overview..: Bugfix: showing the password panel if change customer details run again.
	' Amendee...: D Morris
	' Details...:  Mod: btnSubmitPw_Click() will always switch back to data entry panel.
'
	' Date......: 03/08/19
	' Release...: 4
	' Overview..: Work on X-platform.
	' Amendee...: D Morris
	' Details...:   Mod: code moved to helper class.
	'
	' Date......: 08/02/20
	' Release...: 5
	' Overview..: New UI and Back button added to title bar.
	' Amendee...: D Morris.
	' Details...:  Mod: stdActionBar added and associated code.
	'
	' Date......: 03/05/20
	' Release...: 6
	' Overview..: Title changed. 
	' Amendee...: D Morris
	' Details...:  Mod: Activity_Create() title changed.
	'
	' Date......: 11/05/20
	' Release...: 7
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'		
	' Date......: 23/01/21
	' Release...: 8
	' Overview..: Maintenance release Update to latest standards for CheckAccountStatus and associated modules. 
	' Amendee...: D Morris
	' Details...: Mod: Calls to CheckAccountStatus changed to aCheckAccountStatus.
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
	Private frm As hChangeAccountInfo 	' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
	frm.ReportNoChanges
'#if B4A
	StartActivity(aCheckAccountStatus)
'#else
'	frmCheckAccountStatus.show(True)
'#End If
End Sub

private Sub Activity_Create(FirstTime As Boolean)
	modEposApp.InitializeStdActionBar(bar, "bar")
	Activity.Title = "Edit Account"	' This appears necessary (setting in form designer don't work).
	frm.Initialize(Activity)
End Sub

' Back button - warn user no Account info changed.
private Sub Activity_Keypress(KeyCode As Int) As Boolean
	frm.ReportNoChanges
	Return False ' ensures backbutton works
End Sub

private Sub Activity_Pause (UserClosed As Boolean)
	frm.OnClose
End Sub

private Sub Activity_Resume
	frm.DisplayInfo
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines
' Main method
public Sub pChangeAccountInfo
		
End Sub

' Returns to caller.
public Sub GoBackToCaller
	Activity.Finish
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines


#End Region  Local Subroutines


