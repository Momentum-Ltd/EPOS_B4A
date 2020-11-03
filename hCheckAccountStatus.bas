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
	' Release...: 18
	' Date......: 02/08/20
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 1/8/19)
	' Details...: First release to support version tracking
	'
	' Version 2 - 8 see v9.
	'			
	' Date......: 26/04/20
	' Release...: 9
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris.
	' Details...:  Mod: pCheckAccountStatus(), CheckWebAccount(), ResendActivationEmail().
	'
	' Date......: 09/02/20
	' Release...: 10
	' Overview..: Bugfix: 0398 - Timeout sometimes tripping at startup.
	' Amendee...: D Morris.
	' Details...:  Mod: DFT_MIN_DISPLAY_TIME reduced to 1sec.
	'
	' Date......: 11/05/20
	' Release...: 11
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mod: OnClose().
		'
	' Date......: 03/06/20
	' Release...: 12
	' Overview..: Issue #0175 - work improving signon.
	' Amendee...: D Morris.
	' Details...: Removed: ShowConnectPage().  
	'			      Mod: ReportInternetProblem() and ReportNoInternet() old Wifi connection code removed.
	'
	' Date......: 11/06/20
	' Release...: 13
	' Overview..: Improved checks on Server and internet.
	' Amendee...: D Morris
	' Details...:  Mod: CheckWebAccount(), IsOnLine(), ResendActivationEmail().
	'
	' Date......: 18/06/20
	' Release...: 14
	' Overview..: Add #0395: Select Centre with Logos (Experimental).
	' Amendee...: D Morris.
	' Details...: Mod: ShowSelectPlayCentre() compiler option to select type of centre list. 
	'
	' Date......: 28/06/20
	' Release...: 15
	' Overview..: Experiments why iOS has problems with no internet.
	' Amendee...: D Morris 
	' Details...:   Mod: IsOnLine() - timeout moved after the download().
	'								  timeout increased to 5 seconds.
	'
	' Date......: 09/07/20
	' Release...: 16
	' Overview..: Mod: Activate account - check junk folder added.
	' Amendee...: D Morris.
	' Details...: Mod: NonActivatedAccount() and ResendActivationEmail().
	'
	' Date......: 22/07/20
	' Release...: 17
	' Overview..: New UI startup.
	' Amendee...: D Morris
	' Details...: Mod: Now support a loading indicate (using clsProgressIndicator) - general changes.
	'
	' Date......: 02/08/20
	' Release...: 18
	' Overview..: Support for new UI - Select Centre.
	' Amendee...: D Morris
	' Details...:  Mod: ShowSelectPlayCentre().
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
	Private const DFT_ONLINE_TIMEOUT As Int	= 20000		' Timeout on check for server on-line (and internet) - in msecs.
	
	' Timers
	Private tmrMinimumDisplayPeriod As Timer			' Controls the minimum time this activity is displayed.
	
	' Flags
	Private exitToSelectCentre As Boolean				' Indicates exit to Select Centre activity.
	Private exitToNewInstall As Boolean					' Indicates exit to New install activity
	Private exitToNonActivatedAccount As Boolean		' Indicates exit to non activated account operation
	Private mainSubRunning As Boolean 					' Indicates the main sub is running (to overcome StartActivity() operation).
	Private minDisplayElapsed As Boolean				' When set indicates the minimum display period has elapased.
		
	' Misc objects
	Private progressbox As clsProgressIndicator			' Progress Indicator
	
	' View declarations
	Private btnRetry As B4XView							'ignore This must retained otherwise parent.LoadLayout("frmCheckAccountStatus") has problems.
	Private indLoading As B4XLoadingIndicator			' In progress indicator

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Progress dialog has timed out
Sub progressbox_Timeout()
	xui.MsgboxAsync("No response", "Checking Account")
	Wait for msgbox_result (result As Int)
	RestartThisActivity
End Sub

' Timer to handle the minimum time this page shou be displayed 
'  before another operation can take place.
Sub tmrMinimumDisplayPeriod_tick
	minDisplayElapsed = True
	tmrMinimumDisplayPeriod.Enabled = False
	If exitToSelectCentre Then
		ProgressHide
		ShowSelectPlayCentre
	else if exitToNewInstall Then
		ProgressHide
		ShowQueryNewInstallPage
	else if exitToNonActivatedAccount Then
		ProgressHide
		NonActivatedAccount
	End If
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmCheckAccountStatus")
	InitializeLocals
End Sub

' Main method

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then
		ProgressHide		' Just in-case.		
	End If
	tmrMinimumDisplayPeriod.Enabled = False
	mainSubRunning = False
End Sub

' Perfores the Check account operation.
Public Sub pCheckAccountStatus
	If mainSubRunning = False Then
		mainSubRunning = True			' Shows sign-on screen 
		ProgressShow				
		Wait For (IsOnLine) complete(internetStatus As Int) 
		Select Case internetStatus
			Case 1:
				If Starter.CustomerInfoAvailable Then	' Customer information available?
					wait for (CheckWebAccount(Starter.myData.customer.apiCustomerId)) complete (accountOk As Boolean)
				Else
					DelayedQueryNewInstall
				End If
			Case 0:
				ReportServerProblem
			Case Else
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
	Dim apiHelper As clsEposApiHelper
	apiHelper.Initialize
	Wait For (apiHelper.QueryUpdateFCMandType(apiCustomerId, fcmToken, device.GetDeviceType)) complete (updateOk As Boolean)
	If updateOk Then
		updateDeviceOk = True
	End If
	Return updateDeviceOk
End Sub

