B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' This is a help class for the ValidateDevice activity.
'
#Region  Documentation
	'
	' Name......: hValidateDevice
	' Release...: 23
	' Date......: 28/01/21
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	' 
	' Versions
	'   v2 - 8 see v9.
	'   v9 - 17 see v17.
	'		
	' Date......: 15/12/20
	' Release...: 18
	' Overview..: Issue: #0559 Email address now included in activation messages.
	'			  Bugfix: Now check email format before using.
	' Amendee...: D Morris
	' Details...:  Mod: ValidateTheDevice() email added to message.
	'			   Bugfix: lblForgotPassword_Click() checks and reports error if problems with email.
	'			   Mod: Code to clear email and password moved to OnClose().
	'
	' Date......: 03/01/21
	' Release...: 19
	' Overview..: Added: Forgot password Hyperlink now underlined.
	' Amendee...: D Morris.
	' Details...:  Mod: InitializeLocals() code added.
	'		
	' Date......: 23/01/21
	' Release...: 20
	' Overview..: Maintenance release Update to latest standards for CheckAccountStatus and associated modules. 
	' Amendee...: D Morris
	' Details...: Mod: ShowCheckAccountStatus() calls to CheckAccountStatus changed to aCheckAccountStatus and xCheckAccountStatus.
	'
	' Date......: 24/01/21
	' Release...: 21
	' Overview..: Bugfix (should have been done in v19) - Underline "Forgot password" hyperlink.
	' Amendee...: D Morris.
	' Details...: Mod: InitializeLocals().
	'
	' Date......: 27/01/21
	' Release...: 22
	' Overview..: new uses clsKeyboardHelper for keyboard handling.
	' Amendee...: D Morris
	' Details...: Mod: General changes to support clsKeyboardHelper.
	'
	' Date......: 28/01/21
	' Release...: 23
	' Overview..: Maintenance release - QueryNewInstall updated.
	' Amendee...: D Morris
	' Details...: Mod: lblBackbutton_Click().
	'		      Mod: Old commented out code removed.
	'             Mod: clsEposApiHelper is now global.
	'			  Mod: UpdateCustomerInfo(), lblForgotPassword_Click(), GetCustomerInfo(), lncCustomerRev() calls the API helper.
	'			  Mod: UpdateStoredCustomerInfo() - used cls.
	'			  Mod: InitializeLocals() now calls clsKeyboardHelper.SetupTextAndKeyboard() and clsEposApiHelper.initialize().
	'			  Mod: ShowCheckAccountStatus() renamed to ExitToCheckAccountStatus().
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
	
	Private xui As XUI								'ignore X-platform related.

	' Activity view declarations
	Private btnSubmit As SwiftButton				' Button to submit the account information.
	Private indLoading As B4XLoadingIndicator		' In progress indicator
	Private lblForgotPassword As B4XView			' Hyperlink to invoke send user password email.
	Private lblBackbutton As B4XView				' Back button
	Private pnlEnterDetails As Panel				' Panel for entering details.
	Private pnlHeader As Panel						' Header panel
	Private txtEmailAddress As B4XFloatTextField	' Entry field for user's email.
	Private txtPassword As B4XFloatTextField		' Entry field fpr password.
	
	' Misc objects
	Private apiHelper As clsEposApiHelper			' API helper.
	Private kbHelper As clsKeyboardHelper			' Keyboard handler
	Private progressbox As clsProgressIndicator		' Progress box
 End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmValidateDevice")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Submit user information 
Private Sub btnSubmit_Click
	ValidateTheDevice
End Sub

' Handle Back button in title bar
private Sub lblBackbutton_Click
#if B4A
	StartActivity(aQueryNewInstall)
#else
	xQueryNewInstall.show()
#End If
End Sub

' Request password email
Private Sub lblForgotPassword_Click
	Dim emailAddress As String = modEposWeb.FilterEmailInput(txtEmailAddress.Text) ' Filter email text.
	txtEmailAddress.Text = emailAddress ' Write it back
	If modEposApp.CheckEmailFormat(emailAddress) Then
'		Dim apiHelper As clsEposApiHelper
'		apiHelper.Initialize
		Wait for (apiHelper.ForgotPasswordEmailKnown(emailAddress)) complete (customerId As Int)
	Else
		xui.MsgboxAsync("Email not entered correctly" , "Email problem")
		wait for Msgbox_Result(tempResult As Int)
	End If
End Sub

#if B4i
' User clicks on Entry Panel (to hide keyboard)
Private Sub pnlEnterDetails_Click
	HideKeyboard
