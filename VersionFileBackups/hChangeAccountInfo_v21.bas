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
	' Release...: 21
	' Date......: 03/02/21
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	'
	'	Versions
	'   v2 - 7 see v8.
	'   v8 - 14 see v15.
	'
	'					
	' Date......: 09/10/20 
	' Release...: 15
	' Overview..: Bugfix: #0511 Screen locking into submit mode
	' Amendee...: D Morris
	' Details...: Mod: DisplayInfo() now handles which panels are visible.
	'
	' Date......: 03/01/21
	' Release...: 16
	' Overview..: Issue: #0561 Uses wb viewer for viewing website information. 
	'			  Bugfix: (Android) Hyperlinks no underlined, (iOS) Hyperlinks now correctly displayed.
	' Amendee...: D Morris
	' Details...:  Mod (issue): Support for web view.
	'			   Mod (bugfix): InitializeLocals() code fixed.
	'		
	' Date......: 23/01/21
	' Release...: 17
	' Overview..: Maintenance release Update to latest standards for CheckAccountStatus and associated modules. 
	' Amendee...: D Morris
	' Details...: Mod: SubmitPassword() calls to CheckAccountStatus changed to aCheckAccountStatus and xCheckAccountStatus.
	'
	' Date......: 24/01/21
	' Release...: 18
	' Overview..: Bugfix: #0582 - Underline "Forgot password" hyperlink.
	' Amendee...: D Morris.
	' Details...: Mod: InitializeLocals().
	'
	' Date......: 27/01/21
	' Release...: 19
	' Overview..: new uses clsKeyboardHelper for keyboard handling.
	' Amendee...: D Morris
	' Details...: Mod: General changes to support clsKeyboardHelper.
	'					
	' Date......: 30/01/21
	' Release...: 20
	' Overview..: Maintenance fix to support new names and remove 'l' and 'p' prefixes.
	' Amendee...: D Morris
	' Details...: Mod: lReturnToCaller().
	'			  Mod: General changes to removed 'l' and 'p' prefixes.
	'			  Mod: Old commented code removed.
	'			  Mod: kbHelper_HideKeyboard().
	'			  Mod: InitializeLocals() - New call to clsKeyboardHelper.SetupTextAndKeyboard().
	'					
	' Date......: 03/02/21
	' Release...: 21
	' Overview..: General maitenance.
	' Amendee...: D Morris
	' Details...: Mod: lReturnToCaller() renamed to ReturnToCaller().
	'			  Mod: clsApiHelper now global (to reduce code) - code changed accordlingly.
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
	Private lblAuthForgotPw As B4XView			' Forgot password hyperlink.
	Private pnlAuthorisation As B4XView			' Password authorisation panel
	Private txtAuthorisePw As B4XFloatTextField	' Password (entered by user).

	' Enter details panel
	Private btnClear As SwiftButton				' Clear displayed information button
	Private btnSubmit As SwiftButton			' Submit information button
	Private btnWebClose As SwiftButton			' close web view button.
	Private lblPrivacyPolicy As B4XView			' Link to Privacy Policy.
	Private pnlEnterDetails As Panel			' Enter details panel
	Private pnlWeb As B4XView					' Web view panel
	Private txtAddress As B4XFloatTextField		' Customer's address
	Private txtName As B4XFloatTextField		' Customer's name
	Private txtPostCode As B4XFloatTextField	' Customer's postcode
	Private txtTelephone As B4XFloatTextField	' Customer's telephone number
	Private web As WebView						' Web view
	
	' Misc objects	
	Private apiHelper As clsEposApiHelper		' API helper
	Private kbHelper As clsKeyboardHelper		' Keyboard handler
#if B4I
	Private mHudObj As HUD 						' The HUD object used to display progress dialogs and toast messages.
#End If
	Private progressbox As clsProgressDialog	' Progress box
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmChangeAccountInfo")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handle clear information button.
Private Sub btnClear_Click
	If pnlEnterDetails.Visible = True Then ' Only works if edit details panel shown.
		txtAddress.Text = ""
		txtName.Text = ""
		txtPostCode.Text = ""
		txtTelephone.Text = ""	
	End If
End Sub

' Handle submit information button on the Enter details panel.
Private Sub btnSubmit_Click
	If pnlEnterDetails.Visible = True Then ' Only works if edit details panel shown.
		wait for (CheckEnteredInformation) complete (infoOk As Boolean)
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

' Close web view.
Private Sub btnWebClose_Click
	pnlWeb.Visible = False
End Sub

#if B4i
' Handle hide keyboard required from keyboard helper class.
Private Sub kbHelper_HideKeyboard
	xChangeAccountInfo.HideKeyboard
End Sub
#End If

' Handle forgot password request
Private Sub lblAuthForgotPw_Click
'	Dim apiHelper As clsEposApiHelper
'	apiHelper.Initialize
	Wait for (apiHelper.ForgotPasswordIdKnown(Starter.myData.customer.customerIdStr)) complete (customerId As Int)
End Sub

' Hyperlink to display privacy policy in Browser.
private Sub lblPrivacyPolicy_Click
	HandlePrivacyPolicy(True)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines
' Display information
Public Sub DisplayInfo
	pnlAuthorisation.Visible = False ' Ensure correct panel is displayed.
	pnlEnterDetails.Visible = True
	btnClear.mBase.Visible = True
	ProgressShow("Getting your information")
	Wait For (GetLastestCustomerInfo) complete (infoOk As Boolean)
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
		ReturnToCaller
	End If
End Sub

