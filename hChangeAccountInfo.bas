B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@

'
' This is a help class for ChangeAccountInfo
'
#Region  Documentation
	'
	' Name......: hChangeAccountInfo
	' Release...: 14
	' Date......: 19/07/20
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	'
	'	Versions
	'   v2 - 7 see v8.
	'
	' Date......: 26/04/20
	' Release...: 8
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris
	' Details...: Mod: lblAuthForgotPw_Click(), lGetLastestCustomerInfo(), lQueryPassword(), lUpdateAccountInfo().
	'
	' Date......: 03/05/20
	' Release...: 9
	' Overview..: Added: #381 - Reveal passwords.	
	' Amendee...: D Morris
	' Details...: Mod: Support for check box to show password.
	'		      Mod: Now must press OK to send password.
	'
	' Date......: 11/05/20
	' Release...: 10
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Added: OnClose().
	'
	' Date......: 26/05/20
	' Release...: 11
	' Overview..: Improvements to form (also checks on hinding views with keyboard).
	' Amendee...: D Morris
	' Details...: Mod: txtTelephone type now b4xFloattestfield.
	'			  Mod: txtTelephone_TextChanged() processing of text removed.
	'
	' Date......: 05/06/20
	' Release...: 12
	' Overview..: Bugfix: Typo error.
	' Amendee...: D Morris.
	' Details...: Mod: InitializeLocals() progressbox name spelt wrong.
	'
	' Date......: 09/07/20
	' Release...: 13
	' Overview..: Bugfix: Input filter causing system to lockup
	' Amendee...: D Morris.
	' Details...:  Removed: TextChanged events - caused program to lockup.
	'
	' Date......: 19/07/20
	' Release...: 14
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
	Private xui As XUI					'ignore
	
	' View declarations (consists of 2 panels)
	' Authorisation Panel
#if B4A
	Private chkAuthShowPw As CheckBox	' Show authorisation password.
#else 'B4i
	Private chkAuthShowPw As Switch		' Show authorisation password
#end if
	Private pnlAuthorisation As B4XView	' Password authorisation panel
#if B4A 
	Private txtAuthorisePw As EditText	' Password (entered by user).
#else ' B4i
	Private txtAuthorisePw As TextField
#end if
'	Private txtAuthorisePw As B4XView
	' Enter details panel
	Private btnClear As SwiftButton		' Clear displayed information button
	Private btnSubmit As SwiftButton	' Submit information button
	Private lblPrivacyPolicy As B4XView	' Link to Privacy Policy.
	Private pnlEnterDetails As B4XView	' Enter details panel
	Private txtAddress As B4XView		' Customer's address
	Private txtName As B4XView			' Customer's name
	Private txtPostCode As B4XView		' Customer's postcode	
	Private txtTelephone As B4XView		' Customer's telephone number
	
	' Misc objects	
#if B4I
	Private mHudObj As HUD 						' The HUD object used to display progress dialogs and toast messages.
#End If
	Private progressbox As clsProgressDialog			' Progress box
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmChangeAccountInfo")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handle clear information button.
Sub btnClear_Click
	If pnlEnterDetails.Visible = True Then ' Only works if edit details panel shown.
		txtAddress.Text = ""
		txtName.Text = ""
		txtPostCode.Text = ""
		txtTelephone.Text = ""	
	End If
End Sub

' Handle submit information button on the Enter details panel.
Sub btnSubmit_Click
	If pnlEnterDetails.Visible = True Then ' Only works if edit details panel shown.
		wait for (lCheckEnteredInformation) complete (infoOk As Boolean)
		If infoOk Then
			btnClear.mBase.Visible = False ' Switches to the authorisation panel to enter password
			pnlEnterDetails.Visible = False
			pnlAuthorisation.Visible = True 
			txtAuthorisePw.text = ""
		End If
	Else ' Authorization panel shown
		SubmitPassword
	End If
End Sub

#if B4A
' Handle show password checkbox.
Sub chkAuthShowPw_CheckedChange(Checked As Boolean)
	RevealPassword(Checked)
End Sub
#else ' B4i
' Handle show password switch.
Sub chkAuthShowPw_ValueChanged (Value As Boolean)
	RevealPassword(Value)
End Sub
#End If

' Handle forgot password request
Sub lblAuthForgotPw_Click
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.ForgotPasswordIdKnown(Starter.myData.customer.customerIdStr)) complete (customerId As Int)
End Sub

' Hyperlink to display privacy policy in Browser.
private Sub lblPrivacyPolicy_Click
	modEposApp.DisplayPrivacyNotice
End Sub

