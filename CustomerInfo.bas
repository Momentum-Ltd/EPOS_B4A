B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=8.3
@EndOfDesignText@
'
' Activity which allows the customer to enter their details.
'

#Region  Documentation
	'
	' Name......: CustomerInfo
	' Release...: 18
	' Date......: 26/04/20
	'
	' History
	' Date......: 19/07/18	
	' Created by: D Morris
	' Release...: 1
	'
	' Versions.....: 2 - 8 see v11.
	'                9 - 15 see v16.
	'
	' Date......: 17/11/19
	' Release...: 16
	' Overview..: Support for testMode as part of settings.
	' Amendee...: D Morris
	' Details...:  Mod: Back button operation Activity_Keypress().
	'
	' Date......: 21/03/20
	' Release...: 17
	' Overview..: #315 Issue removed B4A compiler warnings. 
	' Amendee...: D Morris
	' Details...:  Mod: lSubmitNewCustomer() msgbox() replaced with msgboxasync().
	'			      : lSubmitWebOperation() errorMsg removed.
	'			
	' Date......: 26/04/20
	' Release...: 18
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris.
	' Details...:  Mod: lCheckActivation(), lSubmitNewCustomer(), lSubmitWebOperation().
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
	#IncludeTitle: False
#End Region Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' Currently none
End Sub

Sub Globals
	
	' View declarations
	Private btnReady As Button
	Private btnSubmit As Button
	Private lblPrivacyPolicy As Label
	Private lblWelcomeCaption As Label
	Private pnlEnterDetails As Panel
	Private txtAddress As EditText
	Private txtAltPhone As EditText
	Private txtEmailAddress As EditText
	Private txtName As EditText
	Private txtPassword As EditText
	Private txtPhone As EditText
	Private txtPostcode As EditText
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmCustomerInfo")
	
End Sub

Sub Activity_Resume
	
'	lDisplayCurrentCustomerData

End Sub

Sub Activity_Pause(UserClosed As Boolean)
	If Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

Sub Activity_Keypress(KeyCode As Int) As Boolean
	Dim rtnValue As Boolean = False ' Initialised to False, as that will allow the event to continue
	
	' Prevent 'Back' softbutton, from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
	If KeyCode = KeyCodes.KEYCODE_BACK And Not(Starter.settings.testMode) Then ' The 'Back' softbutton was pressed, and not test mode
			rtnValue = True ' Returning true consumes the event, preventing the 'Back' action
	End If

	Return rtnValue
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

Sub btnSubmit_Click
	' First validate all the fields
	ProgressDialogShow("Submitting your details...")
	Dim errorMsg As String = ""
	If txtAddress.Text.Trim <> "" And txtAltPhone.Text.Trim <> "" And txtEmailAddress.Text.Trim <> "" And txtName.Text.Trim <> "" _
	And txtPassword.Text.Trim <> "" And txtPhone.Text.Trim <> "" And txtPostcode.Text.Trim <> "" Then
	
		