End Sub

' User clicks on header (to hide keyboard)
Private Sub pnlHeader_Click
	HideKeyboard
End Sub
#End If

#if B4i
' Handle hide keyboard required from keyboard helper class.
Private Sub kbHelper_HideKeyboard
	HideKeyboard
End Sub
#End If

#End Region  Event Handlers

#Region  Public Subroutines

#if B4i
' This method moves a text entry field so it does not get covered by the keyboard.
' B4XFloatTextField is taken from here: https://www.b4x.com/android/forum/threads/b4xfloattextfield-keyboard-hiding-views.118242/#post-740784
Public Sub MoveUpEnterDetailsPanel(height As Float)
	kbHelper.MoveUpEnterDetailsPanel(height)
End Sub
#End If

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then
		ProgressHide		' Just in-case.
	End If
	txtEmailAddress.Text = ""
	txtPassword.Text =""
End Sub

#if B4i
' Handle resize event
Public Sub Resize
	kbHelper.Resize
End Sub
#End If

' Performs the resume operation.
Public Sub Resume

End Sub

#End Region  Public Subroutines


#Region  Local Subroutines

' Enable/disable user interaction
'  Status = true all controls on screen enabled.
Private Sub ControlUserInteraction(status As Boolean)
#if B4A 
	pnlEnterDetails.Enabled = status
	pnlHeader.Enabled = status
#else ' B4i
	pnlEnterDetails.UserInteractionEnabled = status
	pnlHeader.UserInteractionEnabled = status
#End If	
End Sub

' Exit to check account status page
' Warning can't call this CheckAccountStatus in has problems with a module of the same name.
private Sub ExitToCheckAccountStatus
#if B4A
	StartActivity(aCheckAccountStatus)
#Else
	xCheckAccountStatus.Show(True)				
#End If
End Sub

' Get the Customer information from the Web Server (using the apiCustomerId)
' Returns clsEposWebCustomerRec (if error the clsEposWebCustomerRec it not initialised)
Private Sub GetCustomerInfo(apiCustomerId As Int) As ResumableSub
'	Dim apiHelper As clsEposApiHelper
'	apiHelper.Initialize
	Wait for (apiHelper.GetCustomerInfo(apiCustomerId)) complete (customerInfoRec As clsEposWebCustomerRec)
	Return customerInfoRec
End Sub

#if B4i
' Hide the keyboard.
Private Sub HideKeyboard
	xValidateDevice.HideKeyboard
End Sub
#End If

' Increments a customer's revision number.
' returns new customerId (with embedded rev) if email and password are ok (else -1 error).
Private Sub lncCustomerRev(email As String, password As String) As ResumableSub
'	Dim apiHelper As clsEposApiHelper
'	apiHelper.Initialize
	Wait for (apiHelper.IncrementCustomerIdRevision(email, password)) complete (customerId As Int)
	Return customerId
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	ControlUserInteraction(True)
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT,indLoading)
	apiHelper.Initialize
	Private cs As CSBuilder
	cs.Initialize.Underline.Color(Colors.White).Append("Forgot password").PopAll
	' See https://www.b4x.com/android/forum/threads/b4x-set-csbuilder-or-text-to-a-label.102118/
	XUIViewsUtils.SetTextOrCSBuilderToLabel(lblForgotPassword, cs)
	kbHelper.Initialize(Me, "kbHelper", pnlEnterDetails)
	Dim enterPanelTextFields() As B4XFloatTextField = Array As B4XFloatTextField(txtEmailAddress, txtPassword)
'#if B4i
'	kbHelper.AddViewToKeyboard2(enterPanelTextFields)
'#End If
'	kbHelper.SetupBackcolourAndBorder2(enterPanelTextFields)
'	kbHelper.RemovedTabOrder(enterPanelTextFields)
	kbHelper.SetupTextAndKeyboard(enterPanelTextFields)
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow()
	progressbox.Show()
End Sub

'' Exit to check account status page
'' Warning can't call this CheckAccountStatus in has problems with a module of the same name.
'private Sub ExitToCheckAccountStatus
'#if B4A
'	StartActivity(aCheckAccountStatus)
'#Else
'	xCheckAccountStatus.Show(True)				
'#End If
'End Sub

