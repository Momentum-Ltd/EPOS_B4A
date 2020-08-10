B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=7.3
@EndOfDesignText@
'
' This Activitt acts as a main menu, allowing the operator to choose which task to perform next.
'
#Region  Documentation
	'
	' Name......: TaskSelect
	' Release...: 34
	' Date......: 13/10/19
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on AmdroidRemote V2
	'     Versions 2 - 12 see TaskSelect_v15
	'     Versions 13 - 20 see TestSelect_v22
	'     Versions 21 = 30 see TestSelect_v30
	'
	' Date......: 07/08/19
	' Release...: 31
	' Overview..: Improved status reporting and support for myData.
	' Amendee...: D morris
	' Details...: Mods: lStartPlaceOrder().
	'			  Mods: pHandleOrderAcknResponse() now handles the forDelivery parameter.
	'
	' Date......: 03/09/19
	' Release...: 32
	' Overview..: Support for card payments.
	' Amendee...: D Morris
	' Details...: Mod: pHandleOrderAcknResponse() supports card payments.
		'
	' Date......: 05/09/19
	' Release...: 33
	' Overview..: Now disconnect when leaving a centre.
	' Amendee...: D Morris
	' Details...: Mod: btnConnection_Click() sends disconnect message to Centre server.
		'
	' Date......: 13/10/19
	' Release...: 34
	' Overview..: Support for sub name changes.
	' Amendee...: D Morris
	' Details...:  Mod: clsOrderStartResponse.pXmlDeserialize() renamed to XmlDeserialize().
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
#End Region  Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' Currently none
End Sub

Sub Globals
	
	' Local constants
	Private Const DEFAULT_TIME_STAMP As Int = 1
	
	' Activity view declarations
	Private btnConfig As Button
	Private btnConnection As Button
	Private btnPlaceOrder As Button
	Private btnOrderStatus As Button
	Private btnShowBill As Button
	
	' Local variables
	Private alertCustomerVibrate As PhoneVibrate
	Private rm As RingtoneManager
	Private origConnectText As String
	Private cardProcessor As clsCardPayment
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmTaskSelect")
	origConnectText = btnConnection.Text	' save the original connect button text.
	cardProcessor.Initialize
End Sub

Sub Activity_Resume
	' Update the visibility of the activity's controls as required
	lHandleConfigButton
	lHandleConnectionButton
	
	' Detect pending notifications and display them as required
	If Starter.PrevMessage <> "" Then pShowMessageNotificationMsgBox(False)
	If Starter.PrevStatus(0) <> "" Then pShowStatusNotificationMsgBox(False)
End Sub

Sub Activity_Pause(UserClosed As Boolean)
	If Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

Sub Activity_Keypress(KeyCode As Int) As Boolean
	' Prevent 'Back' softbutton, from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
	If KeyCode = KeyCodes.KEYCODE_BACK Then ' The 'Back' softbutton was pressed
		Return True ' Returning true consumes the event, preventing the 'Back' action
	Else ' It wasn't the 'Back' softbutton that was pressed
		Return False ' Returning false allows the event to continue
	End If
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Config button.
Sub btnConfig_Click
	StartActivity(ChangeSettings)
End Sub

' Handles the Click event of the Connection button.
Private Sub btnConnection_Click
	If Starter.settings.webOnlyComms Then
		Msgbox2Async("Are you sure?", "Leaving this centre", "Yes", "", "No", Null, False)
		Wait For msgbox_result(result As Int)
		If result = DialogResponse.POSITIVE Then
			CallSubDelayed2(Starter, "pSendMessage", modEposApp.EPOS_DISCONNECT & Starter.myData.customer.customerIdStr)
			StartActivity(xSelectPlayCentre)			
		End If
	Else
		StartActivity(Connection)		
	End If
End Sub

' Handles the Click event of the Place Order button.
Private Sub btnPlaceOrder_Click
	lStartPlaceOrder
End Sub

' Handles the Click event of the Order Status button.
Private Sub btnOrderStatus_Click
	CallSubDelayed(ShowOrderStatusList, "pSendRequestForOrderStatusList")
End Sub

