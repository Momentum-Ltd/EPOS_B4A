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
	' Release...: 20
	' Date......: 15/12/20
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

' Timer to handle the minimum time this page shou be displayed 
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
		ToastMessageShow("Auto retry has detect your account is now activated!", True)
#else ' B4i
		Main.ToastMessageShow("Auto retry has detect your account is now activated!", True)
#End If

#if b4A
		ExitToSelectPlayCentre
#else ' B4i
'		RestartThisActivity ' Necessary otherwise msgbox is not removed!
'		frmCheckAccountStatus.Show(False)
		CallSubDelayed2(Me, "msgbox_result",  xui.DialogResponse_Positive)
#End If

	Else ' Not activated = restart the timer.
		tmrRetryActivatedAccount.Enabled = True
	End If
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmCheckAccountStatus")
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
'	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
'	Dim urlStr As String = Starter.server.URL_CUSTOMER_API & "/" & modEposWeb.ConvertApiId(apiCustomerId) & _
'					"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_QUERY_ACTIVATED ' "?search=activated")
'	job.Download(urlStr)		
'	Wait For (job) JobDone(job As HttpJob)
	Dim apiHelper As clsEposApiHelper : apiHelper.Initialize
	Wait for (apiHelper.CheckCustomerActivated(apiCustomerId)) complete (result As Int)
	Wait for (apiHelper.GetCustomerEmail(apiCustomerId)) complete (email As String)
	emailAddress = email
'	If job.Success And job.Response.StatusCode = 200 Then 'Account valid?
'		Dim rxActivated As String = job.GetString
'		If rxActivated = "1" Then ' Activated?
'			CheckFcmAndDeviceType(apiCustomerId) ' Update the FCM and/of device type (they could change) 
'			accountOk = True
'			DelayedSelectPlayCentre
'		Else ' Customer has NOT activated their account
'			DelayedNonActivatedAccount
'		End If
'	Else if job.Success And job.Response.StatusCode = 204 Then ' Customer not found (or invalid customer number)
'		DelayedQueryNewInstall	
'	Else ' Something went wrong with the HTTP job
'		ReportInternetProblem
'	End If
'	job.Release
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

' Initialize the locals etc.
private Sub InitializeLocals
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

'' Check If internet available.
'Private Sub IsInternetAvailable() As ResumableSub
'	Dim internetOk As Boolean = False
'	Dim j As HttpJob
'	j.Initialize("checkInternet", Me)
'	j.Download( "https://www.google.com") ' Hopefully google is always running.
'	j.GetRequest.Timeout = 5000 ' 5 second timeout (timout is set before the downloads starts)
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success Then
'		internetOk = True
'	End If
'	j.Release		' Important.
'	Return internetOk
'End Sub

'' Checks Server is on-line (and internet connected).
'' Returns 1 if Server online
'' Returns 0 if not on-line (Internet is ok)
'' Returns -1 if No internet
'private Sub IsWebServerOnLine As ResumableSub
'	Dim internetStatus As Int   = -1 ' Default to both Server and Internet down.
'	wait for (IsInternetAvailable) complete (ok As Boolean)
'	If ok Then
'		Dim job As HttpJob : job.Initialize("UseWebApi", Me)
'		job.Download(Starter.server.URL_CENTRE_API)
'		job.GetRequest.Timeout = DFT_ONLINE_TIMEOUT' (timout is set before the downloads starts)
'		Wait For (job) JobDone(job As HttpJob)
'		If job.Success And job.Response.StatusCode = 200 Then
'			internetStatus = 1 ' Server online.
'		Else ' Problem check if internet
'			Wait For (IsInternetAvailable) complete (internetOk As Boolean)
'			If internetOk Then
'				internetStatus = 0	' Internet ok (no Server)			
'			End If
'		End If
'		job.release
'	End If
'	Return internetStatus
'End Sub

' Handles the situation when user account is not activated.
private Sub NonActivatedAccount()
	tmrRetryActivatedAccount.Enabled = True	' Start the auto retry timer.
	xui.Msgbox2Async("You have not clicked the link in the activation email we sent" & CRLF & _
							"To: " & emailAddress & CRLF & CRLF & _
							" (if not found CHECK YOUR JUNK FOLDER)." & CRLF & CRLF &  _
	 						"Please do so and then press 'Retry', if the email address is incorrect press 'New account'." _
							, "Account Not Activated", "Resend email", "Retry","New account" , Null)
	Wait for  msgbox_result (result As Int)
	If result = xui.DialogResponse_Positive Then	' Resend activation email
		wait for (ResendActivationEmail(Starter.myData.customer.customerIdStr)) complete (successful As Boolean)
		RestartThisActivity
	Else if result = xui.DialogResponse_Negative Then
		ExitToQueryNewInstall
	Else ' Default restart the checks.
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
	Else if result = xui.DialogResponse_Negative Then	' Continue without internet
		Starter.server.ToggleServer
		RestartThisActivity			' Retry to communicate via the internet
	End If
End Sub

' Resends activation email
Private Sub ResendActivationEmail(apiCustomerId As Int)As ResumableSub
'	Dim successful As Boolean = False
'	ProgressShow
'	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
'	Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False) & _
'								 "?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_MUST_ACTIVATE
'	job.PutString(urlStrg, "")
'	Wait For (job) JobDone(job As HttpJob)
'	ProgressHide	
'	If job.Success And job.Response.StatusCode = 200 Then
'		xui.MsgboxAsync("Has been sent to your email address!" & CRLF & "(If not found check your Junk Folder)" , "Activation email")
'		Wait For msgbox_result(tempResult As Int) 
'		successful = True
'	Else
'		xui.MsgboxAsync("Error has occurred, unable to send a activation email!", "Email problem")
'		Wait For msgbox_result(tempResult As Int)
'	End If
'	job.Release
'	Return successful
	Dim successful As Boolean = False
	ProgressShow
'	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
'	Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False) & _
'	"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_MUST_ACTIVATE
'	job.PutString(urlStrg, "")
'	Wait For (job) JobDone(job As HttpJob)
	Dim apiHelper As clsEposApiHelper : apiHelper.Initialize
	wait for (apiHelper.CustomerMustActivate(apiCustomerId)) complete(emailSent As Boolean)
	ProgressHide
'	If job.Success And job.Response.StatusCode = 200 Then
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
'	job.Release
	Return successful
End Sub

' Restarts this acvtivity.
' See https://www.b4x.com/android/forum/threads/programmatically-restarting-an-app.27544/
Private Sub RestartThisActivity
	OnClose
#if B4A
	CallSubDelayed(CheckAccountStatus,"RecreateActivity")
#else ' B4I
	StartCheckAccount
#End If

End Sub

' Exit Query New Installation page.
private Sub ExitToQueryNewInstall
#if B4A
	StartActivity(QueryNewInstall)
#else
	frmQueryNewInstall.Show
#end if
End Sub

' Exit to Select Play Centre page.
private Sub ExitToSelectPlayCentre
#if B4A
	StartActivity(aSelectPlayCentre3)
#else ' B4i
	frmXSelectPlayCentre3.Show
#End If
End Sub


#End Region  Local Subroutines