'		' Then validate the email address in more detail, otherwise the Web API will throw out the customer submission
'		' The following regex call to determine whether the email address has a valid format is taken from this snippet:
'		' https://www.b4x.com/android/forum/threads/validate-a-correctly-formatted-email-address.39803/
'		' Note that the regex call is not 100% accurate in some edge cases or completely exhaustive - see here:
'		' https://www.b4x.com/android/forum/threads/check-for-for-valid-email-and-characters.99581/#post-626823
'		Dim emailAddress As String = txtEmailAddress.Text.Trim
'		Dim MatchEmail As Matcher = Regex.Matcher("^(?i)[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])$", emailAddress)
'		If MatchEmail.Find = True Then ' Email address validation was successful
'			' Then, contact the Web API to check if that email address is already in use.
'			Log("Checking the email address using the Web API: " & emailAddress)
'			Dim job As HttpJob : job.Initialize("NewCustomer", Me)
'			job.Download("https://www.superord.co.uk/api/customer?email=" & emailAddress)
'			Wait For (job) JobDone(job As HttpJob)
'			If job.Success And job.Response.StatusCode = 200 Then
'				Dim rxInUse As String = job.GetString		
'				Log("Response successfully received from the Web API – email existence value: " & rxInUse)
'				If rxInUse = "0" Then ' The email address is NOT is use - proceed
'					' The fields have now been validated - proceed with submitting the customer details
'					Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")
'			'		If FirebaseMessaging.mMyFirebaseToken <> "" Then
'					If fcmToken <> "" Then
'						Wait for (lSubmitNewCustomer) Complete (result As Boolean)
'						If result = False Then
'							errorMsg = "Problem in submitting new customer"
'						End If
'					Else
'						errorMsg = "Problem with the FCM number (=null)."						
'					End If
'				Else ' The email is already in use
'					errorMsg = "The specified email address is already in use."
'				End If
'			Else ' An error of some sort occurred
'				Log("An error occurred while checking the email address: " & job.ErrorMessage)
'				ProgressDialogHide
'				MsgboxAsync("An error occurred while validating your details. Please try again.","Validation Error")
'				Wait For msgbox_result()
'			End If
'			job.Release ' Must always be called after the job is complete, to free its resources			
'		Else ' The email address is not in a valid format
'			errorMsg = "The entered email address is not in a valid format."
'		End If
		If Starter.settings.webOnlyComms Then
			lSubmitWebOperation
		Else
			lSubmitWifiOperation
		End If
		
	Else ' One of the fields isn't filled in
		errorMsg = "One of more of the fields has not been filled in."
	End If
	
	' Display an error message if any field validation failed
	If errorMsg = "" Then
	'	If Starter.settings.newWebStartup = False And Starter.settings.webOnlyComms = False Then
		If Starter.settings.webOnlyComms = False Then
			StartActivity(Connection)	' Wifi only so go straight to connect.
		End If
	Else
		Log("Validation error: " & errorMsg)
		ProgressDialogHide
		MsgboxAsync(errorMsg, "Cannot Submit New Customer")
		Wait For msgbox_result()
	End If	
End Sub

' Retry button handling.
Sub btnReady_Click
	lCheckActivation
End Sub

' Hyperlink to display privacy policy in Browser.
private Sub lblPrivacyPolicy_Click
'	Dim p As PhoneIntents
'	StartActivity(p.OpenBrowser("http://www.hangar51.co.uk/legal/privacypolicy"))
	modEposApp.DisplayPrivacyNotice
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Checks if any saved customer details are available, and if so, progresses to checking the email acitivation.
' Otherwise, displays the fields to enter and submit a new customers' details.
Public Sub pCheckCustomerDetails
	If Starter.customerInfoAvailable Then ' Go straight to checking activation
		pnlEnterDetails.Visible = False
		btnReady.Text = "Retry"
		btnReady.Visible = True
		lCheckActivation
	Else ' Customer info not available - create a new customer
		lblWelcomeCaption.text = "Welcome to SuperOrder! We need a few details before we begin:"
		btnReady.Visible = False
		pnlEnterDetails.Visible = True
	End If
End Sub

' Displays the form's controls in a state ready to submit new customer details.
Public Sub pCreateNewCustomer
	btnReady.Visible = False
	pnlEnterDetails.Visible = True
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Uses the Web API to check if the user has responded to the activation email, and if so, continues to the next step (connecting to the centre).
Private Sub lCheckActivation
	ProgressDialogShow("Checking your account for email activation...")
	lblWelcomeCaption.Text = "Connecting to your account..."
	Log("Checking the email activation status of the account: " & Starter.myData.customer.customerIdStr)
	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