' Handles the Click event of the Show Bill button.
Private Sub btnShowBill_Click
	CallSubDelayed(ShowBill, "pSendRequestForBill")
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Handles the Order Acknowledgement response from the Server by displaying a messagebox with relevant text.
Public Sub pHandleOrderAcknResponse(orderAcknResponseStr As String)
	ProgressDialogHide ' Always hide the progress dialog
	Dim xmlStr As String = orderAcknResponseStr.SubString(modEposApp.EPOS_ORDER_ACKN.Length)
	Dim responseObj As clsEposOrderStatus : responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr)
	
	Dim msg As String = "Your order is " & _
			 modConvert.ConvertStatusToUserString(responseObj.status, responseObj.deliverToTable) ' Generic message, just in case
	If responseObj.status = modConvert.statusWaiting Then ' Order is progressing as normal
		Dim queueStr As String = " " & modConvert.ConvertNumberToOrdinalString(responseObj.queuePosition)
		If responseObj.queuePosition < 1 Then queueStr = ""
		msg = "Your order is being processed, and is" & queueStr & " in the queue."
		Msgbox2Async(msg, "Order Status", "OK", "", "", Null, False)
	Else If responseObj.status = modConvert.statusWaitingForPayment Then ' Payment required before order is processed
		msg = "Payment is required before your order can be processed." & CRLF & "Please select"
		Msgbox2Async(msg, "Order Status", "Card", "Cash", "", Null, False)
		Wait For MsgBox_Result(Result As Int)
		If Result = DialogResponse.POSITIVE Then ' Card?
			cardProcessor.PayByCard(responseObj.amount)
		else if Result = DialogResponse.CANCEL Then ' Cash?
			msg = "Payment is required before your order can be processed." & CRLF & "Please go to the counter."
			Msgbox2Async(msg, "Order Status", "OK", "", "", Null, False)			
		End If
	End If
End Sub

' Handles the Order Start repsonse from the Server by displaying a relevant messagebox and then starting the Show Order activity.
Public Sub pHandleOrderStart(orderStartStr As String)
	ProgressDialogHide ' Always hide the progress dialog
	Dim xmlStr As String = orderStartStr.SubString(modEposApp.EPOS_ORDER_START.Length) ' TODO - check if the XML string is valid?
	Dim responseObj As clsOrderStartResponse : responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr)' TODO - need to check if the deserialisation was successful?
	If responseObj.accept Then ' OK to go ahead with order - display any instruction message if required
		If responseObj.message <> "" Then MsgboxAsync(responseObj.message, "Order instructions")
		Starter.customerOrderInfo.allowDeliverToTable = responseObj.allowDeliverToTable
		Starter.customerOrderInfo.disableCustomMessage = responseObj.disableCustomMessage
		StartActivity(ShowOrder)
	Else ' Not allowed to place an order - display the reason why
		MsgboxAsync("Reason: " & responseObj.message, "Order cannot be placed")
	End If
End Sub

' Hides this activity's progress dialog.
Public Sub pProgressDialogHide
	ProgressDialogHide
End Sub

' Displays this activity's progress dialog with the specified text and cancelable setting.
Public Sub pProgressDialogShow(dialogText As String)
	ProgressDialogShow(dialogText)
