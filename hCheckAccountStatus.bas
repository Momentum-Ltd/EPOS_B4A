B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' This is a help class for CheckAccountStatus
'

#Region  Documentation
	'
	' Name......: hCheckAccountStatus
	' Release...: 24
	' Date......: 30/01/21
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 1/8/19)
	' Details...: First release to support version tracking
	'
	' Version 2 - 8 see v9.
	'         9 - 18 see v18
	'
	' Date......: 20/11/20
	' Release...: 19
	' Overview..: Issue: #0559 Improve Account not activated report.
	' Amendee...: D Morris.
	' Details...: Mod: NonActivatedAccount() The "not activated" account report reworded. 
	'		
	' Date......: 15/12/20
	' Release...: 20
	' Overview..: Bugfix: Check account not timing correctly when restarted. 
	'             Issue: #0482 Auto retry on non-activated account.
	' Amendee...: D Morris
	' Details...: Mod: ExitToSelectPlayCentre(), ExitToQueryNewInstall(), RestartThisActivity() - B4i code also calls OnClose().
	'			  Mod: OnClose() resets minDisplayElapsed flag.
	'			  Mod: pCheckAccountStatus() - starts tmrMinimumDisplayPeriod.
	'			  Mod: p and l usage is dropped.
	'			  Mod: pCheckAccountStatus() renamed to StartCheckAccountStatus().
	'			  Mod: Call To pCheckAccountStatus() changed To StartCheckAccount().
	'			  Mod: IsInternetAvailable() and IsWebServerOnLine() moved to clsEposApiHelp.
	'			  Mod: StartCheckAccount() and ResendActivationEmail() now uses clsEposApiHelp.
	'			  Mod: ResendActivationEmail(),  Email address now included in activation messages.  
	'
	' Date......: 03/01/21
	' Release...: 21	
	' Overview..: Issue: #0482 - Still problems for iOS.
	' Amendee...: D Morris
	' Details...: Mod: tmrRetryActivatedAccount_Tick() iOS code fixed.
	'			  Mod: Now uses B4XDialog.
	'		
	' Date......: 23/01/21
	' Release...: 22
	' Overview..: Maintenance release - Update to latest standards for CheckAccountStatus and associated modules. 
	' Amendee...: D Morris
	' Details...: Mod: RestartThisActivity() calls to CheckAccountStatus changed to aCheckAccountStatus.
	'			  Mod: tmrRetryActivatedAccount_Tick() - toast message shortened.
	'
	' Date......: 28/01/21
	' Release...: 23
	' Overview..: Maintenance release - QueryNewInstall updated.
	' Amendee...: D Morris
	' Details...: Mod: ExitToQueryNewInstall().
	'
	' Date......: 30/01/21
	' Release...: 24
	' Overview..: Support for rename frmXSelectPlayCentre3 to xSelectPlayCentre3.
	' Amendee...: D Morris
	' Details...:  Mod: ExitToSelectPlayCentre().
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
	Private xui As XUI		'Ignore
	
	' Constants
	Private const DFT_MIN_DISPLAY_TIME As Int = 5000 	' Minimum time the Sign is displayed for (in msecs).
	Private const DFT_RETRY_ACCOUNT As Int = 5000		' Period auto retry if customer's account is activated.
	
	' Timers
	Private tmrMinimumDisplayPeriod As Timer			' Controls the minimum time this activity is displayed.
	Private tmrRetryActivatedAccount As Timer			' Retry timer to check server if customer has activated.
	
	' Flags
	Private exitToSelectCentre As Boolean				' Indicates exit to Select Centre activity.
	Private exitToNewInstall As Boolean					' Indicates exit to New install activity
	Private exitToNonActivatedAccount As Boolean		' Indicates exit to non activated account operation
	Private mainSubRunning As Boolean 					' Indicates the main sub is running (to overcome StartActivity() operation).
	Private minDisplayElapsed As Boolean				' When set indicates the minimum display period has elapased.
	
	' Variables
	Private emailAddress As String						' Local storage for Customer's email address.
			
	' Misc objects
	Private dialog As B4XDialog							' Dialog message.
	Private LongTextTemplate As B4XLongTextTemplate		' Template required to show all the text (otherwise it is truncated).
	Private parentActivity As B4XView					' Storage for parent.
	Private progressbox As clsProgressIndicator			' Progress Indicator.
	
	' View declarations
	Private btnRetry As B4XView							'ignore This must retained otherwise parent.LoadLayout("frmCheckAccountStatus") has problems.
	Private indLoading As B4XLoadingIndicator			' In-progress indicator.

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Progress dialog has timed out
Private Sub progressbox_Timeout()
	xui.MsgboxAsync("No response", "Checking Account")
	Wait for msgbox_result (result As Int)
	RestartThisActivity