'	job.Download("https://www.superord.co.uk/api/customer/" & Starter.myData.customer.customerIdStr & "?search=activated")
	Dim urlStr As String = modEposWeb.URL_CUSTOMER_API & "/" & modEposWeb.BuildApiCustomerId() & _
							"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_QUERY_ACTIVATED
	job.Download(urlStr)
	Wait For (job) JobDone(job As HttpJob)
	ProgressDialogHide
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxActivated As String = job.GetString
		Log("Response successfully received from the Web API – email activation value: " & rxActivated)
		If rxActivated = "1" Then ' Email is fine - continue to the connect-to-centre step
			 'StartActivity(Connection)
			StartActivity(xSelectPlayCentre)
		Else ' Customer has not activated their email address
			btnReady.Text = "Retry"
			btnReady.Visible = True
			MsgboxAsync("You have not clicked the link in the activation email we sent to you. Please do so and then press 'Retry'. ", "Email Not Activated")
			Wait For msgbox_result()
		End If
	Else ' Something went wrong with the HTTP job
		Log("An error occurred with the HTTP job: " & job.ErrorMessage)
		btnReady.Text = "Retry"
		btnReady.Visible = True
		MsgboxAsync("An error occurred while trying to check email activation. Please press 'Retry' to try again.", "Account Checking Error")
		Wait For msgbox_result()
	End If
End Sub

' Collects the customer data entered in the form's text fields and submits it to the Web API as a new customer entry.
' This should only be called if the fields have first been validated - see the contents of btnNewCustomer_Click().
' Returns true if successful.
Private Sub lSubmitNewCustomer As ResumableSub
	Dim customerObj As clsEposWebCustomerRec
	Dim successful As Boolean = False
	
	customerObj.Initialize
	customerObj.address = txtAddress.Text.Trim
	customerObj.altTelephone = txtAltPhone.Text.Trim
	customerObj.deviceType = 0 ' This signifies Android (see PostCodeTest.modEposWeb.enuDeviceType)
	customerObj.email = txtEmailAddress.Text.Trim ' This value MUST be validated beforehand, to prevent Web API rejection
	customerObj.fcmToken = CallSub(FirebaseMessaging, "GetFcmToken") ' FirebaseMessaging.mMyFirebaseToken
	customerObj.hash = txtPassword.text.trim
	customerObj.name = txtName.Text.Trim
	customerObj.postCode = txtPostcode.Text.Trim
	customerObj.telephone = txtPhone.Text.Trim
	Dim jsonToSend As String = customerObj.GetJson
	
	If customerObj.fcmToken = "" Then
		MsgboxAsync("ISubmitNewCustomer - FCM token = null", "FCM Token problem")
		Wait For msgbox_result()
	End If
	
	Log("Sending the customer details to the Web API:" & CRLF & jsonToSend)
	Dim job As HttpJob : job.Initialize("NewCustomer", Me)
'	job.PostString("https://www.superord.co.uk/api/customer", jsonToSend)
	Dim msg As String = modEposWeb.URL_CUSTOMER_API
	job.PostString(msg, jsonToSend)
	job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxCustomerIDstr As String = job.GetString
		Log("Success received from the Web API – new customer ID: " & rxCustomerIDstr)
		Dim apiCustomerId As Int = 0
		If rxCustomerIDstr <> "" Then
			apiCustomerId = rxCustomerIDstr
		End If
		' Save the entered details (currently bodged, as the fields don't correlate properly)
		Starter.myData.customer.customerIdStr = apiCustomerId
		Starter.myData.customer.customerId = modEposWeb.ConvertApiIdToCustomerId(apiCustomerId)
		Starter.myData.customer.email = txtEmailAddress.Text.trim
		Starter.myData.customer.name = txtName.Text.Trim
		Starter.myData.customer.nickName = ""
		Starter.myData.customer.address = txtAddress.Text.Trim
		Starter.myData.customer.postCode = txtPostcode.Text.Trim
		Starter.myData.customer.phoneNumber = txtPhone.Text.Trim
		Starter.myData.customer.rev = modEposWeb.ConvertApiIdtoRev(apiCustomerId)
		Starter.myData.Save
		
		pnlEnterDetails.Visible = False
		btnReady.Text = "Ready"
		btnReady.Visible = True
		ProgressDialogHide
		MsgboxAsync("New customer successfully submitted. We have sent an activation email to the submitted address." & CRLF & CRLF & _ 
						"Please click the activation link in the email, and then press 'Ready'.", "Please Activate Your Account")
		Wait For msgbox_result()
		successful = True
	Else ' An error of some sort occurred
		Log("An error occurred while submitting the customer details: " & job.ErrorMessage)
		ProgressDialogHide
		MsgboxAsync("An error occurred while trying to submit customer details. Please try again.", "Customer Details Submitting Error")
		Wait For msgbox_result()
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	Return successful
	
