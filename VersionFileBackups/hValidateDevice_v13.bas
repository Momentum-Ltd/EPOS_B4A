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
	' Release...: 13
	' Date......: 11/06/20
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	' 
	' Versions
	'   v2 - 8 see v9
	'
	' Date......: 26/04/20
	' Release...: 9
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev). 
	' Amendee...: D Morris
	' Details...:     Mod: lValidateDevice() now uses lncCustomerRev() and also updates the device type. 
	'			  Removed: lGetCustomerId() and lCustomerMustActivate() now redundant.
	'				  Mod: lUpdateCustomerInfo(), lUpdateStoredCustomerInfo().
	'
	' Date......: 03/05/20
	' Release...: 10
	' Overview..: Added: #381 - Reveal passwords.	
	' Amendee...: D Morris
	' Details...: Mod: Support for check box to show password.
	'
	' Date......: 11/05/20
	' Release...: 11
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mod: OnClose().
	'
	' Date......: 13/05/20
	' Release...: 12
	' Overview..: Issue #0315 remove compiler warnings.
	' Amendee...: D Morris.
	' Details...: Mod: lReturnToCaller() not used so removed.
	'
	' Date......: 11/06/20
	' Release...: 13
	' Overview..: Mod: Support for second Server.
	' Amendee...: D Morris.
	' Details...:  Mod: lUpdateCustomerInfo().
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

	' Misc objects
	Private progressbox As clsProgressDialog	' Progress box

	' Activity view declarations
	Private btnClear As B4XView				' Button to clear entered information on form.
	Private btnSubmit As B4XView 			' Button to submit the account information.
#if B4A
	Private chkShowPassword As CheckBox		' Show authorisation password.
#else ' B4i
	Private chkShowPassword As Switch	' Show authorisation password.
#end if
	Private lblForgotPassword As B4XView	' Hyperlink to invoke send user password email.
	Private txtEmailAddress As B4XView		' Entry field for user's email.
#if B4A
	Private txtPassword As EditText			' Entry field fpr password.
#else ' B4i
	Private txtPassword As TextField			' Entry field fpr password.
#end if 
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmValidateDevice")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers
' Clear button - clears display
Private Sub btnClear_Click
	txtEmailAddress.Text = ""
	txtPassword.Text = ""
End Sub

' Submit user information 
Private Sub btnSubmit_Click
	lValidateDevice
End Sub

'#if B4A
'' Handle reveal password checkbox.
'Sub chkShowPassword_CheckedChange(Checked As Boolean)
'	If chkShowPassword.Checked = True Then
'		txtPassword.PasswordMode = False
'	Else
'		txtPassword.PasswordMode = True
'	End If
'End Sub
'#else ' B4i
'' Handle reveal password checkbox.
'Sub chkShowPassword_ValueChanged (Value As Boolean)
'	If chkShowPassword.Value = True Then
'		txtPassword.PasswordMode = False
'	Else
'		txtPassword.PasswordMode = True
'	End If	
'End Sub
'#end if

#if B4A
' Handle reveal password checkbox.
Sub chkShowPassword_CheckedChange(Checked As Boolean)
	RevealPassword(Checked)
End Sub
#else ' B4i
' Handle reveal password checkbox.
Sub chkShowPassword_ValueChanged (Value As Boolean)
	RevealPassword(Value)
End Sub
#end if
' Request password email
Private Sub lblForgotPassword_Click
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.ForgotPasswordEmailKnown(txtEmailAddress.Text.Trim)) complete (customerId As Int)
End Sub

' Check Email address for invalid characters.
Private Sub txtEmailAddress_TextChanged(Old As String, New As String)
	modEposWeb.TextBoxFilterEmail(txtEmailAddress, Old, New)
End Sub

' Check Password for invalid characters.
Private Sub txtPassword_TextChanged(Old As String, New As String)
	modEposWeb.TextBoxFilter(txtPassword, Old, New)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then
		ProgressHide		' Just in-case.
	End If
End Sub

' Performs the resume operation.
Public Sub Resume
	txtEmailAddress.Text = ""
	txtPassword.Text =""	
	txtPassword.PasswordMode = False
End Sub
#End Region  Public Subroutines


#Region  Local Subroutines

' Goes to check account status page
' Warning can't call this CheckAccountStatus in has problems with a module of the same name.
private Sub ShowCheckAccountStatus
#if B4A
	StartActivity(CheckAccountStatus)
#Else
	frmCheckAccountStatus.Show(True)				
#End If
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
End Sub