End Sub

' Timer to handle the minimum time this page should be displayed 
'  before another operation can take place.
Private Sub tmrMinimumDisplayPeriod_tick
	minDisplayElapsed = True
	tmrMinimumDisplayPeriod.Enabled = False
	If exitToSelectCentre Then
		ProgressHide
		ExitToSelectPlayCentre
	else if exitToNewInstall Then
		ProgressHide
		ExitToQueryNewInstall
	else if exitToNonActivatedAccount Then
		ProgressHide
		NonActivatedAccount
	End If
End Sub

' Auto retry account activated timer.
Private Sub tmrRetryActivatedAccount_Tick
	tmrRetryActivatedAccount.Enabled = False
	Dim apiHelper As clsEposApiHelper : apiHelper.Initialize
	wait for (apiHelper.CheckCustomerActivated(Starter.myData.customer.apiCustomerId)) complete(customerStatus As Int)
	If customerStatus = 1 Then ' Customer's account now activated?
#if B4A
		ToastMessageShow("Account now activated!", True)
#else ' B4i
		Main.ToastMessageShow("Account now activated!", True)
#End If
		dialog.Close(xui.DialogResponse_Cancel)  ' Important - need to close it.
	Else ' Not activated = restart the timer.
		tmrRetryActivatedAccount.Enabled = True
	End If
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmCheckAccountStatus")
	parentActivity = parent
	InitializeLocals
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then
		ProgressHide		' Just in-case.		
	End If
	tmrMinimumDisplayPeriod.Enabled = False
	tmrRetryActivatedAccount.Enabled = False
	mainSubRunning = False
	minDisplayElapsed = False
	emailAddress = ""
	' See code snippets in https://www.b4x.com/android/forum/threads/b4x-xui-views-cross-platform-views-and-dialogs.100836/#content
	dialog.Close(xui.DialogResponse_Cancel)  ' Important - need to close it.
End Sub

' Starts check account operation.
Public Sub StartCheckAccount
	If mainSubRunning = False Then
		mainSubRunning = True					' Shows sign-on screen 
		tmrMinimumDisplayPeriod.Enabled = True 	' Start the minimum display timer.
		exitToNewInstall = False				' Initialize the flags
		exitToSelectCentre = False
		exitToNonActivatedAccount = False
		tmrRetryActivatedAccount.Enabled = False
		ProgressShow			
		Dim apiHelper As clsEposApiHelper : apiHelper.Initialize
		Wait For (apiHelper.CheckWebServerStatus) complete(internetStatus As Int)
		Select Case internetStatus
			Case 1: ' Server is on-line
				If Starter.CustomerInfoAvailable Then	' Customer information available?
					wait for (CheckWebAccount(Starter.myData.customer.apiCustomerId)) complete (accountOk As Boolean)
				Else
					DelayedQueryNewInstall
				End If
			Case 0: ' Unable to contact Server (However the Internet is working).
				ReportServerProblem
			Case Else ' Any other problem.
				ReportNoInternet
		End Select
		mainSubRunning = False
	End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Check the FCM token and device type (update web server if not the same).
'  Return true if update was successful or values were already the same.
private Sub CheckFcmAndDeviceType(apiCustomerId As Int) As ResumableSub
	Dim updateDeviceOk As Boolean
#if B4A
	Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")	' TODO Does this need to be resummable?
#else ' B4I
	wait for (Main.GetFirebaseToken()) complete (fcmToken As String)
