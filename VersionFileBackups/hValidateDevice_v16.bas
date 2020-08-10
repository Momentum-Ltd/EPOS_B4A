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
	' Release...: 16
	' Date......: 22/07/20
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
	' Date......: 09/07/20
	' Release...: 14
	' Overview..: Bugfix: Input filter causing system to lockup.
	' Amendee...: D Morris.
	' Details...:  Removed: TextChanged events - caused program to lockup.
	'				   Mod: lValidateDevice() check junk folder added.
	'
	' Date......: 19/07/20
	' Release...: 15
	' Overview..: Start on new UI theme (First phase changing buttons to Orange with rounded corners.. 
	' Amendee...: D Morris.
	' Details...: Mod: Buttons changed to swiftbuttons.
		'
	' Date......: 22/07/20
	' Release...: 16
	' Overview..: New UI Move account.
	' Amendee...: D Morris
	' Details...: Mod: General changes
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
	Private xui As XUI								'ignore

	' Misc objects
	Private progressbox As clsProgressIndicator		' Progress box

	' Activity view declarations
	Private btnSubmit As SwiftButton				' Button to submit the account information.
	Private indLoading As B4XLoadingIndicator		' In progress indicator
	Private lblForgotPassword As B4XView			' Hyperlink to invoke send user password email.
	Private lblBackbutton As B4XView				' Back button
	Private pnlEnterDetails As Panel				' Panel for entering details.
	Private pnlHeader As Panel						' Header panel
	Private txtEmailAddress As B4XFloatTextField	' Entry field for user's email.
	Private txtPassword As B4XFloatTextField		' Entry field fpr password.
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
	StartActivity(QueryNewInstall)
#else
	frmQueryNewInstall.show()
#End If
End Sub

' Request password email
Private Sub lblForgotPassword_Click
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.ForgotPasswordEmailKnown(txtEmailAddress.Text.Trim)) complete (customerId As Int)
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

' Get the Customer information from the Web Server (using the apiCustomerId)
' Returns clsEposWebCustomerRec (if error the clsEposWebCustomerRec it not initialised)
Private Sub GetCustomerInfo(apiCustomerId As Int) As ResumableSub
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

' Initialize the locals etc.
private Sub InitializeLocals
	ControlUserInteraction(True)
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT,indLoading)
	txtEmailAddress.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
	txtPassword.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow()
	progressbox.Show()
End Sub

' Goes to check account status page
' Warning can't call this CheckAccountStatus in has problems with a module of the same name.
private Sub ShowCheckAccountStatus
#if B4A
	StartActivity(CheckAccountStatus)
#Else
	frmCheckAccountStatus.Show(True)				
#End If
End Sub

' Updates the customer info on the Web Server (using the apiCustomerId) 
Private Sub UpdateCustomerInfo(apiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec) As ResumableSub
	Dim updateOk As Boolean = False
	Dim jsonToSend As String = customerInfoRec.GetJson
	Dim job As HttpJob : job.Initialize("NewCustomer", Me)
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
private Sub UpdateStoredCustomerInfo(apiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec)
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
						UpdateStoredCustomerInfo(apiCustomerId , customerInfoRec)	' Updates the stored info with the new customerId with revision.
						ProgressHide
						xui.MsgboxAsync("Open the activiation email and click on the link to activate your account." & CRLF & _
						"(If not found, check your Junk folder)" , "Activation Email sent")
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