'' Check Address for invalid characters.
'Private Sub txtAddress_TextChanged(Old As String, New As String)
'	modEposWeb.TextBoxFilter(txtAddress, Old, New)
'End Sub
''
''' Detect the done button (password accepted)
''Sub txtAuthorisePw_EnterPressed
''	txtAuthorisePw.Text = modEposWeb.FilterStringInput(txtAuthorisePw.Text.trim)
''	SubmitPassword
''End Sub
'
'' Filter password for invalid text.
'Sub txtAuthorisePw_TextChanged (Old As String, New As String)
'	modEposWeb.TextBoxFilter(txtAuthorisePw, Old, New)
'End Sub
'
'' Check Name for invalid characters.
'private Sub txtName_TextChanged(Old As String, New As String)
'	modEposWeb.TextBoxFilter(txtName, Old, New)
'End Sub
'
'' Check txtPostCode for invalid characters.
'private Sub txtPostCode_TextChanged(Old As String, New As String)
'	modEposWeb.TextBoxFilter(txtPostCode, Old, New)
'End Sub
'
'' Check txtPostCode for invalid characters.
'private Sub txtTelephone_TextChanged(Old As String, New As String)
'	' Removed for test.
''	modEposWeb.TextBoxFilter(txtTelephone, Old, New)
'End Sub

#End Region  Event Handlers

#Region  Public Subroutines
' Display information
Public Sub DisplayInfo
	ProgressShow("Getting your information")
	Wait For (lGetLastestCustomerInfo) complete (infoOk As Boolean)
	ProgressHide
	If infoOk Then
		txtAuthorisePw.text = ""
		txtAddress.Text = Starter.myData.customer.address
		txtName.Text = Starter.myData.customer.name
		txtPostCode.Text = Starter.myData.customer.postCode
		txtTelephone.Text = Starter.myData.customer.phoneNumber
	Else
		xui.MsgboxAsync("Unable to get latest customer information, please retry!", "Cannot change information")
		wait for msgbox_result(tempResult As Int)
		lReturnToCaller
	End If
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

' Report no changes maded to data.
' Not ideal to use a toast message (but as this is usually called when the back button is pressed)
Public Sub ReportNoChanges
#if B4A	
	ToastMessageShow("Back button pressed" & CRLF & "No changes made.", True) 
#Else
	mHudObj.ToastMessageShow("Back button pressed" & CRLF & "No changes made.", True)
#End If

End Sub

#End Region  Public Subroutines

#Region  Local Subroutines
' Initialize the locals etc.
private Sub InitializeLocals
	If progressbox.IsInitialized = False Then
		progressbox.Initialize(Me, "progressbox",modEposApp.DFT_PROGRESS_TIMEOUT) 		
	End If
End Sub

' Checks if information entered on the form can be accepted.
' Returns True of information is ok.
private Sub lCheckEnteredInformation() As ResumableSub
	Dim informationOk As Boolean = False
	txtAddress.Text = modEposWeb.FilterStringInput(txtAddress.Text.Trim)
	txtName.Text = modEposWeb.FilterStringInput(txtName.Text.trim)
	txtPostCode.Text = modEposWeb.FilterStringInput(txtPostCode.Text.Trim)
	txtTelephone.Text = modEposWeb.FilterStringInput(txtTelephone.Text.trim)
	If txtName.Text.Trim <> "" Then	' Currently on a name is required.
		informationOk =True
	Else
		xui.MsgboxAsync("Name cannot be blank" & CRLF & CRLF & "Please retry!", "Name required")
		wait for msgbox_result
	End If
	Return informationOk
End Sub

' Gets the latest information from Web server
' Returns true if ok
Private Sub lGetLastestCustomerInfo As ResumableSub
	Dim infoOk As Boolean = False
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.SyncPhoneFromWebServer(Starter.myData.customer.customerIdStr)) complete (syncOk As Boolean)
	If syncOk Then
		infoOk = True
	End If
	Return infoOk
End Sub

' Checks if valid password for this user.
' Returns true if ok.
private Sub lQueryPassword(password As String) As ResumableSub
	Dim passwordOk As Boolean = False
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.CheckCustomerEmailAndPassword(Starter.myData.customer.email, password)) complete (customerId As Int)
	If customerId > 0 Then
		passwordOk = True
	End If
	Return passwordOk
End Sub

' Programmatically similates the back button.
private Sub lReturnToCaller
#if B4A
	CallSubDelayed(ChangeAccountInfo, "GoBackToCaller")
#End If
End Sub

' Handles the Submit customer information to the Web server
' Returns true if submission is ok
Private Sub lSubmitCustomerInformation() As ResumableSub
	Dim submitOk As Boolean = False
	ProgressShow("Saving the new information...")
	wait for (lQueryPassword(txtAuthorisePw.text.Trim)) complete (passwordOk As Boolean)
	If passwordOk Then
		wait for (lUpdateAccountInfo) complete (updateOk As Boolean)
		If updateOk Then
			submitOk = True
		End If
	Else
		ProgressHide
		xui.MsgboxAsync("No information changed!", "Wrong password")
		Wait For Msgbox_result(tempResult As Int)
	End If
	ProgressHide
	Return submitOk
End Sub

' Update account information on the web server
' returns true if update is ok.
private Sub lUpdateAccountInfo() As ResumableSub
	Dim updateOk As Boolean = False
	Starter.myData.customer.address = txtAddress.Text.Trim
	Starter.myData.customer.name = txtName.Text.Trim
	Starter.myData.customer.phoneNumber = txtTelephone.Text.Trim
	Starter.myData.customer.postCode = txtPostCode.Text.Trim
	Starter.myData.customer.Save
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.SyncWebServerToPhone(Starter.myData.customer.customerIdStr)) complete (syncOk As Boolean)
	If syncOk Then
		updateOk = True
	End If
	Return updateOk
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Handles reveal/hide password operation
private Sub RevealPassword(showPassword As Boolean)
	If showPassword = True Then
		txtAuthorisePw.PasswordMode = False
	Else
		txtAuthorisePw.PasswordMode = True
	End If
End Sub

' Handles submit password operation.
private Sub SubmitPassword
	Wait For (lSubmitCustomerInformation) complete (submitOk As Boolean)
	pnlAuthorisation.Visible = False ' Ensure enter details panel next time (i.e. if activity_resume is invoked).
	btnClear.mBase.Visible = True
	pnlEnterDetails.Visible = True
	If submitOk Then
#if B4A
		StartActivity(CheckAccountStatus)
#else
		frmCheckAccountStatus.show(True)
#End If
	End If
End Sub

#End Region  Local Subroutines