End Sub

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub pShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	' Make the notification sound and vibration, if required
	If soundAndVibrate Then
		alertCustomerVibrate.Vibrate(500)
		lPlayRingtone(rm.GetDefault(rm.TYPE_NOTIFICATION))
	End If
	
	' Show the message box
	Msgbox2Async(Starter.PrevMessage, "New message(s)", "OK", "", "", Null, False)
	
	' Clear out previous notification data
	Starter.NotificationMessage.Cancel(modEposApp.NOTIFY_MESSAGE_ID) ' Should be cancelled automatically, but just in case
	Starter.PrevMessage = "" ' Clear the most recent message, as it is checked in multiple places
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub pShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	' Make the notification sound and vibration, if required
	If soundAndVibrate Then
		alertCustomerVibrate.Vibrate(500)
		lPlayRingtone(rm.GetDefault(rm.TYPE_NOTIFICATION))
	End If
	
	' Show the message box and send acknowledgement once it has been dismissed
	Msgbox2Async(Starter.prevstatus(1), Starter.PrevStatus(0), "OK", "", "", Null, False)
	Wait For Msgbox_Result (Result As Int) ' Wait until it has been deliberately dismissed by the user
	lSendStatusAckn(Starter.PrevStatusRec)
	
	' Clear out previous notification data
	Starter.NotificationStatus.Cancel(modEposApp.NOTIFY_STATUS_ID) ' Usually cancelled automatically, but just in case
	Starter.PrevStatus = Array As String("","") ' Clear the most recent order status, as it is checked in multiple places
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Sets the visibility of the Config button according to test mode status, rearranging nearby controls as required.
Private Sub lHandleConfigButton
	Dim testMode As Boolean = Starter.TestMode
	btnConfig.Visible = testMode
	Dim connectionBtnWidthModifier As Int = 0
	If testMode Then connectionBtnWidthModifier = btnConfig.Width
	btnConnection.Width = Activity.Width - (connectionBtnWidthModifier + 40dip)
End Sub

' Handle the Text displayed on connection button.
private Sub lHandleConnectionButton
	If Starter.settings.webOnlyComms Then
		btnConnection.Text = "Leave Centre"
	Else
		btnConnection.Text = origConnectText	' Replace original text.
	End If
End Sub

' See https://www.b4x.com/android/forum/threads/default-message-sound.56476/
Private Sub lPlayRingtone(url As String)
	Dim jo As JavaObject
	jo.InitializeStatic("android.media.RingtoneManager")
	Dim jo2 As JavaObject
	jo2.InitializeContext
	Dim u As Uri
	u.Parse(url)
	jo.RunMethodJO("getRingtone", Array(jo2, u)).RunMethod("play", Null)
End Sub

' Sends a message to the Server acknowledging the specified status notification.
Private Sub lSendStatusAckn(statusRec As clsEposOrderStatus)
	Dim xmlStatus As String = statusRec.XmlSerialize
	CallSub2(Starter, "pSendMessage", modEposApp.EPOS_ORDERSTATUS & xmlStatus)
End Sub

' Starts the order placing procedure. If unable to do so (due to e.g. wifi poor/off), will instead display a relevant message.
Private Sub lStartPlaceOrder()
	' Setup up variables, and ensure the relevant service is running
	Dim centreConnectedOk As Boolean = False
	If IsPaused(Starter) Then ' Belt-and-braces - the Starter is almost guaranteed to be permanently running, but just in case:
		StartService(Starter)
		Sleep(50) ' Allow the service to start by sleeping, causing the message queue to be processed
	End If
	
	' Detect if any problems with the connection to the centre.
	If Starter.settings.webOnlyComms Then
		If Starter.settings.webOnlyComms Then
			If Starter.connect.IsInternetAvailable Then
				centreConnectedOk = True
			End If
		End If
	Else ' Check wifi connection.
		If Starter.connect.IsWifiOn Then ' The phone's Wifi is enabled
			If Starter.connect.IsWifiQuickCheckOk = False Then ' Wifi strength is too low to reliably communicate
				MsgboxAsync("Please try to move to an area with a better WiFi signal.", "WiFi Signal Strength Low")
			End If
			centreConnectedOk = True
		Else ' The phone's Wifi is not enabled
			Dim message As String = "The ordering system will not work without WiFi." &	CRLF & "Please switch it on!"
			MsgboxAsync(message, "WiFi Not Enabled")
		End If	
	End If
	
	' Continue with starting the order, if applicable
	If centreConnectedOk Then
		ProgressDialogShow("Starting your order, please wait...")
		Dim msgToSend As String = modEposApp.EPOS_ORDER_START & "," & Starter.myData.Customer.customerIdStr & _
									"," & DEFAULT_TIME_STAMP & "," & Starter.customerOrderInfo.tableNumber		
		CallSub2(Starter, "pSendMessageAndCheckReconnect", msgToSend)
	End If
End Sub

#End Region  Local Subroutines
