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
	' Release...: 9
	' Date......: 03/01/21
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	'
	' Versions
	'  2 - 6 v7
	'		
	' Date......: 26/11/20
	' Release...: 7
	' Overview..: Issue #0561 Viewing website information. 
	' Amendee...: D Morris
	' Details...: MOD: lblPrivacyPolicy_Click() - now uses webview.
	'			  Mod: Support for new UI style.
	'			  Mod: Will now always move back to select centre.
	'
	' Date......: 15/12/20
	' Release...: 8
	' Overview..: Enhanced web view (supports close button).
	' Amendee...: D Morris.
	' Details...: Mod: Support for web view clsoe button.
	'
	' Date......: 03/01/21
	' Release...: 9
	' Overview..: Bugfix: (Android) Hyperlinks no underlined, (iOS) Hyperlinks now correctly displayed.
	' Amendee...: D Morris.
	' Details...:  Mod: InitializeLocals() code fixed.
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
	Private xui As XUI						'ignore
	
	' View declarations
	Private btnWebClose As SwiftButton		' close web view button.
	Private lblAppName As B4XView			' App name.
	Private lblBackButton As B4XView		' Back button	
	Private lblPrivacyPolicy As B4XView		' Hypertext to show privacy policy.
	Private lblVersion As B4XView			' App version information.
	Private pnlWeb As Panel					' Border for the Web view.
	Private web As WebView					' Web view for showing privacy policy.

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmAbout")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers
'Exit form and restart.
Private Sub btnExitForm_Click
	ExitBackToSelectCentre
End Sub

' Close web view.
Sub btnWebClose_Click
	pnlWeb.Visible = False
End Sub

' Handle back button
private Sub lblBackButton_Click
	ExitBackToSelectCentre
End Sub

' Handler to display the privacy notice request.
Private Sub lblPrivacyPolicy_Click
	HandlePrivacyPolicy(True)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines
' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	HandlePrivacyPolicy(False)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Exits back to Select Centre - usually called when an error has occurred.
private Sub ExitBackToSelectCentre
#if B4A
	StartActivity(aSelectPlayCentre3)
#else
	frmXSelectPlayCentre3.Show
#End If
End Sub

' Will show or hide privacy policy
Private Sub HandlePrivacyPolicy(show As Boolean)
	web.LoadUrl(modEposWeb.URL_PRIVACY_POLICY)
	pnlWeb.Visible = show
	web.Visible = show
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
#if B4A
	lblAppName.Text = "App name:" & Application.PackageName
	lblVersion.Text = "Version:" & Application.VersionName
#Else
	lblAppName.Text = "App name: " & Main.GetAppName
	lblVersion.Text = "Version: " & Main.GetAppVersion
#End If
	Private cs As CSBuilder
	cs.Initialize.Underline.Color(Colors.White).Append("View Privacy Policy").PopAll
	' See https://www.b4x.com/android/forum/threads/b4x-set-csbuilder-or-text-to-a-label.102118/
	XUIViewsUtils.SetTextOrCSBuilderToLabel(lblPrivacyPolicy, cs)
End Sub

' Is this form shown
private Sub IsVisible As Boolean
#if B4A
	Return (CallSub(About, "IsVisible"))
#else ' B4i
	Return frmAbout.IsVisible
#End If
End Sub

#End Region  Local Subroutines