B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@

'
' class to handle communications.
'
#Region  Documentation
	'
	' Name......: clsCommunications
	' Release...: 1
	' Date......: 10/02/21
	'
	' History
	' Date......: 10/02/21
	' Release...: 1
	' Created by: D Morris
	' Details...: New class - code taken from Starter_v92.
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
	Public connect As clsConnect
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	connect.Initialize
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'' CHecks if internet is available.
'public Sub IsInternetAvailable As ResumableSub
'	Dim sf As ResumableSub = connect.IsInternetAvailable
'	wait for (sf) complete (internetAvailable As Boolean)	
'	Return internetAvailable
'End Sub

' Processes a input communications string.
public Sub ProcessInputStrg(inputCommsStrg As String)
	Try ' Try/Catch added here to investigate crash when receiving a message after being asleep for some time
		If inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_REQUEST) Then
			HandleCustomerDetailsMsg(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_CONFIRM) Then
			HandleOpenTabConfirm(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_RECONNECT) Then
#if B4A 
'			Starter.connect.ReconnectSuccess
			connect.ReconnectSuccess
#else ' B4i
			connect.ReconnectSuccess
#End If
			SendQueuedMsgAfterReconnect
		Else If inputCommsStrg.StartsWith(modEposApp.EPOS_DISCONNECT) Then
			DisconnectedByServer(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_SYNC_DATA) Then
			HandleSyncDataResponse(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_ACKN) Then
#if B4A
			CallSubDelayed2(aPlaceOrder, "HandleOrderAcknResponse", inputCommsStrg) ' Calls an Activity
#else ' B4i
			xPlaceOrder.HandleOrderAcknResponse(inputCommsStrg)
#End If
		Else If inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_QUERY) Then
#if B4A
			CallSubDelayed2(aHome, "HandleOrderInfo", inputCommsStrg) ' Calls an Activity
#Else ' B4i
			xHome.HandleOrderInfo(inputCommsStrg)
#End If
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_SEND) Then
#if B4A
			CallSubDelayed2(aPlaceOrder, "HandleOrderResponse", inputCommsStrg) ' Calls an Activity
#else ' B4i
			xPlaceOrder.HandleOrderResponse(inputCommsStrg)
#End If
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDERSTATUSLIST) Then
			HandleStatusListMsg(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDERSTATUS) Then
			NotifyStatus(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_START) Then
#if B4A
			CallSubDelayed2(aHome, "HandleOrderStart", inputCommsStrg) ' Calls an Activity
#else ' B4i
			xHome.HandleOrderStart(inputCommsStrg)
#End If
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_PING) Then
			HandlePing(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_MESSAGE) Then
			NotifyMessage(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_BALANCECHECK) Then
			HandleBalanceCheckMsg(inputCommsStrg)
		Else If inputCommsStrg.StartsWith(modEposApp.EPOS_UPDATE_CUSTOMER) Then
			HandleUpdateCustomer(inputCommsStrg)
		else if inputCommsStrg.StartsWith(modEposApp.EPOS_PAYMENT) Then
			HandlePaymentResponse(inputCommsStrg)
		else if inputCommsStrg.StartsWith(modEposApp.EPOS_GET_LOCATION) Then
			HandleGetLocationRequest
		End If
	Catch
		Log("Comms string:" & inputCommsStrg)
#if B4A
		Starter.LogFile.LogReport(modEposApp.ERROR_COMMS_FILENAME, "A comms error occurred. Exception type:" & LastException.Message & _
								CRLF & CRLF & "Current contents of the comms buffer:" & CRLF & inputCommsStrg)
#else ' B4i
		Main.AppendToExtLog(Main.ERROR_COMMS_FILENAME, "A comms error occurred. Exception type:" & LastException.Message & _
								CRLF & CRLF & "Current contents of the comms buffer:" & CRLF & inputCommsStrg)
#End If

#if B4A
		ToastMessageShow("An error occurred while communicating with the server. Please try again.", True)
#else
		Main.ToastMessageShow("An error occurred while communicating with the server. Please try again.", True)
#End If
	End Try
End Sub

' Sends the specified message through the socket to the Server.
Public Sub SendMessage(msg As String) As ResumableSub
	Dim statusCode As Int = 200
	If Starter.settings.webOnlyComms = False Then
		Dim sNewLine As String