#if B4i
' This method moves a text entry field so it does not get covered by the keyboard.
' B4XFloatTextField is taken from here: https://www.b4x.com/android/forum/threads/b4xfloattextfield-keyboard-hiding-views.118242/#post-740784
Public Sub MoveUpEnterDetailsPanel(height As Float)
	kbHelper.MoveUpEnterDetailsPanel(height)
End Sub
#End If

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

#if B4i
' Handle resize event
Public Sub Resize
	kbHelper.Resize
End Sub
#End If

#End Region  Public Subroutines

#Region  Local Subroutines
' Initialize the locals etc.
private Sub InitializeLocals
	apiHelper.Initialize
	If progressbox.IsInitialized = False Then
		progressbox.Initialize(Me, "progressbox",modEposApp.DFT_PROGRESS_TIMEOUT) 		
	End If
	Private cs As CSBuilder	
	cs.Initialize.Underline.Color(Colors.White).Append("View Privacy Policy").PopAll
	' See https://www.b4x.com/android/forum/threads/b4x-set-csbuilder-or-text-to-a-label.102118/
	XUIViewsUtils.SetTextOrCSBuilderToLabel(lblPrivacyPolicy, cs)
	Private newCs As CSBuilder
	newCs.Initialize.Underline.Color(Colors.White).Append("Forgot password").PopAll
	XUIViewsUtils.SetTextOrCSBuilderToLabel(lblAuthForgotPw, newCs)

	kbHelper.Initialize(Me, "kbHelper", pnlEnterDetails)
	'TODO Check this could be a problem as txtAuthorisePw is on a different panel.
	Dim enterPanelTextField() As B4XFloatTextField = Array As B4XFloatTextField(txtAddress, txtName, txtPostCode, txtTelephone, txtAuthorisePw)
	kbHelper.SetupTextAndKeyboard(enterPanelTextField)
End Sub

' Checks if information entered on the form can be accepted.
' Returns True of information is ok.
private Sub CheckEnteredInformation() As ResumableSub
	Dim informationOk As Boolean = False
	txtAddress.Text = modEposWeb.FilterStringInput(txtAddress.Text.Trim)
	txtName.Text = modEposWeb.FilterStringInput(txtName.Text.trim)
	txtPostCode.Text = modEposWeb.FilterStringInput(txtPostCode.Text.Trim)
	txtTelephone.Text = modEposWeb.FilterStringInput(txtTelephone.Text.trim)
	If txtName.Text.Trim <> "" Then	' Currently only a name is required.
		informationOk =True
	Else
		xui.MsgboxAsync("Name cannot be blank" & CRLF & CRLF & "Please retry!", "Name required")
		wait for msgbox_result
	End If
	Return informationOk
End Sub

' Gets the latest information from Web server
' Returns true if ok
Private Sub GetLastestCustomerInfo As ResumableSub
	Dim infoOk As Boolean = False
'	Dim apiHelper As clsEposApiHelper
'	apiHelper.Initialize
	Wait for (apiHelper.SyncPhoneFromWebServer(Starter.myData.customer.customerIdStr)) complete (syncOk As Boolean)
	If syncOk Then
		infoOk = True
	End If
	Return infoOk
End Sub

' Will show or hide privacy policy
Private Sub HandlePrivacyPolicy(show As Boolean)
	web.LoadUrl(modEposWeb.URL_PRIVACY_POLICY)
	pnlWeb.Visible = show
	web.Visible = show
End Sub

' Checks if valid password for this user.
' Returns true if ok.
private Sub QueryPassword(password As String) As ResumableSub
	Dim passwordOk As Boolean = False
'	Dim apiHelper As clsEposApiHelper
'	apiHelper.Initialize
	Wait for (apiHelper.CheckCustomerEmailAndPassword(Starter.myData.customer.email, password)) complete (customerId As Int)
	If customerId > 0 Then
		passwordOk = True
	End If
	Return passwordOk
End Sub

' Programmatically similates the back button.
private Sub ReturnToCaller
#if B4A
	CallSubDelayed(aChangeAccountInfo, "GoBackToCaller")
#End If
End Sub

' Handles the Submit customer information to the Web server
' Returns true if submission is ok
Private Sub SubmitCustomerInformation() As ResumableSub
	Dim submitOk As Boolean = False
	ProgressShow("Saving the new information...")
	wait for (QueryPassword(txtAuthorisePw.text.Trim)) complete (passwordOk As Boolean)
	If passwordOk Then
		wait for (UpdateAccountInfo) complete (updateOk As Boolean)
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

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Handles submit password operation.
private Sub SubmitPassword
	Wait For (SubmitCustomerInformation) complete (submitOk As Boolean)
	pnlAuthorisation.Visible = False ' Ensure enter details panel next time (i.e. if activity_resume is invoked).
	btnClear.mBase.Visible = True
	pnlEnterDetails.Visible = True
	If submitOk Then
#if B4A
		StartActivity(aCheckAccountStatus)
#else
		xCheckAccountStatus.show(True)
#End If
	End If
End Sub

' Update account information on the web server
' returns true if update is ok.
private Sub UpdateAccountInfo() As ResumableSub
	Dim updateOk As Boolean = False
	Starter.myData.customer.address = txtAddress.Text.Trim
	Starter.myData.customer.name = txtName.Text.Trim
	Starter.myData.customer.phoneNumber = txtTelephone.Text.Trim
	Starter.myData.customer.postCode = txtPostCode.Text.Trim
	Starter.myData.customer.Save
'	Dim apiHelper As clsEposApiHelper
'	apiHelper.Initialize
	Wait for (apiHelper.SyncWebServerToPhone(Starter.myData.customer.customerIdStr)) complete (syncOk As Boolean)
	If syncOk Then
		updateOk = True
	End If
	Return updateOk
End Sub

#End Region  Local Subroutines

