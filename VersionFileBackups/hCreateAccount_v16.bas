﻿B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' This is a helper class for the CreateAccount activity.
'
#Region  Documentation
	'
	' Name......: hCreateAccount
	' Release...: 16
	' Date......: 22/07/20
	'
	' History
	' Date......: 02/05/20
	' Release...: 1-
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	'
	' Versions
	'    v2 - 8 see v9
	'			
	' Date......: 26/04/20
	' Release...: 9
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	'			  Bug #0382: Spaces in passwords - now filtered out.
	' Amendee...: D Morris.
	' Details...:  Mod: SubmitNewCustomer()
	'			   Mod: lCreateAccount() - code addded to create new FCM Token and prompt customer to activate account. 
	'			   Bugfix 0382:ICreateAccount().
	'
	' Date......: 03/05/20
	' Release...: 10
	' Overview..: Added: #381 - Reveal passwords.	
	' Amendee...: D Morris
	' Details...: Mod: Support for reveal passwords.
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
	' Details...:  Mod: SubmitNewCustomer().
	'
	' Date......: 09/07/20
	' Release...: 14
	' Overview..: Bugfix: Input filter causing system to lockup.
	' Amendee...: D Morris.
	' Details...:  Removed: TextChanged events - caused program to lockup.
	'				   Mod: lCreateAccount() - check junk folder added.
	'
	' Date......: 19/07/20
	' Release...: 15
	' Overview..: Start on new UI theme (First phase changing buttons to Orange with rounded corners.. 
	' Amendee...: D Morris.
	' Details...: Mod: Buttons changed to swiftbuttons.
	'
	' Date......: 22/07/20
	' Release...: 16
	' Overview..: New UI Create Account.
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
	Private xui As XUI								'ignore (to remove warning)
	
	' Misc objects	
	Private progressbox As clsProgressIndicator		' Progress box
	
	' View declarations
	
	Private btnSubmit As SwiftButton				' Button to submit customer details.
	Private indLoading As B4XLoadingIndicator		' In progress indicator
	Private lblBackbutton As B4XView				' Back button 
	Private lblPrivacyPolicy As B4XView				' Link to Privacy Policy
	Private pnlEnterDetails As Panel				' Panel for entering details.	
	Private pnlHeader As Panel						' Header panel
	Private txtEmailAddress As B4XFloatTextField	' Customer's email
	Private txtName As B4XFloatTextField			' Customer's name.

	Private txtPassword As B4XFloatTextField		' Customer's password
	Private txtVerifyPassword As B4XFloatTextField	' Verify customer's password

End Sub

' This is the Main entry point.
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmCreateAccount")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handle Submit information pressed
Private Sub btnSubmit_Click
	wait for (CreateAccount) complete (createdOk As Boolean)
	If createdOk Then
#if B4A
		StartActivity(CheckAccountStatus)
#Else
		frmCheckAccountStatus.Show(False)
#End If
	End If
End Sub

' Handle Back button in title bar
private Sub lblBackbutton_Click
#if B4A
	StartActivity(QueryNewInstall)
#else
	frmQueryNewInstall.show
#End If
End Sub

' Hyperlink to display privacy policy in Browser.
private Sub lblPrivacyPolicy_Click
	modEposApp.DisplayPrivacyNotice
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then
		ProgressHide		' Just in-case.
	End If
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

' Create the new customer Account (rejected if not correct)
private Sub CreateAccount As ResumableSub
	Dim accountCreated As Boolean = False
	' First validate all the fields
	ProgressShow
	Dim errorMsg As String = ""
	Dim emailAddress As String = modEposWeb.FilterEmailInput(txtEmailAddress.Text.Trim) ' Filter email text.
	txtEmailAddress.Text = emailAddress ' Write it back to screen	
	Dim name As String  = modEposWeb.FilterStringInput(txtName.Text.Trim)
	Dim password As String = txtPassword.text.Trim
	txtPassword.Text = password
	Dim verifyPassword As String = txtVerifyPassword.Text.trim
	txtVerifyPassword.Text = verifyPassword
	If emailAddress <> "" And name <> "" _
		And password <> "" And verifyPassword <> "" Then	
		If password = verifyPassword Then ' Password and its verification is the same?
			If modEposApp.CheckEmailFormat(emailAddress) Then ' Password format ok?
				Wait for (EmailAlreadyExist(emailAddress)) complete (emailExists As Boolean) 'Check email is OK.
				If emailExists = False Then' Email is unique?
#if B4A		
					Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")' TODO Does this needs to be resummable?
#else ' B4I
					wait for (Main.GetFirebaseToken()) complete (fcmToken As String)