#if B4A
		sNewLine = modEposApp.HEADER_STRING & msg & modEposApp.EOF_STRING ' & CRLF
#Else ' B4i
		sNewLine = Main.HEADER_STRING & msg & Main.EOF_STRING ' & CRLF
#End If

#if INCLUDE_SOCKET_CODE		
		Dim buffer() As Byte
		buffer = sNewLine.GetBytes("UTF8")
		Starter.Astreams.Write(buffer)
#end if
	Else
		Dim job As HttpJob : job.Initialize("NewCustomer", Me)
		' Smart string literals see https://www.b4x.com/android/forum/threads/b4x-smart-string-literal.50135/
		' $"xml{msg}"$	' XML - Escapes the five XML entities (", ', <, >, &): - I Think!
		Dim newMsg As String
		newMsg = msg.Replace(Chr(34) , "\""")
		Dim tempMsg As String = """" & newMsg & """" '  Temp 4 quotes in row are required to put a quote around the message text.
		Dim centreIdStrg As String = NumberFormat2(Starter.myData.centre.centreId, 3, 0, 0, False)	' Ensures large numbers converted correcly
		Dim urlString As String = Starter.server.URL_COMMS_API & "?" & modEposWeb.API_SEND_MSG & "=0" & "&" & _
											modEposWeb.API_CENTRE_ID  & "=" & centreIdStrg & "&"  & _
											modEposWeb.API_CUSTOMER_ID & "=" & Starter.myData.customer.customerIdStr
		job.PutString(urlString, tempMsg)
		job.GetRequest.SetContentType("application/json;charset=UTF-8")
		Wait For (job) JobDone(job As HttpJob)
		Log("Send Message response:" & job.Success & " Code:" & job.Response.StatusCode)
		If job.Success And job.Response.StatusCode = 200 Then
			'Hack code removed until problem with HttpJob fixed see #0262 and #0291.
'		''	ToastMessageShow("Comms message sent to Web Server.", True)
'		Else If job.Success And job.Response.StatusCode = 204 Then
'			ToastMessageShow("Centre Closed", True)
'		Else ' An error of some sort occurred
'			Dim errorMsg As String = "An error occurred with the HTTP job: " & job.ErrorMessage
'			ToastMessageShow(errorMsg, True)
			'
		End If
		statusCode = job.Response.StatusCode
		job.Release ' Must always be called after the job is complete, to free its resources
	End If
	Return statusCode
End Sub

Public Sub SendMessageAndCheckReconnect(msgToSend As String) As ResumableSub
	Dim statusCodeResult As Int = 200
#if B4A
	If Starter.ReconnectFailed Then
		Starter.ReconnectQueuedMsg = msgToSend
		Starter.ReconnectEnabled = True ' Start a reconnect
#else ' B4i
	If Main.ReconnectFailed Then
		Main.ReconnectQueuedMsg = msgToSend
		Main.ReconnectEnabled = True ' Start a reconnect
#End If

#if B4A 
		Starter.ConnectToServer
#else ' B4i
		Main.ConnectToServer
#End If
	Else
		'	pSendMessage(msgToSend)
		Wait For (SendMessage(msgToSend)) complete(statusCode As Int)
		statusCodeResult = statusCode
	End If
	Return statusCodeResult
End Sub

' Sends an open tab message
Public Sub SendOpenTab
#if B4A
	Dim msg As String = modEposApp.EPOS_OPENTAB_REQUEST & "," & Starter.MyIpAddress & _
						 "," & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
						 "," & Starter.myData.customer.BuildUniqueCustomerInfoString & _
						 "," & Starter.myData.customer.rev
#else ' B4i
	Dim msg As String = modEposApp.EPOS_OPENTAB_REQUEST & "," & Main.MyIpAddress & _
						 "," & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
						 "," & Starter.myData.customer.BuildUniqueCustomerInfoString & _
						 "," & Starter.myData.customer.rev
#End If
	SendMessage(msg)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Process disconnect command from server
Private Sub DisconnectedByServer(msg As String)
	Dim apiCustomerId As Int = msg.SubString(modEposApp.EPOS_DISCONNECT.Length)
	If apiCustomerId = modEposWeb.BuildApiCustomerId() Then ' Correct command for this customer?
#if B4A
		Starter.IsConnected = False
#else ' B4i
		Main.IsConnected = False
#End If

#if B4A
		Starter.StopAntiSleepPhoneModes ' Stop the potentially battery-draining anti-sleep measures
#end if
#if B4A
		'Starter.connect.StopServerChecking ' Stop the regular server pings (as they will cause reconnection)
		connect.StopServerChecking
#else ' B4i
		connect.StopServerChecking
#End If

#if B4A
		Starter.DisconnectedCloseActivities = True
#else ' B4i
		Main.DisconnectedCloseActivities = True
#End If

	End If
End Sub

' Deserialises the specified Balance Check XML string, processes it, and replies to the Server.
Private Sub HandleBalanceCheckMsg(balanceCheckStr As String)
#if B4A
	Dim xmlStr As String = balanceCheckStr.SubString(modEposApp.EPOS_BALANCECHECK.Length)
#else ' B4i
	Dim xmlStr As String = Main.TrimToXmlOnly(balanceCheckStr)
#End If
	Dim balanceCheckObj As clsEposBalanceCheckRec : balanceCheckObj.initialize
	balanceCheckObj = balanceCheckObj.XmlDeserialize(xmlStr)
#if B4A
	balanceCheckObj.phoneTotal = srvPhoneTotal.phoneTotal
#else ' B4i - Until service prefix changed.
	balanceCheckObj.phoneTotal = svcPhoneTotal.phoneTotal
#End If
	balanceCheckObj.centreId = Starter.myData.centre.centreId
	balanceCheckObj.customerId = Starter.myData.customer.customerId
	Dim msg As String = modEposApp.EPOS_BALANCECHECK & balanceCheckObj.XmlSerialize(balanceCheckObj)
	If balanceCheckObj.zeroTotals Then
#if B4A
		CallSub(srvPhoneTotal, "ZeroPhoneTotal")
#Else ' B4i - Until service prefix changed.
		svcPhoneTotal.ZeroPhoneTotal
#End If
	End If
	SendMessage(msg)
End Sub

' Deserialises the specified Customer Details XML string, and updates the global .CustomerDetails structure
Private Sub HandleCustomerDetailsMsg(openTabCmdResponseStr As String)
	' TODO Duplicated code see connection.pConfirmCustomerDetails()
#if B4A
	Dim xmlStr As String = openTabCmdResponseStr.SubString(modEposApp.EPOS_OPENTAB_REQUEST.Length)
#else ' B4i
	Dim xmlStr As String = Main.TrimToXmlOnly(openTabCmdResponseStr)	
#End If
	Dim customerDetailsObj As clsEposCustomerDetails : customerDetailsObj.Initialize
	customerDetailsObj = customerDetailsObj.XmlDeserialize(xmlStr)
	Dim centreSignonOk As Boolean = False
	If customerDetailsObj.customerId <> "0" Then ' Customer ID accepted?
#if B4A
		Starter.DisconnectedCloseActivities = False
		Starter.IsConnected = True
#else ' B4i
		Main.DisconnectedCloseActivities = False
		Main.IsConnected = True
#End If

#if B4A
		Starter.StartAntiSleepPhoneModes ' Now it's connected, prevent the app from sleeping so that all messages get through
#end if

#if B4A
		'Starter.connect.StartServerChecking ' Start the regular polling for server only when connected
		connect.StartServerChecking
#else ' B4i
		connect.StartServerChecking
#End If
		' TODO Test code for EPOS_OPENTAB_REQUEST response
		Starter.myData.centre.acceptCards = customerDetailsObj.acceptCards
		Starter.myData.customer.address = customerDetailsObj.address
		Starter.myData.customer.cardAccountEnabled = customerDetailsObj.cardAccountEnabled
		Starter.myData.centre.centreId = customerDetailsObj.centreId
		Starter.myData.customer.customerId = customerDetailsObj.customerId
		Starter.myData.customer.email = customerDetailsObj.email
		Starter.myData.customer.name = customerDetailsObj.name
		Starter.myData.customer.nickName = customerDetailsObj.nickName
		Starter.myData.centre.publishedKey = customerDetailsObj.publishedKey
		Starter.myData.customer.rev = customerDetailsObj.rev
		centreSignonOk = True
	End If
#if B4A
	CallSubDelayed2(aValidateCentreSelection2, "ConnectToServerResponse", centreSignonOk) ' Calls an Activity
#else ' B4i
	xValidateCentreSelection2.ConnectToServerResponse(centreSignonOk)
#End If
End Sub

' Handles EPOS_GET_LOCATION request and sends a response.
Private Sub HandleGetLocationRequest()
	Dim locationRec As clsEposLocationRec : locationRec.Initialize
	locationRec.ID = Starter.myData.customer.customerId
	locationRec.location.latitude = Starter.latestLocation.Latitude
	locationRec.location.longitude = Starter.latestLocation.Longitude
	Dim msg As String = modEposApp.EPOS_GET_LOCATION & locationRec.XmlSerialize
	SendMessage(msg)
End Sub

' Handle the Open TAB confirmation 
private Sub HandleOpenTabConfirm(openTabConfirmResponse As String)
	' TODO Duplicated code see connection.pConfirmCustomerDetails()
#if B4A
	Dim xmlStr As String = openTabConfirmResponse.SubString(modEposApp.EPOS_OPENTAB_CONFIRM.Length)
#else ' B4i
	Dim xmlStr As String = Main.TrimToXmlOnly(openTabConfirmResponse)
#End If
	Dim customerDetailsObj As clsEposCustomerDetails : customerDetailsObj.Initialize
	customerDetailsObj = customerDetailsObj.XmlDeserialize(xmlStr)
	If customerDetailsObj.authorized Then
		If customerDetailsObj.customerId = Starter.myData.customer.customerId Then ' Customer ID correct?
			If customerDetailsObj.centreId = Starter.myData.centre.centreId Then ' Centre ID correct?
				Starter.myData.centre.signedOn = True ' Flag signed on to this centre.
#if B4A
				CallSubDelayed(aValidateCentreSelection2, "OpenTabConfirmResponse") ' Calls an Activity
#else ' B4i
				xValidateCentreSelection2.OpenTabConfirmResponse
#End If
			End If
		End If
	End If
End Sub

' Handle payment response string.
private Sub	HandlePaymentResponse(paymentResponse As String)
#if B4A
	Dim xmlStr As String = paymentResponse.SubString(modEposApp.EPOS_PAYMENT.Length)
#else 'B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(paymentResponse)
#end if
	Dim paymentInfo As clsEposCustomerPayment : paymentInfo.Initialize
	paymentInfo = paymentInfo.XmlDeserialize(xmlStr)
#if B4A
	CallSubDelayed2( aHome, "ReportPaymentStatus", paymentInfo) 
#else ' B4I
	xHome.ReportPaymentStatus(paymentInfo)
#end if
End Sub

' Handles the response To a server ping.
Private Sub HandlePing(txtPing As String)
	' TODO Need to check if customer number is correct
	Dim rxMsg As String
	rxMsg = txtPing.SubString(modEposApp.EPOS_PING.Length)
	Dim fields() As String
	fields = Regex.Split(",", rxMsg)
	If fields.Length = 2 Then ' ping (response required)?
		DateTime.DateFormat = "HH:mm:ss"
		Dim timeStamp As String = "Time:" & DateTime.Date(DateTime.Now)
#if B4A
		Dim txMsg As String = modEposApp.EPOS_PING  & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
								 "," & connect.GetWifiSignalStrength  & "%" & _
								 "," & timeStamp
#else ' B4i
		Dim txMsg As String = modEposApp.EPOS_PING  & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
								 "," & connect.GetWifiSignalStrength  & "%" & _
								 "," & timeStamp
#End If
		SendMessage(txMsg)
	Else ' response ping (no resposne expected)
#if B4A
		'Starter.connect.ServerCheckSuccess
		connect.ServerCheckSuccess
#else ' B4i
		connect.ServerCheckSuccess
#End If
	End If
End Sub

' Handles the Server's response to the Get Status List command.
Private Sub HandleStatusListMsg(statusListMsg As String)
	If srcTestSequence.TestSeqRunning Then ' Original command was a test message
#if B4A
		CallSub(srcTestSequence, "ReceivedResponse")
#Else ' B4i - Until service prefix changed.
		srcTestSequence.ReceivedResponse
#End If
	Else
#if B4A
		If Not(IsPaused(aHome)) Then ' Only show Status list if Home is visible.
			CallSubDelayed2(aHome, "HandleOrderStatusList", statusListMsg) ' Calls an Activity
		End If
#else ' B4i 
		If xHome.IsVisible Then' Only show Status list if Home is visible.
			xHome.HandleOrderStatusList(statusListMsg)
		End If
#End If
	End If
End Sub

' Handles the Server's response to the menu (sync data).
Public Sub HandleSyncDataResponse(syncDataResponse As String)
#if B4A
	CallSubDelayed2(aHome, "HandleSyncDbResponse", syncDataResponse) 
#else ' B4i
	xHome.HandleSyncDbResponse(syncDataResponse)
#End If
End Sub

' Deserialises the specified Update Customer XML string, and uses it to update the locally-stored customer info.
Private Sub HandleUpdateCustomer(updateCustomerMsg As String)
#if B4A
	Dim xmlStr As String = updateCustomerMsg.SubString(modEposApp.EPOS_UPDATE_CUSTOMER.Length)
#else ' B4i
	Dim xmlStr As String = Main.TrimToXmlOnly(updateCustomerMsg)
#End If
	Dim newCustomerInfo As clsEposCustomerInfo : newCustomerInfo.Initialize
	newCustomerInfo.XmlDeserialise(xmlStr)
	'TODO - Needs fully testing
	' Take fields from clsEposeCustomerInfo to update myData (note: customerId, email and house number are skipped)
	Starter.myData.customer.address = newCustomerInfo.address
	Starter.myData.customer.name = newCustomerInfo.name
	Starter.myData.customer.nickName = newCustomerInfo.nickName
	SendCustomerUpdateResponse(newCustomerInfo)
End Sub

' Deserialises the specified Message To Customer XML string, and displays it either on the Task Select form or as a notification.
Private Sub NotifyMessage(inStrg As String)
	' Deserialise the XML string argument
#if B4A
	Dim xmlStr As String = inStrg.SubString(modEposApp.EPOS_MESSAGE.Length) ' TODO - check if the XML string is valid?
#else
	Dim xmlStr As String = Main.TrimToXmlOnly(inStrg) ' TODO - check if the XML string is valid?
#End If
	Dim msgObj As clsEposMessageRec : msgObj.Initialize
	msgObj = msgObj.XmlDeserialize(xmlStr)' TODO - need to determine if the deserialisation was successful?
	Dim messageStr As String = "Received at " & DateTime.Time(DateTime.Now) & CRLF & _
	msgObj.headingTop & CRLF & CRLF & msgObj.headingBottom & CRLF & CRLF & msgObj.message & CRLF
#if B4A
	Starter.PrevMessage = messageStr
#else ' B4i
	Main.PrevMessage = messageStr
#End If
	If msgObj.messageId <> 0 Then	' Send message delivery confirmation?
		SendDeliveryMessage(msgObj.messageId)
	End If
#if B4A
	ShowMessageNotification(msgObj.headingTop)
#else ' B4i
	' Raise the notification (the Application_ReceiveLocalNotification() handler will handle it if the app is running)
	Main.NotificationMessage = "You have a new message: " & msgObj.headingTop
	If xHome.IsVisible Then ' Just in case the message relates to an order
		xHome.SendRequestForOrderStatusList
	End If
	Main.RaiseNotification(Main.NotificationMessage)
#End If
End Sub

' Deserialises the specified Message To Customer XML string, and if the user needs to be notified, it will be displayed either
' on the Task Select form or as a notification. Otherwise, the order status form will be updated (if it is active).
Private Sub NotifyStatus(inStrg As String)
#if B4A
	Dim xmlStr As String = inStrg.SubString(modEposApp.EPOS_ORDERSTATUS.Length)
#else ' B4i
	Dim xmlStr As String = Main.TrimToXmlOnly(inStrg) ' TODO - check if the XML string is valid?
#End If
	Dim responseObj As clsEposOrderStatus :	responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr)
	If responseObj.status <> modConvert.statusUnknown Then ' XML has been deserialised OK
		If responseObj.messageId <> 0 Then	' Send message delivery confirmation?
			SendDeliveryMessage(responseObj.messageId)
		End If
		If responseObj.status = modConvert.statusReady And responseObj.deliverToTable = False Then
#if B4A
			Dim tempStatus(2) As String = Array As String("Order #" & responseObj.orderId, "Your order is now ready. " & _
			"Please go to the counter to collect it.")
			Starter.PrevStatusRec = responseObj
			Starter.PrevStatus = tempStatus ' Always overwrite status storage with the most recent status
			ShowStatusNotification
#else ' B4i
			Main.PrevStatusRec = responseObj
			' Raise the notification (the Application_ReceiveLocalNotification() handler will handle it if the app is running)
			Main.NotificationStatus = "Your order #" & responseObj.orderId & " is now ready for collection from the counter."
			Main.RaiseNotification(Main.NotificationStatus)
#End If

		else if responseObj.status = modConvert.statusCollected And responseObj.deliverToTable = True Then ' Delivered to table?
#if B4A
			Dim tempStatus(2) As String = Array As String("Order #" & responseObj.orderId, "Your order has been delivered.")
			Starter.PrevStatusRec = responseObj
			Starter.PrevStatus = tempStatus ' Always overwrite status storage with the most recent status
			ShowStatusNotification
#else ' B4i
			Main.PrevStatusRec = responseObj
			Main.NotificationStatus = "Your Order #" & responseObj.orderId & " has been delivered."
			Main.RaiseNotification(Main.NotificationStatus)
#End If
		End If
#if B4A
'		Else if IsPaused(aHome) = False Then ' Other - Only change status if Home screen shown?
		If IsPaused(aHome) = False Then ' Other - Only change status if Home screen shown?
			CallSubDelayed2(aHome, "UpdateOrderStatus", responseObj) ' Calls an Activity
		End If
#else ' b4i
'		Else if xHome.IsVisible = True Then
		If xHome.IsVisible = True Then
			xHome.UpdateOrderStatus(responseObj)
		End If	
#End If

	Else ' XML deserialisation failed (or contains Unknown status, which is just as bad)
#if B4A
		Starter.LogFile.LogReport(modEposApp.ERROR_LIST_FILENAME, "Received bad status message:" & CRLF & inStrg) ' Log the error
#else ' B4i
		Main.AppendToExtLog(modEposApp.ERROR_LIST_FILENAME, "Received bad status message:" & CRLF & inStrg) ' Log the error
#end if
	End If
End Sub

'' Handles the response to a server ping.
'Private Sub PingHandle(txtPing As String)
'	' TODO Need to check if customer number is correct
'	Dim rxMsg As String
'	rxMsg = txtPing.SubString(modEposApp.EPOS_PING.Length)
'	Dim fields() As String
'	fields = Regex.Split(",", rxMsg)
'	If fields.Length = 2 Then ' ping (response required)?
'		DateTime.DateFormat = "HH:mm:ss"
'		Dim timeStamp As String = "Time:" & DateTime.Date(DateTime.Now)
'#if B4A
'		Dim txMsg As String = modEposApp.EPOS_PING  & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
'								 "," & connect.GetWifiSignalStrength  & "%" & _
'								 "," & timeStamp
'#else ' B4i
'		Dim txMsg As String = modEposApp.EPOS_PING  & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
'								 "," & connect.GetWifiSignalStrength  & "%" & _
'								 "," & timeStamp
'#End If
'		SendMessage(txMsg)
'	Else ' response ping (no resposne expected)
'#if B4A
'		'Starter.connect.ServerCheckSuccess
'		connect.ServerCheckSuccess
'#else ' B4i
'		connect.ServerCheckSuccess
'#End If
'	End If
'End Sub

#if B4i
' Raises a notification with the specified body text. If the app is in foreground, vibration and sound will be additionally invoked.
' See the Application_ReceiveLocalNotification() handler for what will happen when the notification arrives (either due to the 
' user pressing it or the app already being in foreground).
Private Sub RaiseNotification(notificationText As String)
	Dim notify As Notification : notify.Initialize(DateTime.Now + 10) ' 10ms added to allow the event queue to process
	notify.IconBadgeNumber = 1
	notify.AlertBody = notificationText
	
'	notify.PlaySound = True

	' This method to set the notification to play a custom sound is taken from:
	' https://www.b4x.com/android/forum/threads/play-custom-sound-file-for-local-or-scheduled-notifications.54940/
	
'	Dim nativeObj As NativeObject = notify
'	nativeObj.SetField("soundName", "notify.wav")

	notify.Register ' Submits the notification to be raised
	
'	If IsVisible Then
'		mPhone.Vibrate
'		mMedia.Initialize(File.DirAssets, "notify.wav", "notificationSound")
'		mMedia.Play
'	End If
End Sub
#End If


' Sends a response to the customer update command
Private Sub SendCustomerUpdateResponse(customerInfoRec As clsEposCustomerInfo)
	Dim msg As String = modEposApp.EPOS_MESSAGE & customerInfoRec.XmlSerialize(customerInfoRec)
	SendMessage(msg)
End Sub

' Send Delivery message
Private Sub SendDeliveryMessage(messageId As Int)
	Dim msg As String = modEposApp.EPOS_DELIVERY & _
						 "," & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
						 "," & modEposWeb.ConvertToString(messageId)
	SendMessage(msg)
End Sub

' Sends the message which had been queued to be sent after automatically reconnecting (if any).
Private Sub SendQueuedMsgAfterReconnect
#if B4A
	If Starter.reconnectQueuedMsg <> "" Then
		SendMessage(Starter.reconnectQueuedMsg)
		Starter.reconnectQueuedMsg = ""
	End If
#else ' B4i
	If Main.reconnectQueuedMsg <> "" Then
		SendMessage(Main.reconnectQueuedMsg)
		Main.reconnectQueuedMsg = ""
	End If
#End If
End Sub

' Shows a message notification
Private Sub ShowMessageNotification(headingTop As String)

#if B4A
	' Show the message directly, If possible, otherwise raise a notification
	If IsPaused(aHome) = False Then
		CallSubDelayed2(aHome, "ShowMessageNotificationMsgBox", True) ' Calls an Activity
	else if IsPaused(aPlaceOrder) = False Then
		CallSubDelayed2(aPlaceOrder, "ShowMessageNotificationMsgBox", True) ' Calls an Activity
	else if IsPaused(aSelectItem) = False Then
		CallSubDelayed2(aSelectItem, "ShowMessageNotificationMsgBox", True) ' Calls an Activity
	Else ' Task Select activity is not currently active - raise a notification instead
		Dim titleContentTag(3) As String = Array As String("You have a new message", headingTop, modEposApp.NOTIFY_MESSAGE_TAG)
		Starter.NotificationMessage = CallSub3(srvNotification, "pSimple_Notification", titleContentTag, modEposApp.NOTIFY_MESSAGE_ID)
	End If
#else  ' B4i
	'TODO Check if code required for B4i - DM 09/02/21 - don't appear necessary.
#End If

End Sub

' Shows a status notification.
Private Sub ShowStatusNotification
#if B4A
	' Either show the message directly or raise a notification as required
	If IsPaused(aHome) = False Then
		CallSubDelayed2(aHome, "ShowStatusNotificationMsgBox", True) ' Calls an Activity
	else if IsPaused(aPlaceOrder) = False Then
		CallSubDelayed2(aPlaceOrder, "ShowStatusNotificationMsgBox", True) ' Calls an Activity
	else if IsPaused(aSelectItem) = False Then
		CallSubDelayed2(aSelectItem, "ShowStatusNotificationMsgBox", True) ' Calls an Activity
	Else ' Task Select activity is not currently active - raise a notification instead
		Dim titleContentTag(3) As String = Array As String(Starter.PrevStatus(0), Starter.PrevStatus(1), modEposApp.NOTIFY_STATUS_TAG)
		Starter.NotificationStatus = CallSub3(srvNotification, "pSimple_Notification", titleContentTag, modEposApp.NOTIFY_STATUS_ID)
	End If
#else ' B4i
	'TODO Check if code required for B4i - DM 09/02/21 - don't appear necessary.
#End If

End Sub

#if B4A

#Else ' B4i - Until service prefix changed.

#End If


#End Region  Local Subroutines
