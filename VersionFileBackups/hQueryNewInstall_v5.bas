B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@

'
' This is a help class for the QueryNewInstall activity.
'
#Region  Documentation
	'
	' Name......: hQueryNewInstall
	' Release...: 5
	' Date......: 19/05/20
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	'
	' Date......: 22/10/19
	' Release...: 2
	' Overview..: Changes to support B4i operation.
	' Amendee...: D Morris
	' Details...: Mod: btnCreateNewAccount_Click() and btnMoveAccount_Click() - code added to support B4I.
	'
	' Date......: 11/05/20
	' Release...: 3
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mod: OnClose().
	'
	' Date......: 16/05/20
	' Release...: 4
	' Overview..: Changes to screen text.
	' Amendee...: D Morris
	' Details...:  Mod: InitializeLocals() now builds a welcome message.
	'
	' Date......: 19/07/20
	' Release...: 5
	' Overview..: Start on new UI theme (First phase changing buttons to Orange with rounded corners.. 
	' Amendee...: D Morris.
	' Details...: Mod: Buttons changed to swiftbuttons.
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
	Private btnCreateNewAccount As SwiftButton	' Button to invoke create new customer account.
	Private btnMoveAccount As SwiftButton		' Button to move an existing account to this device.
	Private lblWelcomeCaption As B4XView		' Welcome message
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmQueryNewInstall")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data
' Button to create new account
Sub btnCreateNewAccount_Click
#if B4A
	StartActivity(CreateAccount)
#else ' B4I
	frmCreateAccount.Show
#end if
End Sub

' Button to move account to this device 
Sub btnMoveAccount_Click
#if B4A
	StartActivity(ValidateDevice)
#else ' B4I
	frmValidateDevice.Show
#End If

End Sub

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	' Nothing to do.
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines
' Initialize the locals etc.
private Sub InitializeLocals
	Dim msgPart As String = ""
	If Starter.customerInfoAvailable = False Then
		msgPart = "No account has been created for this device."
	End If
	lblWelcomeCaption.Text = "Welcome to SuperOrder" & CRLF & _
								msgPart & CRLF & "What do you want to do?"
End Sub

#End Region  Local Subroutines