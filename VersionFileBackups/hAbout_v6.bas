B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@

'
' This is a help class for the About activity.
'
#Region  Documentation
	'
	' Name......: hAbout
	' Release...: 6
	' Date......: 02/08/20
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	'
	' Date......: 12/08/19
	' Release...: 2
	' Overview..: Changes to use latest modEposApp.
	' Amendee...: D Morris 
	' Details...:	Mod: Renamed pBuildCustomerName To BuildCustomerName.
	'
	' Date......: 22/10/19
	' Release...: 3
	' Overview..: Now returns to the Select Centre form when ok button pressed.
	' Amendee...: D Morris
	' Details...: Mod: btnExitForm_Click() goes to the Select centre form.
	'
	' Date......: 11/05/20
	' Release...: 4
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Added: OnClose().
	'
	' Date......: 28/06/20
	' Release...: 5
	' Overview..: Add #0395: Select Centre with Logos (Experimental).
	' Amendee...: D Morris.
	' Details...: Mod: ????
	'
	' Date......: 02/08/20
	' Release...: 6
	' Overview..: UI to select centre.
	' Amendee...: D Morris.
	' Details...: Mod: btnExitForm_Click().
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation


#Region  Mandatory Subroutines & Data


Sub Class_Globals
	' X-platform related.
	Private xui As XUI			'ignore
	
	' View declarations
	Private lblAppName As B4XView		' App name.
	Private lblPrivacyPolicy As B4XView	' Hypertext to show privacy policy.
	Private lblVersion As B4XView		' App version information.
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmAbout")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers
'Exit form and restart.
Sub btnExitForm_Click
#if B4A
	StartActivity(aSelectPlayCentre3)
#Else
	frmXSelectPlayCentre3.Show
#End If

End Sub

' Handler to display the privacy notice request.
Sub lblPrivacyPolicy_Click
	modEposApp.DisplayPrivacyNotice
End Sub

#End Region  Event Handlers

#Region  Public Subroutines
' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	' Nothing to do!
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines
' Initialize the locals etc.
private Sub InitializeLocals
#if B4A
	lblAppName.Text = "App name:" & Application.PackageName
	lblVersion.Text = "Version:" & Application.VersionName
#Else
	lblAppName.Text = "App name:" & Main.GetAppName
	lblVersion.Text = "Version:" & Main.GetAppVersion
#End If
End Sub

#End Region  Local Subroutines