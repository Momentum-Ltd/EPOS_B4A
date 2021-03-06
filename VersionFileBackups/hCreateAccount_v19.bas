B4A=true
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
	' Release...: 19
	' Date......: 03/01/21
	'
	' History
	' Date......: 02/05/20
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking
	'
	' Versions
	'    v2 - 8 see v9
	'    v9 - 17 see v17
	'		
	' Date......: 15/12/20
	' Release...: 18
	' Overview..:  Issue: #0559 Email address now included in activation messages.
	'			   Issue: #0561 Uses wb viewer for viewing website information. 
	' Amendee...: D Morris
	' Details...:  Mod: CreateNewAccount() email added to message.
	'
	' Date......: 03/01/21
	' Release...: 19
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
	Private xui As XUI								'ignore (to remove warning)
	
	' Misc objects	
	Private progressbox As clsProgressIndicator		' Progress box

	
	' View declarations
	Private btnSubmit As SwiftButton				' Button to submit customer details.
	Private btnWebClose As SwiftButton				' close web view button.
	Private indLoading As B4XLoadingIndicator		' In progress indicator
	Private lblBackbutton As B4XView				' Back button 
	Private lblPrivacyPolicy As B4XView				'ignore Link to Privacy Policy
	Private pnlEnterDetails As Panel				' Panel for entering details.	
	Private pnlHeader As Panel						' Header panel
	Private pnlWeb As B4XView						' Web view panel
	Private txtEmailAddress As B4XFloatTextField	' Customer's email
	Private txtName As B4XFloatTextField			' Customer's name.
	Private txtPassword As B4XFloatTextField		' Customer's password
	Private txtVerifyPassword As B4XFloatTextField	' Verify customer's password
	Private web As WebView							' Web view

	' Used to handle keyboard operation.
#if B4I 
	Dim gWidth As Int								' Saved screen width.
	Dim gPnl_Hide As Panel							' Panel added above keyboard the hide keyboard button.
	Dim gIm_Hide As ImageView						' Hide keyboard button.
	
	Private pnlEnterDetailsOrgTop As Int 			' Original top of the Text entry panel (used for moving it above keyboard).
#End If

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
	wait for (CreateNewAccount) complete (createdOk As Boolean)
	If createdOk Then
#if B4A
		StartActivity(CheckAccountStatus)
#Else
		frmCheckAccountStatus.Show(False)
#End If
	End If
End Sub

' Close web view.
Sub btnWebClose_Click
	pnlWeb.Visible = False
End Sub

#if B4i
' User clicks on hide keyboard
Sub Im_Hide_Click
	HideKeyboard
End Sub
#End If

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
	HandlePrivacyPolicy(True)
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

#End Region  Event Handlers

#Region  Public Subroutines

#if B4i
'TODO This is duplicated code!
' This method moves a text entry field so it does not get covered by the keyboard.
' B4XFloatTextField is taken from here: https://www.b4x.com/android/forum/threads/b4xfloattextfield-keyboard-hiding-views.118242/#post-740784
Public Sub MoveUpEnterDetailsPanel(height As Float)
	If height = 0 Then ' Keyboard has been hidden
		pnlEnterDetails.top = pnlEnterDetailsOrgTop
	Else ' Keyboard has been shown
		pnlEnterDetails.top = pnlEnterDetailsOrgTop
		Sleep(0)
		For Each v As B4XView In pnlEnterDetails.GetAllViewsRecursive
			If v.Tag Is B4XFloatTextField Then
				Dim f As B4XFloatTextField = v.Tag
				If f.Focused Then
					Dim base As Panel = f.mBase
					Dim d As Double = base.CalcRelativeKeyboardHeight(height)
					If d < base.Height Then
						pnlEnterDetails.Top = pnlEnterDetailsOrgTop -(base.Height - d)
					End If
				End If
			End If
		Next
	End If
End Sub
#End If


' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then
		ProgressHide		' Just in-case.
	End If
	txtEmailAddress.Text = ""
	txtVerifyPassword.Text = ""
	txtPassword.Text = ""
	txtVerifyPassword.text = ""
	HandlePrivacyPolicy(False)
End Sub

#if B4i
' Handle resize event
Public Sub Resize
	gWidth = GetPanelWidth
	gPnl_Hide.RemoveAllViews
	gPnl_Hide.AddView ( gIm_Hide, gWidth-55,0,50,40)
End Sub
#End If


#End Region  Public Subroutines

#Region  Local Subroutines

#If B4I
'TODO Duplicated code.
' Add hide keyboard button.
Private Sub AddViewToKeyboard (xx As Object, view As Object)
	Dim no As NativeObject = xx
	no.SetField("inputAccessoryView", view)
End Sub
#End If

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
private Sub CreateNewAccount As ResumableSub
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
														" we have sent an activation email to your email address." & CRLF & _
														"At :" & emailAddress & CRLF & CRLF & _
														"Please click the activation link in the email to activation your account." & CRLF & _
														"(IF NOT FOUND, CHECK YOUR JUNK FOLDER)"
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

#if B4i
' Get the screen width 
Private Sub GetPanelWidth As Int
	Return  pnlEnterDetails.Width
End Sub
#End If

' Will show or hide privacy policy
Private Sub HandlePrivacyPolicy(show As Boolean)
	web.LoadUrl(modEposWeb.URL_PRIVACY_POLICY)
	pnlWeb.Visible = show
	web.Visible = show
End Sub

#if B4i
' Hide the keyboard.
Private Sub HideKeyboard
	frmCreateAccount.HideKeyboard
End Sub
#End If

' Initialize the locals etc.
private Sub InitializeLocals
	ControlUserInteraction(True)
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
	txtName.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
	txtEmailAddress.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
	txtPassword.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
	txtVerifyPassword.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 5dip)
#if B4I
	' B4I code for close keyboard button.
		pnlEnterDetailsOrgTop = pnlEnterDetails.Top ' Save the original enter panel top postion.
	gIm_Hide.Initialize("Im_Hide")
	gIm_Hide.Bitmap = LoadBitmap(File.DirAssets, "hide_keyboard.png")
	gIm_Hide.Color = xui.Color_Gray
	gIm_Hide.Height = 50
	gIm_Hide.Width = 40
	gWidth = GetPanelWidth
	gPnl_Hide.Initialize ("")
	gPnl_Hide.Color = Colors.Transparent
	gPnl_Hide.AddView ( gIm_Hide, gWidth-55,0,50,40)	
	gPnl_Hide.Height = 40
	
	AddViewToKeyboard(txtName.TextField, gPnl_Hide)
	AddViewToKeyboard(txtEmailAddress.TextField, gPnl_Hide)
	AddViewToKeyboard(txtPassword.TextField, gPnl_Hide)
	AddViewToKeyboard(txtVerifyPassword.TextField, gPnl_Hide)

#End If
	Private cs As CSBuilder
	cs.Initialize.Underline.Color(Colors.White).Append("View Privacy Policy").PopAll
'	lblPrivacyPolicy.Text = cs
	' See https://www.b4x.com/android/forum/threads/b4x-set-csbuilder-or-text-to-a-label.102118/
	XUIViewsUtils.SetTextOrCSBuilderToLabel(lblPrivacyPolicy, cs)
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