#end if
	Dim device As clsDeviceInfo : device.initialize
	Dim apiHelper As clsEposApiHelper : apiHelper.Initialize
	Wait For (apiHelper.QueryUpdateFCMandType(apiCustomerId, fcmToken, device.GetDeviceType)) complete (updateOk As Boolean)
	If updateOk Then
		updateDeviceOk = True
	End If
	Return updateDeviceOk
End Sub

' Checks the web server for information on this customer 
private Sub CheckWebAccount(apiCustomerId As Int) As ResumableSub
	Dim accountOk As Boolean = False
	Dim apiHelper As clsEposApiHelper : apiHelper.Initialize
	Wait for (apiHelper.CheckCustomerActivated(apiCustomerId)) complete (result As Int)
	Wait for (apiHelper.GetCustomerEmail(apiCustomerId)) complete (email As String)
	emailAddress = email
	Select result
		Case 1: ' Customer found and activated.
			wait for (CheckFcmAndDeviceType(apiCustomerId)) complete (updateOk As Boolean) ' Update the FCM and/of device type (they could change)
			accountOk = True
			DelayedSelectPlayCentre
		Case 0: ' Customer found but NOT activated.
			DelayedNonActivatedAccount
		Case -1: ' Customer not found.
			DelayedQueryNewInstall
		Case Else ' Something else wrong
			ReportInternetProblem
	End Select
	Return accountOk
End Sub

' Ensures this non-activited account is not started before DFT_MIN_DISPLAY_TIME has elapsed.
private Sub DelayedNonActivatedAccount
	If minDisplayElapsed Then
		NonActivatedAccount
	Else
		exitToNonActivatedAccount = True
	End If
End Sub

' Ensures QueryNewInstall is not display before DFT_MIN_DISPLAY_TIME has elapsed.
private Sub DelayedQueryNewInstall
	If minDisplayElapsed Then		
		ExitToQueryNewInstall
	Else
		exitToNewInstall = True	' Wait for timer to elapse.
	End If
End Sub

' Ensures SelectPlayCentre is not display before DFT_MIN_DISPLAY_TIME has elapsed. 
private Sub DelayedSelectPlayCentre
	If minDisplayElapsed Then
		ExitToSelectPlayCentre
	Else
		exitToSelectCentre = True	' Wait for timer to elapse.
	End If
End Sub

' Exit to Query New Installation page.
private Sub ExitToQueryNewInstall
#if B4A
	StartActivity(aQueryNewInstall)
#else
	xQueryNewInstall.Show
#end if
End Sub

' Exit to Select Play Centre page.
private Sub ExitToSelectPlayCentre
#if B4A
	StartActivity(aSelectPlayCentre3)
#else ' B4i
	xSelectPlayCentre3.Show
#End If
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	dialog.Initialize(parentActivity)
	LongTextTemplate.Initialize
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
	tmrMinimumDisplayPeriod.Initialize("tmrMinimumDisplayPeriod", DFT_MIN_DISPLAY_TIME)
	tmrMinimumDisplayPeriod.Enabled = False	' Just in-case the timer is already running.
	tmrRetryActivatedAccount.Initialize("tmrRetryActivatedAccount", DFT_RETRY_ACCOUNT)
	mainSubRunning = False
	minDisplayElapsed = False
	exitToNewInstall = False
	exitToSelectCentre = False
	exitToNonActivatedAccount = False
End Sub

' Handles the situation when user account is not activated.
private Sub NonActivatedAccount()
	tmrRetryActivatedAccount.Enabled = True	' Start the auto retry timer.
	dialog.Title = "Account Not Activated"
	Dim dialogString As String = "You have not clicked the link in the activation email we sent" & CRLF & _
							"To: " & emailAddress & CRLF & CRLF & _
							" (if not found CHECK YOUR JUNK FOLDER)." & CRLF & CRLF &  _
	 						"Please click on the link and press 'Retry'." & CRLF & "If the email address Is incorrect press 'New'."
	LongTextTemplate.Text = dialogString ' Using long text template is necessary to prevent the text truncating.
	Wait For (dialog.ShowTemplate(LongTextTemplate, "Resend", "New", "Retry")) Complete (result As Int)
	' See code snippets in https://www.b4x.com/android/forum/threads/b4x-xui-views-cross-platform-views-and-dialogs.100836/#content
	dialog.Close(xui.DialogResponse_Cancel)  ' Important - need to close it.
	If result = xui.DialogResponse_Positive Then	' Resend activation email
		wait for (ResendActivationEmail(Starter.myData.customer.customerIdStr)) complete (successful As Boolean)
		RestartThisActivity
	Else if result = xui.DialogResponse_Negative Then ' New account
		ExitToQueryNewInstall
	Else ' Default restart the checks (Retry)
		RestartThisActivity
	End If
