B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a helper class for Task Select Activity
'
#Region  Documentation
	'
	' Name......: hTaskSelect
	' Release...: 28
	' Date......: 02/08/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on TaskSelect_v34.
	' 
	' History 2 - 9 	See v_10. 
	'	      10 - 17	See v_18.	
	'
	' Date......: 03/05/20
	' Release...: 18
	' Overview..: Bugfix: #0394 - Not displaying Payment options correctly.
	' Amendee...: D Morris
	' Details...: Mod: HandleOrderAcknResponse() code to replace "Cancel" with "Cash".
	'	
	' Date......: 05/05/20
	' Release...: 19
	' Overview..: Bugfix: #0392 No progress dialog when new card information entered.
	' Amendee...: D Morris
	' Details...:   Mod: HandleOrderAcknResponse() code changed to call CardEntry to input card and
	'						code to query payment options moved to another sub.
	'			  Added: Public QueryPayment().
	'
	' Date......: 05/05/20
	' Release...: 20
	' Overview..: Code fix to run on iOS.
	' Amendee...: D Morris.
	' Details...:  Mod: QueryPayment() code changed to support b4i.
	'
	' Date......: 09/05/20
	' Release...: 21
	' Overview..: Bugfix: 0401 - No progress dialog order between order ackn message and displaying payment options. 
	' Amendee...: D Morris.
	' Details...:  Mod: HandleOrderAcknResponse() and QueryPayment() moved to hPlaceOrder.
	'
	' Date......: 11/05/20
	' Release...: 22
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Added: OnClose().
		'
	' Date......: 16/05/20
	' Release...: 23
	' Overview..: Mod: Task Select now settings option is in title bar.
	' Amendee...: D Morris
	' Details...:    Added: Public ChangeDeviceSettings().
	'			   Removed: Code to handle btnConfig (settings button).
	'				   Mod: btnConnection button now btnLeaveCentre.
	'
	' Date......: 11/06/20
	' Release...: 24
	' Overview..: Mod: Support for second Server.
	' Amendee...: D Morris.
	' Details...:  Mod: IsCentreOpen().
	'
	' Date......: 18/06/20
	' Release...: 25
	' Overview..: Add #0395: Select Centre with Logos (Experimental).
	' Amendee...: D Morris.
	' Details...:    Mod: Initialize() select the Task Select form.
	'				 Mod: ResumeOp() displays centre picture if applicable.
	'
	' Date......: 28/06/20
	' Release...: 26
	' Overview..: Add #0395 Select centre pictures (experimental - images changed to "your business").
	' Amendee...: D Morris.
	' Details...:    Mod: ResumeOp().
	'
	' Date......: 17/07/20
	' Release...: 27
	' Overview..: Start on new UI theme (First phase changing buttons to Orange with rounded corners. 
	' Amendee...: D Morris.
	' Details...: Mod: Buttons changed to swiftbuttons.
	'
	' Date......: 02/08/20
	' Release...: 28
	' Overview..: UI to select centre.
	' Amendee...: D Morris.
	' Details...: Mod: progressbox_Timeout(), btnLeaveCentre_Click().
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
	Private xui As XUI							'ignore (to remove warning)
		
	Private notification As clsNotifications	' Handles notifications
	
	' Local constants
	Private Const DEFAULT_TIME_STAMP As Int = 1
	
	' Activity view declarations
'	Private btnLeaveCentre As B4XView			' Leave centre
'	Private btnPlaceOrder As B4XView			' Place order button.
'	Private btnOrderStatus As B4XView			' Show order status button.
'	Private btnShowBill As B4XView				' Show Bills button.
	Private btnLeaveCentre As SwiftButton		' Leave centre
	Private btnPlaceOrder As SwiftButton		' Place order button.
	Private btnOrderStatus As SwiftButton		' Show order status button.
	Private btnShowBill As SwiftButton			' Show Bills button.
#if CENTRE_LOGOS
	Private imgCentrePicture As B4XView			' Centre Picture. 
#End If
	
	' misc objects
	Private progressbox As clsProgressDialog
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(parent As B4XView)
#if CENTRE_LOGOS
	parent.LoadLayout("frmTaskSelect2")
#else
	parent.LoadLayout("frmTaskSelect")