' Checks the web server for information on this customer 
private Sub CheckWebAccount(apiCustomerId As Int) As ResumableSub
	Dim accountOk As Boolean = False
	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
	Dim urlStr As String = Starter.server.URL_CUSTOMER_API & "/" & modEposWeb.ConvertApiId(apiCustomerId) & _
					"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_QUERY_ACTIVATED ' "?search=activated")
	job.Download(urlStr)		
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then 'Account valid?
		Dim rxActivated As String = job.GetString
		If rxActivated = "1" Then ' Activated?
			CheckFcmAndDeviceType(apiCustomerId) ' Update the FCM and/of device type (they could change) 
			accountOk = True
			DelayedSelectPlayCentre
		Else ' Customer has NOT activated their account
			DelayedNonActivatedAccount
		End If
	Else if job.Success And job.Response.StatusCode = 204 Then ' Customer not found (or invalid customer number)
		DelayedQueryNewInstall	
	Else ' Something went wrong with the HTTP job
		ReportInternetProblem
	End If
	job.Release
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
		ShowQueryNewInstallPage
	Else
		exitToNewInstall = True	' Wait for timer to elapse.
	End If
End Sub

' Ensures SelectPlayCentre is not display before DFT_MIN_DISPLAY_TIME has elapsed. 
private Sub DelayedSelectPlayCentre
	If minDisplayElapsed Then
		ShowSelectPlayCentre
	Else
		exitToSelectCentre = True	' Wait for timer to elapse.
	End If
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
	tmrMinimumDisplayPeriod.Initialize("tmrMinimumDisplayPeriod", DFT_MIN_DISPLAY_TIME)
	tmrMinimumDisplayPeriod.Enabled = False	' Just in-case the timer is already running.
	tmrMinimumDisplayPeriod.Enabled = True
	mainSubRunning = False
	minDisplayElapsed = False
	exitToNewInstall = False
	exitToSelectCentre = False
	exitToNonActivatedAccount = False
End Sub

' Check if internet available.
Private Sub IsInternetOk() As ResumableSub
	Dim internetOk As Boolean = False
	Dim j As HttpJob
	j.Initialize("checkInternet", Me)
	j.Download( "https://www.google.com") ' Hopefully google is always running.
	j.GetRequest.Timeout = 5000 ' 5 second timeout (timout is set before the downloads starts)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		internetOk = True
	End If
	j.Release		' Important.
	Return internetOk
End Sub

' Checks Server is on-line (and internet connected).
' Returns 1 if Server online
' Returns 0 if not on-line (Internet is ok)
' Returns -1 if No internet
private Sub IsOnLine As ResumableSub
	Dim internetStatus As Int   = -1 ' Default to both Server and Internet down.
	wait for (IsInternetOk) complete (ok As Boolean)
	If ok Then
		Dim job As HttpJob : job.Initialize("UseWebApi", Me)
		job.Download(Starter.server.URL_CENTRE_API)
		job.GetRequest.Timeout = DFT_ONLINE_TIMEOUT' (timout is set before the downloads starts)
		Wait For (job) JobDone(job As HttpJob)
		If job.Success And job.Response.StatusCode = 200 Then
			internetStatus = 1 ' Server online.
		Else ' Problem check if internet
			Wait For (IsInternetOk) complete (internetOk As Boolean)
			If internetOk Then
				internetStatus = 0	' Internet ok (no Server)			
			End If
		End If
		job.release
	End If
	Return internetStatus
End Sub

' Handles the situation when user account is not activated.
private Sub NonActivatedAccount
	xui.Msgbox2Async("You have not clicked the link in the activation email we sent to you " & _
							" (if not found check your Junk folder)." & CRLF & _
	 						"Please do so and then press 'Retry' or 'New account' to create a new account." _
							, "Email Not Activated", "Resend email", "Retry","New account" , Null)
	Wait for msgbox_result (result As Int)
	If result = xui.DialogResponse_Positive Then	' Resend activation email
		wait for (ResendActivationEmail(Starter.myData.customer.customerIdStr)) complete (successful As Boolean)
		RestartThisActivity
	Else if result = xui.DialogResponse_Negative Then
		ShowQueryNewInstallPage
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
	Dim successful As Boolean = False
	ProgressShow
	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
	Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False) & _
								 "?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_MUST_ACTIVATE
	job.PutString(urlStrg, "")
	Wait For (job) JobDone(job As HttpJob)
	ProgressHide	
	If job.Success And job.Response.StatusCode = 200 Then
		xui.MsgboxAsync("Has been sent to your email address!" & CRLF & "(If not found check your Junk Folder)" , "Activation email")
		Wait For msgbox_result(tempResult As Int) 
		successful = True
	Else
		xui.MsgboxAsync("Error has occurred, unable to send a activation email!", "Email problem")
		Wait For msgbox_result(tempResult As Int)
	End If
	job.Release
	Return successful
End Sub

' Restarts this acvtivity.
' See https://www.b4x.com/android/forum/threads/programmatically-restarting-an-app.27544/
Private Sub RestartThisActivity
#if B4A
	OnClose
	CallSubDelayed(CheckAccountStatus,"RecreateActivity")
#else ' B4I
	pCheckAccountStatus
#End If

End Sub

' Shows QueryNewInstall page.
private Sub ShowQueryNewInstallPage
#if B4A
	OnClose
	StartActivity(QueryNewInstall)
#else
	frmQueryNewInstall.Show
#end if
End Sub

' Show SelectPlayCentre page.
private Sub ShowSelectPlayCentre
#if B4A
	OnClose
'	StartActivity(aSelectPlayCentre2)
	StartActivity(aSelectPlayCentre3)
#else ' B4i
'	frmXSelectPlayCentre2.Show
	frmXSelectPlayCentre3.Show
#End If
End Sub


#End Region  Local Subroutines