' Validate the device
Private Sub lValidateDevice
	Dim errorMsg As String = ""
	
	ProgressShow("Checking your information...")
	Dim emailAddress As String = modEposWeb.FilterEmailInput(txtEmailAddress.Text) ' Filter email text.
	txtEmailAddress.Text = emailAddress ' Write it back to
	If modEposApp.CheckEmailFormat(emailAddress) Then ' Password format ok?
		Wait For (lncCustomerRev(emailAddress, txtPassword.Text.Trim)) complete (apiCustomerId As Int)
		If apiCustomerId > 0 Then ' Increment successful?
			Wait For (lGetCustomerInfo(apiCustomerId)) complete (customerInfoRec As clsEposWebCustomerRec)
			If customerInfoRec.IsInitialized Then ' Check if valid data available
	#if B4A
				Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")' TODO This needs to be resummable.
	#else ' B4I
				wait for (Main.GetFirebaseToken()) complete (fcmToken As String)
	#End If
				Dim device As clsDeviceInfo : device.initialize	' Just in case the device type has changed
				customerInfoRec.deviceType = device.GetDeviceType()				
				customerInfoRec.fcmToken = fcmToken
				wait for (lUpdateCustomerInfo(apiCustomerId, customerInfoRec)) complete (result As Boolean)
				If result Then
					lUpdateStoredCustomerInfo(apiCustomerId , customerInfoRec)	' Updates the stored info with the new customerId with revision.
					ProgressHide
					xui.MsgboxAsync("Open activiation email and click on the link to activate your account.", "Activation Email sent")	
					wait for Msgbox_Result(tempResult As Int)
					ShowCheckAccountStatus	' Exit to Check Account status.
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

	ProgressHide ' Belt and braces
	If errorMsg <> "" Then
		Log("Validate device failed: " & errorMsg)
		xui.MsgboxAsync(errorMsg, "Validate device failed")
		Wait For msgbox_result(tempResult As Int)
	End If
End Sub


' Get the Customer information from the Web Server (using the apiCustomerId)
' Returns clsEposWebCustomerRec (if error the clsEposWebCustomerRec it not initialised)
Private Sub lGetCustomerInfo(apiCustomerId As Int) As ResumableSub
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.GetCustomerInfo(apiCustomerId)) complete (customerInfoRec As clsEposWebCustomerRec)
	Return customerInfoRec
End Sub
 
' Increments a customer's revision number.
' returns new customerId (with embedded rev) if email and password are ok (else -1 error).
Private Sub lncCustomerRev(email As String, password As String) As ResumableSub
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.IncrementCustomerIdRevision(email, password)) complete (customerId As Int)
	Return customerId
End Sub

' Updates the customer info on the Web Server (using the apiCustomerId) 
Private Sub lUpdateCustomerInfo(apiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec) As ResumableSub
	Dim updateOk As Boolean = False
	Dim jsonToSend As String = customerInfoRec.GetJson
	Dim job As HttpJob : job.Initialize("NewCustomer", Me)
'	job.PutString(modEposWeb.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0,0,False) , jsonToSend)
	job.PutString(Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0,0,False) , jsonToSend)
	job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		updateOk = True
	End If
	job.Release
	Return updateOk
End Sub

' Update and store the stored customer info.
' TODO Move to starter service (duplicated with code in hCreateAccount).
private Sub lUpdateStoredCustomerInfo(apiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec)
	Starter.myData.customer.apiCustomerId = apiCustomerId
	Starter.myData.customer.address = customerInfoRec.address
	Starter.myData.customer.customerId = customerInfoRec.ID
	Starter.myData.customer.customerIdStr = modEposWeb.ConvertToString(apiCustomerId)	
	Starter.myData.customer.email = customerInfoRec.email
	Starter.myData.customer.name = customerInfoRec.name
	Starter.myData.customer.phoneNumber = customerInfoRec.telephone
	Starter.myData.customer.postCode = customerInfoRec.postCode
	Starter.myData.customer.rev = customerInfoRec.rev
	Starter.myData.Save
	Starter.customerInfoAvailable = True ' necessary to signal valid information available.
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

'' Programmatically similates the back button.
'private Sub lReturnToCaller
'#if B4A
'	CallSubDelayed(ChangeAccountInfo, "GoBackToCaller")
'#End If
'End Sub

' Handles reveal/hide password operation
private Sub RevealPassword(showPassword As Boolean)
	If showPassword = True Then
		txtPassword.PasswordMode = False
	Else
		txtPassword.PasswordMode = True
	End If
End Sub

#End Region  Local Subroutines