#End If
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers
'' Handles the Click event of the Config button.
'Sub btnConfig_Click
'#if B4A
'	StartActivity(ChangeSettings)
'#else ' B4I
'	xTaskSelect.ClrPageTitle()	' fixes page title operation.
'	frmChangeSettings.show
'#end if
'End Sub

' Handles the Leave Centre button.
Private Sub btnLeaveCentre_Click
'	If Starter.settings.webOnlyComms Then
		xui.Msgbox2Async("Are you sure?", "Leaving this centre", "Yes", "", "No", Null)
		Wait For msgbox_result(result As Int)
		If result = xui.DialogResponse_Positive Then
			Starter.myData.centre.signedOn = False ' log off centre.
			Dim msg As String = modEposApp.EPOS_DISCONNECT & modEposWeb.ConvertToString(Starter.myData.customer.customerId)
#if B4A
			CallSubDelayed2(Starter, "pSendMessage", msg )		
			StartActivity(aSelectPlayCentre3)
#else 'B4I
			Main.SendMessage(msg)
			xTaskSelect.ClrPageTitle()	' fixes page title operation.
			frmXSelectPlayCentre3.Show				
#end if
		End If
'	Else
'#if B4A
'		StartActivity(Connection)
'#else ' B4I
'		xTaskSelect.ClrPageTitle()	' fixes page title operation.
'		frmConnection.Show(False)		
'#end if	
'	End If
End Sub

' Handles the Click event of the Place Order button.
Private Sub btnPlaceOrder_Click
	'#if B4I
	' Clear old order data (in case e.g. the Make Order form's 'Back' nav-button was previously used, avoiding the order being cleared)
	Starter.customerOrderInfo.orderList.Clear
	Starter.customerOrderInfo.orderMessage = ""
	'#End If
	' Apply to the Server to start the order
	lStartPlaceOrder
' Test code for timeout.
'	progressbox.Show("Testing Timeout")
End Sub

' Handles the Click event of the Order Status button.
Private Sub btnOrderStatus_Click
	Wait For (CheckConnection) complete(centreConnectionOk As Boolean)
	If centreConnectionOk Then
#if B4A
		CallSubDelayed(aShowOrderStatusList, "pSendRequestForOrderStatusList")
#else ' B4I
		xTaskSelect.ClrPageTitle()	' fixes page title operation.
		xShowOrderStatusList.Show 	' TODO Check if this is necessary.
		xShowOrderStatusList.SendRequestForOrderStatusList
#End If		
	End If
End Sub

' Handles the Click event of the Show Bill button.
Private Sub btnShowBill_Click
	Wait For (CheckConnection) complete(centreConnectionOk As Boolean)
	If centreConnectionOk Then
#if B4A
		CallSubDelayed(aShowBill, "pSendRequestForBill")
#else ' B4I
		xTaskSelect.ClrPageTitle()	' fixes page title operation.
		xShowBill.Show		' TODO Check if this is necessary.
		xShowBill.SendRequestForBill
#end if		
	End If
End Sub

' Progress dialog has timed out
Private Sub progressbox_Timeout()
	Dim tempLocationRec As clsEposWebCentreLocationRec
	tempLocationRec.Initialize
	tempLocationRec.centreName = Starter.myData.centre.name
	tempLocationRec.centreOpen = True 
	tempLocationRec.id = Starter.myData.centre.centreId
#if B4A
	CallSubDelayed2(ValidateCentreSelection2, "ValidateSelection", tempLocationRec)
#else ' B4I
	xTaskSelect.ClrPageTitle()	' fixes page title operation.
	frmXValidateCentreSelection2.Show(tempLocationRec)
#end if
End Sub
#end Region Event Handlers

#Region  Public Subroutines
' Changes device settings
Public Sub ChangeDeviceSettings
#if B4A
	StartActivity(ChangeSettings)
#else ' B4I
	xTaskSelect.ClrPageTitle()	' fixes page title operation.
	frmChangeSettings.show
#end if
End Sub

' Handles the Order Start reponse from the Server by displaying a relevant messagebox and then starting the Show Order activity.
Public Sub HandleOrderStart(orderStartStr As String)
	ProgressHide ' Always hide the progress dialog