' Updates the customer info on the Web Server.
Private Sub UpdateCustomerInfo(apiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec) As ResumableSub
'	Dim updateOk As Boolean = False
'	Dim jsonToSend As String = customerInfoRec.GetJson
'	Dim job As HttpJob : job.Initialize("UpdateCustomer", Me)
'	job.PutString(Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0,0,False) , jsonToSend)
'	job.GetRequest.SetContentType("application/json;charset=UTF-8")
'	Wait For (job) JobDone(job As HttpJob)
'	If job.Success And job.Response.StatusCode = 200 Then
'		updateOk = True
'	End If
'	job.Release
'	Return updateOk
	Wait For (apiHelper.UpdateCustomerInfo(apiCustomerId, customerInfoRec)) complete (updateOk As Boolean)
	Starter.customerInfoAvailable = True ' necessary to signal valid information available.
	Return updateOk
End Sub

' Update and stored customer info.
private Sub UpdateStoredCustomerInfo(apiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec)
'	Starter.myData.customer.apiCustomerId = apiCustomerId
'	Starter.myData.customer.address = customerInfoRec.address
'	Starter.myData.customer.customerId = customerInfoRec.ID
'	Starter.myData.customer.customerIdStr = modEposWeb.ConvertToString(apiCustomerId)	
'	Starter.myData.customer.email = customerInfoRec.email
'	Starter.myData.customer.name = customerInfoRec.name
'	Starter.myData.customer.phoneNumber = customerInfoRec.telephone
'	Starter.myData.customer.postCode = customerInfoRec.postCode
'	Starter.myData.customer.rev = customerInfoRec.rev
'	Starter.myData.Save
'	Starter.customerInfoAvailable = True ' necessary to signal valid information available.
	Starter.myData.customer.Update(apiCustomerId, customerInfoRec)
	Starter.customerInfoAvailable = True ' necessary to signal valid information available.
	Starter.myData.Save()
End Sub

' Validate the device
Private Sub ValidateTheDevice
	Dim errorMsg As String = ""
	
	ProgressShow
	Dim emailAddress As String = modEposWeb.FilterEmailInput(txtEmailAddress.Text) ' Filter email text.
	txtEmailAddress.Text = emailAddress ' Write it back
	Dim password As String = modEposWeb.FilterStringInput(txtPassword.Text.trim)
	txtPassword.Text = password
	If emailAddress <> "" And password <> "" Then
		If modEposApp.CheckEmailFormat(emailAddress) Then ' Password format ok?
			Wait For (lncCustomerRev(emailAddress, txtPassword.Text.Trim)) complete (apiCustomerId As Int)
			If apiCustomerId > 0 Then ' Increment successful?
				Wait For (GetCustomerInfo(apiCustomerId)) complete (customerInfoRec As clsEposWebCustomerRec)
				If customerInfoRec.IsInitialized Then ' Check if valid data available
#if B4A
					Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")' TODO This needs to be resummable.
#else ' B4I
					wait for (Main.GetFirebaseToken()) complete (fcmToken As String)
#End If
					Dim device As clsDeviceInfo : device.initialize	' Just in case the device type has changed
					customerInfoRec.deviceType = device.GetDeviceType()
					customerInfoRec.fcmToken = fcmToken
					wait for (UpdateCustomerInfo(apiCustomerId, customerInfoRec)) complete (result As Boolean)
					If result Then
						UpdateStoredCustomerInfo(apiCustomerId , customerInfoRec)	' Updates the stored info with the new customerId and revision.
						ProgressHide
						xui.MsgboxAsync("Open the activation email" & CRLF & _
						"Sent to: " & customerInfoRec.email & CRLF & _ 
						"Then click on the link To activate your account." & CRLF & _
						"(IF NOT FOUND PLEASE CHECK IN YOUR JUNK FOLDER)" , "Activation Email sent")
						wait for Msgbox_Result(tempResult As Int)
						ExitToCheckAccountStatus	' Exit to Check Account status.
					Else ' Update customer info on Web failed.
						errorMsg = "Problem with Web Server updating information, please try again."
					End If
				Else ' Error - No information from Web Server.
					errorMsg = "Problem getting customer information from Web Server, please try again."
				End If
			Else ' invalid email/password.
				errorMsg = "Account Not found! Check your details"
			End If
		Else ' Problems with password format.
			errorMsg = "The entered email address is not in a valid format."
		End If		
	Else ' One of the fields isn't filled in
		errorMsg = "One of more of the fields has not been filled in."
	End If
	ProgressHide ' Belt and braces
	If errorMsg <> "" Then
		Log("Validate device failed: " & errorMsg) 
		xui.MsgboxAsync(errorMsg, "Account operation failed")
		Wait For msgbox_result(tempResult As Int)
	End If
End Sub

#End Region  Local Subroutines