End Sub

' Submit for web operation.	
private Sub lSubmitWebOperation
	' Then validate the email address in more detail, otherwise the Web API will throw out the customer submission
	' The following regex call to determine whether the email address has a valid format is taken from this snippet:
	' https://www.b4x.com/android/forum/threads/validate-a-correctly-formatted-email-address.39803/
	' Note that the regex call is not 100% accurate in some edge cases or completely exhaustive - see here:
	' https://www.b4x.com/android/forum/threads/check-for-for-valid-email-and-characters.99581/#post-626823
	Dim emailAddress As String = txtEmailAddress.Text.Trim

	Dim MatchEmail As Matcher = Regex.Matcher("^(?i)[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])$", emailAddress)
'	Dim errorMsg As String 
	If MatchEmail.Find = True Then ' Email address validation was successful
		' Then, contact the Web API to check if that email address is already in use.
		Log("Checking the email address using the Web API: " & emailAddress)
		Dim job As HttpJob : job.Initialize("NewCustomer", Me)
		' job.Download("https://www.superord.co.uk/api/customer?email=" & emailAddress)
		Dim urlStr As String = modEposWeb.URL_CUSTOMER_API & "?" & modEposWeb.API_EMAIL & "=" & emailAddress
		job.Download(urlStr)
		Wait For (job) JobDone(job As HttpJob)
		If job.Success And job.Response.StatusCode = 200 Then
			Dim rxInUse As String = job.GetString
			Log("Response successfully received from the Web API – email existence value: " & rxInUse)
			If rxInUse = "0" Then ' The email address is NOT is use - proceed
				' The fields have now been validated - proceed with submitting the customer details
				Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")
				'		If FirebaseMessaging.mMyFirebaseToken <> "" Then
				If fcmToken <> "" Then
					Wait for (lSubmitNewCustomer) Complete (result As Boolean)
'					If result = False Then
'						errorMsg = "Problem in submitting new customer"
'					End If
				Else
	'				errorMsg = "Problem with the FCM number (=null)."
				End If
'			Else ' The email is already in use
'				errorMsg = "The specified email address is already in use."
			End If
		Else ' An error of some sort occurred
			Log("An error occurred while checking the email address: " & job.ErrorMessage)
			ProgressDialogHide
			MsgboxAsync("An error occurred while validating your details. Please try again.","Validation Error")
			Wait For msgbox_result()
		End If
		job.Release ' Must always be called after the job is complete, to free its resources
'	Else ' The email address is not in a valid format
'		errorMsg = "The entered email address is not in a valid format."
	End If
End Sub

private Sub lSubmitWifiOperation
	' Save the entered details (currently bodged, as the fields don't correlate properly)
'	Starter.customerInfoData.customerIdStr = rxCustomerID
	Starter.myData.customer.email = txtEmailAddress.Text.trim
	Starter.myData.customer.name = txtName.Text.Trim
	Starter.myData.customer.nickName = ""
	Starter.myData.customer.address = txtAddress.Text.Trim
	Starter.myData.customer.postCode = txtPostcode.Text.Trim
	Starter.myData.customer.phoneNumber = txtPhone.Text.Trim
	Starter.myData.Save
End Sub
#End Region  Local Subroutines