#if B4A
	Dim xmlStr As String = orderStartStr.SubString(modEposApp.EPOS_ORDER_START.Length) ' TODO - check if the XML string is valid?
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(orderStartStr) ' TODO - check if the XML string is valid?
#end if
	Dim responseObj As clsOrderStartResponse : responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr)' TODO - need to check if the deserialisation was successful?
	If responseObj.accept Then ' OK to go ahead with order - display any instruction message if required
		If responseObj.message <> "" Then 
			xui.MsgboxAsync(responseObj.message, "Order instructions")
			Wait For MsgBox_Result(Result As Int)			
		End If
		Starter.myData.centre.allowDeliverToTable = responseObj.allowDeliverToTable
		Starter.myData.centre.disableCustomMessage = responseObj.disableCustomMessage
#if B4A
		StartActivity(aPlaceOrder)
#else ' B4I
		xTaskSelect.ClrPageTitle()	' fixes page title operation.
		xPlaceOrder.Show
#end if
	Else ' Not allowed to place an order - display the reason why
		xui.MsgboxAsync("Reason: " & responseObj.message, "Order cannot be placed")
		wait for MsgBox_Result(Result As Int)
	End If
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

' Handles resume operation.
Public Sub ResumeOp
'	' Update the visibility of the activity's controls as required
'	lHandleConfigButton
'	lHandleConnectionButton
'	' Detect pending notifications and display them as required
#if B4A
	If Starter.PrevMessage <> "" Then
		ShowMessageNotificationMsgBox(False)
	End If
	If Starter.PrevStatus(0) <> "" Then
		ShowStatusNotificationMsgBox(False)
	End If
#else ' B4A
	' TODD Need B4I code to check the previous message  and status as above.
#end if

#if CENTRE_LOGOS
'	If Starter.myData.centre.centreId = 55 Then
'		imgCentrePicture.SetBitmap(xui.LoadBitmapResize(File.DirAssets, "momentumoffices_001.jpg", imgCentrePicture.Width, imgCentrePicture.Height, True))
'	Else
''		imgCentrePicture.SetBitmap(xui.LoadBitmapResize(File.DirAssets, "imagenotavailablesmall.png", imgCentrePicture.Width, imgCentrePicture.Height, True))
'		imgCentrePicture.SetBitmap(xui.LoadBitmapResize(File.DirAssets, "orderandpayapp.jpg", imgCentrePicture.Width, imgCentrePicture.Height, True))
'	End If
	
	Dim img  As ImageView
	img.Initialize("test")
	Wait For (Starter.DownloadImage(Starter.myData.centre.picture, img)) complete(a As Boolean)
	Dim bt As Bitmap = img.Bitmap
	imgCentrePicture.SetBitmap(bt.Resize(imgCentrePicture.Width, imgCentrePicture.Height, True))
#End If

End Sub

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	notification.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	notification.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Checks if connected to centre.
private Sub CheckConnection() As ResumableSub
	' Setup up variables, and ensure the relevant service is running
	Dim centreConnectedOk As Boolean = False

	ProgressShow("Checking connection...")
	' Detect if any problems with the connection to the centre.
'	If Starter.settings.webOnlyComms Then
#if B4A
		Wait For (Starter.connect.IsInternetAvailable) complete (internetAvailable As Boolean)
#else ' B4I
		Wait For (Main.connect.IsInternetAvailable) complete (internetAvailable As Boolean)
#End If
		If internetAvailable Then
			Wait For (IsCentreOpen(Starter.myData.centre.centreId)) complete(centreOpen As Boolean)
			If centreOpen Then
				centreConnectedOk = True	
			Else
#if B4A	' HACK for Android only to deal with the HttpJob problem, see #0262.
				xui.MsgboxAsync("This centre is closed or cannot take orders, ask a member of staff.", "Centre problem" )
#else ' B4I  ' HACK for iOS to deal issue #0293.
				xui.MsgboxAsync("This centre is closed or cannot take orders, ask a member of staff.", "Centre problem" )
#End If
				Wait For Msgbox_Result (Result As Int)
#if B4A 
				StartActivity(CheckAccountStatus)
#else ' B4I
				frmCheckAccountStatus.Show(True)
#End If						
			End If
		Else
			ReportNoInternet
		End If