#End If
					If fcmToken <> "" Then 					
						Wait for (SubmitNewCustomer) Complete (submitOk As Boolean) ' Update Webserver and local storage (and send activation email).
						If submitOk = True Then '
							ProgressHide
							Dim activateMsg As String = "Your account information has been accepted," & _
														" we have sent an activation email to the submitted email address." & CRLF & CRLF & _
														"Please click the activation link in the email To activation your account." & CRLF & _
														"(If not found, check your Junk folder)"
							xui.MsgboxAsync( activateMsg , "Please Activate Your Account")
							wait for Msgbox_Result(tempResult As Int)
							accountCreated = True
						Else
							errorMsg = "Problem in submitting a new customer, please try again."
						End If
					Else
						errorMsg = "Problem with the FCM string (=null)."
					End If
				Else	' Email already exists?
					errorMsg = "The specified email address is already in use."
				End If
			Else
				errorMsg = "The entered email address is not in a valid format."
			End If
		Else
			errorMsg = "The password and verify-password are not the same!"
		End If
	Else ' One of the fields isn't filled in
		errorMsg = "One of more of the fields has not been filled in."
	End If
	ProgressHide
	If errorMsg <> "" Then	' Display an error message if any field validation failed
		Log("Validation error: " & errorMsg)
		xui.MsgboxAsync(errorMsg, "Account Error")
		Wait For msgbox_result(tempResult As Int)
	End If
	Return accountCreated
End Sub

' Check if email already exists
private Sub EmailAlreadyExist(email As String) As ResumableSub
	Dim emailExists As Boolean = False
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait for (apiHelper.GetCustomerId(email)) complete (customerId As Int)
	If customerId > 0 Then
		emailExists = True
	End If
	Return emailExists
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	ControlUserInteraction(True)
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
	txtName.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
	txtEmailAddress.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
	txtPassword.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
	txtVerifyPassword.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
End Sub

' Collects the customer data entered in the form's text fields and submits it to the Web API as a new customer entry.
' This should only be called if the fields have first been validated - see the contents of btnNewCustomer_Click().
' Returns true if successful.
Private Sub SubmitNewCustomer As ResumableSub
	Dim customerObj As clsEposWebCustomerRec
	Dim successful As Boolean = False
	
	customerObj.Initialize
	Dim device As clsDeviceInfo : device.initialize	' Just in case the device type has changed
	customerObj.deviceType = device.GetDeviceType()
	customerObj.email = txtEmailAddress.Text.Trim ' This value MUST be validated beforehand, to prevent Web API rejection
#if B4A
	' TODO This need to be resummable.
	Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")
#else ' B4I
	wait for (Main.GetFirebaseToken()) complete (fcmToken As String)
#End If
	customerObj.fcmToken = fcmToken
	customerObj.hash = txtPassword.text.trim
	customerObj.name = txtName.Text.Trim
	Dim jsonToSend As String = customerObj.GetJson
	If customerObj.fcmToken <> "" Then
		Log("Sending the customer details to the Web API:" & CRLF & jsonToSend)
		Dim job As HttpJob : job.Initialize("NewCustomer", Me)
		Dim msg As String = Starter.server.URL_CUSTOMER_API
		job.PostString(msg, jsonToSend)
		job.GetRequest.SetContentType("application/json;charset=UTF-8")	
		Wait For (job) JobDone(job As HttpJob)
		If job.Success And job.Response.StatusCode = 200 Then
			Dim rxCustomerIDStr As String = job.GetString
			Dim apiCustomerId As Int = 0
			If rxCustomerIDStr <> "" Then
				apiCustomerId = rxCustomerIDStr
			End If 
			Log("Success received from the Web API – new customer ID: " & rxCustomerIDStr)
			' Save the entered details (currently bodged, as the fields don't correlate properly)
			customerObj.rev = modEposWeb.ConvertApiIdtoRev(apiCustomerId) ' Now we have the apiCustomerId - so get the revision.
			customerObj.ID = modEposWeb.ConvertApiIdToCustomerId(apiCustomerId) ' and customerId.
			UpdateStoredCustomerInfo(apiCustomerId , customerObj)	' Updates the stored info with the new customerId with revision.		
			successful = True
		End If			
	Else
		ProgressHide
		xui.MsgboxAsync("ISubmitNewCustomer - FCM token = null", "FCM Token problem")
		wait for msgbox_result(tempResult As Int)
	End If
	ProgressHide 
	job.Release ' Must always be called after the job is complete, to free its resources
	Return successful
End Sub

' Show the process box
Private Sub ProgressHide
	ControlUserInteraction(True)
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow()
	ControlUserInteraction(False)
	progressbox.Show
End Sub

' Update and store the stored customer info.
' TODO Move to starter service (duplicated with code in hValidateDevice).
private Sub UpdateStoredCustomerInfo(apiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec)
	Starter.myData.customer.apiCustomerId = apiCustomerId
	Starter.myData.customer.address = customerInfoRec.address
	Starter.myData.customer.customerId = customerInfoRec.ID
	Starter.myData.customer.customerIdStr = NumberFormat2(apiCustomerId, 3, 0, 0, False)
	Starter.myData.customer.email = customerInfoRec.email
	Starter.myData.customer.name = customerInfoRec.name
	Starter.myData.customer.phoneNumber = customerInfoRec.telephone
	Starter.myData.customer.postCode = customerInfoRec.postCode
	Starter.myData.customer.rev = customerInfoRec.rev
	Starter.myData.Save
	Starter.customerInfoAvailable = True ' necessary to signal valid information available.
End Sub

#End Region  Local Subroutines