End Sub

'Hide the Progress box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Show The progress box.
'Private Sub ProgressShow(message As String)
Private Sub ProgressShow
	progressbox.Show
End Sub

' Reports a problem with internet operation and handles the response
private Sub ReportInternetProblem
	ProgressHide
	xui.Msgbox2Async("What do you want to do?." _
		, "Issue with the Internet!", "Retry (recommended)", "" ,"Continue without internet",  Null)
	Wait for msgbox_result (result As Int)
	If result = xui.DialogResponse_Positive Then	' Retry check for internet?
		RestartThisActivity			' Retry to communicate via the internet
	Else if result = xui.DialogResponse_Negative Then	' Continue without internet
		xui.MsgboxAsync("App not allowed to run without the internet.", "Issue with the Internet!")
		wait for msgbox_result (result As Int)
		RestartThisActivity			' Retry to communicate via the internet
	End If
End Sub

' Reports and handles no internet and handles the response
private Sub ReportNoInternet
	ProgressHide	
	xui.Msgbox2Async("What do you want to do?." _
		, "No Internet connection found!", "Retry", "" ,"Continue without internet",  Null)
	Wait for msgbox_result (result As Int)
	If result = xui.DialogResponse_Positive Then	' Retry check for internet?
		RestartThisActivity
	Else if result = xui.DialogResponse_Negative Then	' Continue without internet
		xui.MsgboxAsync("App not allowed to run without the internet.", "Issue with the Internet!")
		wait for msgbox_result (result As Int)
		RestartThisActivity			' Retry to communicate via the internet
	End If
End Sub

' Reports Server problem
Private Sub ReportServerProblem
	ProgressHide
	xui.Msgbox2Async("What do you want to do?." _
		, "No response from Web Server", "Retry", "" ,"Switch Server",  Null)
	Wait for msgbox_result (result As Int)
	If result = xui.DialogResponse_Positive Then	' Retry check for internet?
		RestartThisActivity
	Else if result = xui.DialogResponse_Negative Then	' Switch Server?
		Starter.server.ToggleServer
		RestartThisActivity			' Retry to communicate via the internet
	End If
End Sub

' Resends activation email
Private Sub ResendActivationEmail(apiCustomerId As Int)As ResumableSub
	Dim successful As Boolean = False
	ProgressShow
	Dim apiHelper As clsEposApiHelper : apiHelper.Initialize
	wait for (apiHelper.CustomerMustActivate(apiCustomerId)) complete(emailSent As Boolean)
	ProgressHide
	If emailSent Then ' Email sent ok?
		xui.MsgboxAsync("Has been sent to your email address!" & CRLF & _ 
							emailAddress & CRLF & CRLF & "(if not found CHECK YOUR JUNK FOLDER)" , "Activation email")
		Wait For msgbox_result(tempResult As Int)
		successful = True
	Else
		xui.MsgboxAsync("Error has occurred, unable to send a activation email!" & CRLF & _
							"To: " & emailAddress, "Email problem")
		Wait For msgbox_result(tempResult As Int)
	End If
	Return successful
End Sub

' Restarts this acvtivity.
' See https://www.b4x.com/android/forum/threads/programmatically-restarting-an-app.27544/
Private Sub RestartThisActivity
	OnClose
#if B4A
	CallSubDelayed(aCheckAccountStatus,"RecreateActivity")
#else ' B4I
	StartCheckAccount
#End If
End Sub


#End Region  Local Subroutines