'	Else ' Check wifi connection.
'#if B4A
'		If Starter.connect.IsWifiOn Then ' The phone's Wifi is enabled
'			If Starter.connect.IsWifiQuickCheckOk = False Then ' Wifi strength is too low to reliably communicate
'#else ' B4I
'		If Main.Connect.IsWifiOn Then
'			If Main.Connect.IsWifiQuickCheckOk = False Then
'#End If
'				xui.MsgboxAsync("Please try to move to an area with a better WiFi signal.", "WiFi Signal Strength Low")
'			End If
'			centreConnectedOk = True
'		Else ' The phone's Wifi is not enabled
'			Dim message As String = "The ordering system will not work without WiFi." &	CRLF & "Please switch it on!"
'			xui.MsgboxAsync(message, "WiFi Not Enabled")
'		End If
'	End If
	ProgressHide
	Return centreConnectedOk
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
'	origConnectText = btnConnection.Text	' save the original connect button text.
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
	notification.Initialize
End Sub


'' Sets the visibility of the Config button according to test mode status, rearranging nearby controls as required.
'Private Sub lHandleConfigButton
'#if B4A
'	Dim testMode As Boolean = Starter.settings.testMode
'	btnConfig.Visible = testMode
'#else ' B4I
'	' Handled by sub in xTaskSelect - Need to move code to here!
'	If Starter.Settings.testMode Then
'		btnConfig.Visible = True
'	Else
'		btnConfig.Visible = False
'	End If
'#End If
'
'End Sub

'' Handle the Text displayed on connection button.
'private Sub lHandleConnectionButton
'	If Starter.settings.webOnlyComms Then
'		btnConnection.Text = "Leave Centre"
'	Else
'		btnConnection.Text = origConnectText	' Replace original text.
'	End If
'End Sub

' Checks if a centre is open
private Sub IsCentreOpen(centreId As Int) As ResumableSub
	Dim centreOpen As Boolean = False
	Dim job As HttpJob : job.Initialize("CheckCentreAPI", Me)
'	Dim apiString As String = modEposWeb.URL_CENTRE_API & "/" & centreId & _
'							 "?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_OPEN_QUERY 'search=open"
	Dim apiString As String = Starter.server.URL_CENTRE_API & "/" & centreId & _
							 "?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_OPEN_QUERY 'search=open"
	job.Download(apiString  )
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxMsg As String = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)		
		If IsNumber(rxMsg) Then
			Dim statusValue As Int = rxMsg
			If statusValue = 1 Then
				centreOpen = True
			End If
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	Return centreOpen
End Sub

' Starts the order placing procedure. .
Private Sub lStartPlaceOrder()
	Wait For (CheckConnection) complete(centreConnectionOk As Boolean)
	If centreConnectionOk Then
		ProgressShow("Starting your order, please wait...") ' TODO Progress box needs moving up
		
		Dim apiHelper As clsEposApiHelper
		apiHelper.Initialize
		Wait for (apiHelper.CheckMenuRevision) complete (menuOk As Boolean)
		If menuOk Then ' Menu ok
			Dim msgToSend As String = modEposApp.EPOS_ORDER_START & "," & Starter.myData.Customer.customerId & _
									"," & DEFAULT_TIME_STAMP & "," & Starter.customerOrderInfo.tableNumber	
			' Taken from https://www.b4x.com/android/forum/threads/solved-resumable-subs-and-callbacks.103775/
#if B4A
			Dim SendMsg As ResumableSub = CallSub2(Starter, "pSendMessageAndCheckReconnect", msgToSend)
#else ' B4I
			Dim SendMsg As ResumableSub = Main.SendMessageAndCheckReconnect(msgToSend)
#End If
			Wait For (SendMsg) Complete( statusCodeResult As Int)
		Else ' Menu error = resync data.
			xui.MsgboxAsync("Your will need to resync your menu with the Centre.", "Menu out of date!" )
			Wait For Msgbox_Result (Result As Int)
#if B4A
			CallSubDelayed(aSyncDatabase, "pSyncDataBase")
#Else
			xTaskSelect.ClrPageTitle()	' fixes page title operation.
			xSyncDatabase.show
#End If			
		End If
	End If
End Sub

' Hide the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Show The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Report no internet detected.
Private Sub ReportNoInternet
	xui.MsgboxAsync("Unable to continue without a working Internet connection.", "No Internet!" )
End Sub

#End Region  Local Subroutines