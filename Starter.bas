B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
'
' This service runs at application startup, and is used as a repository for program data as well as handling the socket communications.
'

#Region Documentation
	'
	' Name......: Starter
	' Release...: 86
	' Date......: 09/10/20
	'
	' History
	'	For versions 1-15 see Starter_v19.
	'       versions 16-45 see Starter_v48.
	'	    versions 46-54 see Starter_v57.
	'       versions 55-64 see Starter_v65.
	'		versions 65-71 see Starter_v73.
	'       versions 72-78 see Starter_v79.
	'
	' Date......: 11/06/20
	' Release...: 79
	' Overview..: bugfix: #420 Order status update problem.
	'			   Added: Support for second Server.
	' Amendee...: D Morris.
	' Details...:  Mod: lNotifyStatus() code to aShowOrderStatusList.pUpdateOrderStatus() and aShowBill.RefreshList() removed.
	'			   Mod: Old commented code removed. 
	'			 Added: server object added.
	'			   Mod: Service_Create() initializes server.
	'			   Mod: pSendMessage() uses server object.
	'
	' Date......: 28/06/20
	' Release...: 80
	' Overview..: Add #0395 Select centre pictures (More work to download from Web Server).
	' Amendee...: D Morris
	' Details...:  Added: DownloadImage().
	'
	' Date......: 02/08/20
	' Release...: 81
	' Overview..: UI to select centre.
	' Amendee...: D Morris.
	' Details...: Mod: lHandleCustomerDetailsMsg(), lHandleOpenTabConfirm().
	'
	' Date......: 08/08/20
	' Release...: 82
	' Overview..: Mod: Validate centre page - Confirm centre text added.
	' Amendee...: D Morris
	' Details...:  Mods: lNotifyStatus() - Now updates status when order completed. 
	'			   Mods: pProcessInputStrg(), lHandleStatusListMsg(), lNotifyStatus(),
	'						ShowMessageNotification(), ShowStatusNotification() - Support for new Centre Home page. 
	' 			  			    
	' Date......: 16/09/20
	' Release...: 83 
	' Overview..: More log reports added.
	' Amendee...: D Morris
	' Details...: Service_Create() - log report added.
	' 			  			    
	' Date......: 16/09/20
	' Release...: 84
	' Overview..: Investigation into not running in debug
	' Amendee...: D Morris
	' Details...: Added: Reference to Astream and CltSocket removed by conditional compiler Symbol "INCLUDE_SOCKET_CODE".
	'		
	' Date......: 02/10/20
	' Release...: 85
	' Overview..: Bugfix: #0500 - Validate Centre screen not showing picture after communication timeout.
	' Amendee...: D Morris
	' Details...: Mod: centreLocationRec added.
	' 			  			    
	' Date......: 09/10/20
	' Release...: 86
	' Overview..: Bugfix: #0514 - Not displaying text part of messages.
	' Amendee...: D Morris
	' Details...: Mod: lNotifyMessage() code fixed.
	' 			  			    
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
	'	Review using CallSub() replacing with CallSubDelayed() in many places.
	'
#End Region  Documentation

#Region  Service Attributes
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region  Service Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	
	' Local constants:
	Private Const DISCONNECT_THRESHOLD As Int = 5 						' The number of failed pings that determine the app recognising it is no longer connected.
	Private Const EOF_STRING As String  = "<EOF>" 						' The string that should appear at the end of a socket transmisssion.
	Private const ERROR_COMMS_FILENAME As String = "EposCommsErrors.txt" ' The name of the file used to log comms errors.
	Private Const ERROR_LIST_FILENAME As String = "EposErrorList.txt"	 ' The name of the file used to log exceptions.
	Private Const HEADER_STRING As String = "<MESSAGE_HEADER>" 			' The string that should appear at the start of a socket transmission.
	Private Const PREV_TESTMODE_FILENAME As String = "PrevTestMode.txt" ' The name of the file used to store the Test mode setting.
	Private Const FOREGROUND_NOTIFICATION_ID As Int = 654321 			' The (arbitrary) ID number assigned to the persistent foreground notification.
	
	' Public variables:
	Public connect As clsConnect 						' Object which handles TCP socket operations.
	Public currentLocation As Location					' Current location of this device.
	Public currentPurchaseOrder As Int 					' The current order number.
	Public customerInfoAvailable As Boolean = False 	' Whether the customer information is currently available.
	Public customerOrderInfo As clsEposCustomerOrder 	' The info of the most recent customer's order.
	Public menuRevision As Int							' Menu revision number
	Public DataBase As clsDataBaseTables 				' Database used to store goods and order information.
	Public DisconnectedCloseActivities As Boolean 		' Whether all activities (other than Connection) should be ended due to a disconnect command.
	Public IsConnected As Boolean 						' Whether the device is currently connected to the Server.
	Public latestOrderTotal As Float 					' The most recent order total (updated by ShowOrder when order button pressed).
#if INCLUDE_SOCKET_CODE
	Public MyIpAddress As String 						' This device's IP address.
#else
	Public MyIpAddress As String = "1.0.0.0"			' This device's IP address (temporary IP address is required otherwise problems with communications).
#end if
	Public NotificationMessage As Notification 			' The most recent Message notification object (stored so it can be cancelled).
	Public NotificationStatus As Notification 			' The most recent Order Status notification object (stored so it can be cancelled).
	Public PrevMessage As String 						' Storage for the most recent message notification text. Currently appends new messages until acknowledged.
	Public PrevStatus(2) As String 						' Array used to store the title and message (in that order) of the most recent order status notification.
	Public PrevStatusRec As clsEposOrderStatus 			' The most recent Order Status record (so it can be returned to the Server as acknowledgement).
	Public reconnectEnabled As Boolean = False 			' When set will allow reconnect operation.
	Public reconnectFailed As Boolean = False 			' Stores whether the most recent reconnect attempt failed.
	Public reconnectQueuedMsg As String 				' Stores the comms message to be sent after a successful reconnect (or an empty string if none).
	Public ServerIP As String 							' The IP address of the Server.
	Public settings As clsConfigSettings 				' The class containing the app's settings.
	Public myData As clsMyData							' Store for customer, centre and device information.

	Public server As clsServer							' Storage for server information.
	
	Public selectedCentreLocationRec As clsEposWebCentreLocationRec	' Storage for selected centre location information.
 	
	' Local variables:
#if INCLUDE_SOCKET_CODE
	Private Astreams As AsyncStreams 			' The asynchronous streams object used to read and write socket transmissions.
	Private CltSock As Socket 					' The socket object which handles the connection to the Server.
#end if
'	Private externalFolder As String 			' The path to the externally-acessible storage folder.
	Private disconnectCounter As Int 			' The counter used to determine when the app recognises it is no longer connected to the Server.
	Private inputStrg As String = "" 			' Static storage for incoming socket data.
	Private LogFile As clsReportErrors					' Error logging
	Private mlWifiObj As MLwifi 				' Object which provides wifi info and actions (used here to control the wifi lock)
	Private phoneLock As PhoneWakeState			' Object which allows the phone's wake state to be controlled.
'	Private runtimePerms As RuntimePermissions 	' Object which handles runtime permissions (used when getting .externalFolder).


End Sub

Sub Globals
	' Currently none
End Sub

Sub Service_Create
	Log("Starter.Service_Create")
'	externalFolder = runtimePerms.GetSafeDirDefaultExternal("eposLogs") ' This should happen as early as possible (for exceptions)
	LogFile.Initialize	' Initialize Logging system.
#if INCLUDE_SOCKET_CODE
	Dim testSocket As ServerSocket : testSocket.Initialize(51000, "testSocket") ' To get this devices's IP address
	MyIpAddress = testSocket.GetMyIP
	testSocket.Close
	#end if
	settings.Initialize
	settings.LoadSettings
	ServerIP = modEposApp.SERVER_FIXED_IP
	
	server.Initialize(settings.serverApiUrl)
	
	DataBase.Initialize
	customerOrderInfo.Initialize
	myData.Initialize
	
	selectedCentreLocationRec.Initialize
	
	customerInfoAvailable = myData.load ' Load customer information and set flag accordingly.
	currentLocation.Initialize2(0, 0)
	currentPurchaseOrder = 100 ' Get purchase order numbers moving
	connect.Initialize ' Initialise the connection checking.
	CallSubDelayed(FirebaseMessaging, "SubscribeToTopics")	'Added for Firebase
	
	Log("TEST")
	
End Sub

Sub Service_Start(StartingIntent As Intent)
	' Currently nothing
End Sub

' This event will be raised when the user removes the app from the recent apps list.
Sub Service_TaskRemoved
	If settings.webOnlyComms = False Then
		lDisconnect ' Is this the best way to send a disconnect message?
		NotificationStatus.Cancel(modEposApp.NOTIFY_STATUS_ID) ' Cancel any outstanding status notifications
		NotificationMessage.Cancel(modEposApp.NOTIFY_MESSAGE_ID) ' Cancel any outstanding message notifications
	End If

	lStopAntiSleepPhoneModes
	
	' HACK to try to prevent the process continuing to run after being closed
	Sleep(1000) ' Must pause, otherwise the application will restart (probably required to allow StopForeground to take effect)
	ExitApplication ' Kill the application (TODO - need to find a better way to close - the OS should control the closing)
End Sub

Sub Application_Error(Error As Exception, StackTrace As String) As Boolean
'	lAppendToExtLog(ERROR_LIST_FILENAME, "An unhandled exception occurred: " & CRLF & StackTrace) ' Log the exception
	LogFile.LogReport(ERROR_LIST_FILENAME, "An unhandled exception occurred: " & CRLF & StackTrace) ' Log the exception
	' Allow the exception to continue as usual (TODO - should this do a specific action instead? e.g. always close the app)
	Return True ' Returns true to allow the OS default exceptions handler to handle uncaught exceptions.
End Sub

Sub Service_Destroy
	lStopAntiSleepPhoneModes ' Included here as belt-and-braces: this should already have happened in Service_TaskRemoved()
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the NewData event of the asynchronous streams (comms socket) object.
Private Sub AStreams_NewData(Buffer() As Byte)
	disconnectCounter = 0 ' Any message received from the Server resets the disconnect counter
	
	Dim tempResponse As String = BytesToString(Buffer, 0, Buffer.Length, "UTF8")
	inputStrg = inputStrg & tempResponse
	connect.RetriggerServerCheck
	
	If tempResponse.Contains(EOF_STRING) Then
		
		' This HACK throws out anything found in the buffer after the first complete message,
		' but it's not a good solution as latter messages will disappear without trace.
		inputStrg = lTruncateCommsBuffer(inputStrg) ' TODO - Need to handle multiple messages in the buffer better
		
		inputStrg = inputStrg.Replace(HEADER_STRING, "").Replace(EOF_STRING, "")
		pProcessInputStrg(inputStrg)
		inputStrg = "" ' Reset the comms input object
	End If
End Sub

' Handles the Terminated event (socket closed from other end) of the asynchronous streams (comms socket) object.
Private Sub AStreams_Terminated()
	' TODO - should something happen if the socket connection is broken from the Server end?
'	Dim i As Int = 1 ' Dummy code to insert breakpoint if required.
End Sub

' Handles the Connected event of the socket client.
Private Sub Client_Connected(ConnectedSuccessfully As Boolean)
	If reconnectEnabled = False Then ' Normal connect
		reconnectFailed = False
#if INCLUDE_SOCKET_CODE
		Astreams.Initialize(CltSock.InputStream,CltSock.OutputStream, "AStreams")
#end if
		lSendOpenTab
	Else ' Reconnection enabled.
		If ConnectedSuccessfully Then
			reconnectFailed = False
#if INCLUDE_SOCKET_CODE
			Astreams.Initialize(CltSock.InputStream,CltSock.OutputStream, "AStreams")
#end if
			Dim msg As String = modEposApp.EPOS_OPENTAB_RECONNECT & BuildEposCustomerDetailsXml
			pSendMessage(msg)
		Else ' Unsuccessful reconnect attempt
			reconnectFailed = True
		End If
		reconnectEnabled = False ' Always reset the reconnectEnabled flag.
	End If
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Builds a clsEposCustomerDetails XML string 
public Sub BuildEposCustomerDetailsXml As String
	'TODO new function needs fully testing.
	Log("starter.BuildEposCustomeDetailsXml needs TESTING")
	Dim tmpCustomerDetails As clsEposCustomerDetails : tmpCustomerDetails.initialize
	tmpCustomerDetails.acceptCards = myData.centre.acceptCards
	tmpCustomerDetails.address = myData.customer.address
	tmpCustomerDetails.authorized = True	'TODO need to check how this is handle currently always true (it currently used to confirm messages).
	tmpCustomerDetails.cardAccountEnabled = myData.customer.cardAccountEnabled
	tmpCustomerDetails.centreId = myData.centre.centreId
	tmpCustomerDetails.customerId = myData.customer.customerId
	tmpCustomerDetails.email = myData.customer.email
	tmpCustomerDetails.name = myData.customer.name
	tmpCustomerDetails.nickName = myData.customer.nickName
	tmpCustomerDetails.publishedKey = myData.centre.publishedKey
	tmpCustomerDetails.rev = myData.customer.rev
	Return tmpCustomerDetails.XmlSerialize
End Sub

' Down image from Server and store in iv.
' If Ok returns true (else a default image return) 
Public Sub DownloadImage(imageName As String, iv As ImageView) As ResumableSub
	Dim job As HttpJob
	Dim downloadOk As Boolean = False
	job.Initialize("", Me) 'note that the name parameter is no longer needed.
	Dim fullPath As String = server.serverUrlPath & modEposWeb.WEB_DIR_IMG & "/" & imageName
	job.Download(fullPath)
	Wait For JobDone(job As HttpJob)
	If job.Success Then
		iv.Bitmap = job.GetBitmap
		downloadOk = True
	Else
		iv.Bitmap = LoadBitmap(File.DirAssets, "ImageNotAvailableSmall.png")
	End If
	job.Release
	Return downloadOk
End Sub

' Write a report to the specified log file.
Public Sub LogReport(logFileName As String, logText As String)
	If LogFile.isInitialized = False Then	' Bit of protection just in case it is called before Service_Create() is complete
		LogFile.Initialize
	End If
	LogFile.LogReport(logFileName, logText)
End Sub


' Attempts to connect Server 
Public Sub pConnectToServer
	If settings.webOnlyComms Then
		lSendOpenTab
	Else
#if INCLUDE_SOCKET_CODE
		CltSock.Initialize("Client") ' Connect to server as a client
		CltSock.Connect(ServerIP, modEposApp.TCP_PORT_NUMBER, (settings.connectionTimeout * 1000))
#end if
	End If
End Sub

' Disconnects the socket connection to the Server.
Public Sub pDisconnectFromServer
	lDisconnect
End Sub

' Adds one to the number of timeouts that have occurred since last successful transmission, and if it
' then matches the disconnection threshold, triggers the app to revert to disconnected state.
Public Sub pIncrementDisconnectCounter
	disconnectCounter = disconnectCounter + 1
	If disconnectCounter = DISCONNECT_THRESHOLD Then
#if INCLUDE_SOCKET_CODE
		Astreams.Close ' End the message stream connection
		CltSock.Close ' Kill the socket
#end if
		IsConnected = False ' No longer connected
		lStopAntiSleepPhoneModes ' Stop the potentially battery-draining anti-sleep measures
		connect.StopServerChecking ' Stop the regular server pings (as they will cause reconnection)
		DisconnectedCloseActivities = True
	End If
End Sub

' Processes a input communications string.
public Sub pProcessInputStrg(inputCommsStrg As String)
	Try ' Try/Catch added here to investigate crash when receiving a message after being asleep for some time
		If inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_REQUEST) Then
			lHandleCustomerDetailsMsg(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_CONFIRM) Then
			lHandleOpenTabConfirm(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_RECONNECT) Then
			connect.ReconnectSuccess
			lSendQueuedMsgAfterReconnect
		Else If inputCommsStrg.StartsWith(modEposApp.EPOS_DISCONNECT) Then
			lDisconnectedByServer(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_SYNC_DATA) Then
			lHandleSyncDataResponse(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_ACKN) Then
			CallSubDelayed2(aPlaceOrder, "pHandleOrderAcknResponse", inputCommsStrg)
		Else If inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_QUERY) Then
'			CallSubDelayed2(aShowOrderStatusList, "pHandleOrderInfo", inputCommsStrg)
			CallSubDelayed2(aHome, "pHandleOrderInfo", inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_SEND) Then
			CallSubDelayed2(aPlaceOrder, "pHandleOrderResponse", inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDERSTATUSLIST) Then
			Log("Starter.pProcessInputStrg call lHandleStatusListMsg()")
			lHandleStatusListMsg(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDERSTATUS) Then
			lNotifyStatus(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_START) Then
'			CallSubDelayed2(aTaskSelect, "pHandleOrderStart", inputCommsStrg)
			CallSubDelayed2(aHome, "pHandleOrderStart", inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_PING) Then
			lPingHandle(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_MESSAGE) Then
			lNotifyMessage(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_BALANCECHECK) Then
			lHandleBalanceCheckMsg(inputCommsStrg)
'		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ITEMIZED_BILL) Then
'			CallSubDelayed2(aShowBill, "pHandleGetBillByItemResponse", inputCommsStrg)
		Else If inputCommsStrg.StartsWith(modEposApp.EPOS_UPDATE_CUSTOMER) Then
			lHandleUpdateCustomer(inputCommsStrg)
		else if inputCommsStrg.StartsWith(modEposApp.EPOS_PAYMENT) Then
			lHandlePaymentResponse(inputCommsStrg)
		else if inputCommsStrg.StartsWith(modEposApp.EPOS_GET_LOCATION) Then
			HandleGetLocationRequest
		End If
	Catch
		Log("Comms string:" & inputCommsStrg)
		LogFile.LogReport(ERROR_COMMS_FILENAME, "A comms error occurred. Exception type:" & LastException.Message & _
								CRLF & CRLF & "Current contents of the comms buffer:" & CRLF & inputCommsStrg)
		ToastMessageShow("An error occurred while communicating with the server. Please try again.", True)
	End Try
End Sub

' Sends the specified message through the socket to the Server.
Public Sub pSendMessage(msg As String) As ResumableSub
	Dim statusCode As Int = 200
	If settings.webOnlyComms = False Then
		Dim sNewLine As String
		sNewLine = HEADER_STRING & msg & EOF_STRING ' & CRLF
#if INCLUDE_SOCKET_CODE		
		Dim buffer() As Byte
		buffer = sNewLine.GetBytes("UTF8")
		Astreams.Write(buffer)
#end if
	Else
	
		Dim job As HttpJob : job.Initialize("NewCustomer", Me)
		' Smart string literals see https://www.b4x.com/android/forum/threads/b4x-smart-string-literal.50135/
		' $"xml{msg}"$	' XML - Escapes the five XML entities (", ', <, >, &): - I Think!
		Dim newMsg As String
		newMsg = msg.Replace(Chr(34) , "\""")
		Dim tempMsg As String = """" & newMsg & """" '  Temp 4 quotes in row are required to put a quote around the message text.
		Dim centreIdStrg As String = NumberFormat2(myData.centre.centreId, 3, 0, 0, False)	' Ensures large numbers converted correcly
'		Dim urlString As String = modEposWeb.URL_COMMS_API & "?" & modEposWeb.API_SEND_MSG & "=0" & "&" & _
'											modEposWeb.API_CENTRE_ID  & "=" & centreIdStrg & "&"  & _
'											modEposWeb.API_CUSTOMER_ID & "=" & myData.customer.customerIdStr
		Dim urlString As String = server.URL_COMMS_API & "?" & modEposWeb.API_SEND_MSG & "=0" & "&" & _
											modEposWeb.API_CENTRE_ID  & "=" & centreIdStrg & "&"  & _
											modEposWeb.API_CUSTOMER_ID & "=" & myData.customer.customerIdStr
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

' Attempts to send the specified message to the Server, but first checks if an automatic reconnection is necessary.
' If it is, then the message is queued while the reconnection is invoked; otherwise, the message is sent normally. 
Public Sub pSendMessageAndCheckReconnect(msgToSend As String) As ResumableSub
	Dim statusCodeResult As Int = 200
	If reconnectFailed Then
		reconnectQueuedMsg = msgToSend
		reconnectEnabled = True ' Start a reconnect
		pConnectToServer
	Else
		'	pSendMessage(msgToSend)
		Wait For (pSendMessage(msgToSend)) complete(statusCode As Int)
		statusCodeResult = statusCode
	End If
	Return statusCodeResult
End Sub

' Sends a open tab request to the Server
Public Sub pSendOpenTabRequest()
	lSendOpenTab
End Sub

' Sets the value of whether Test mode is active, and saves the value for future ease.
' The saved file will also contain the current Server IP address, appended after a comma.
Public Sub pSetTestMode(testModeOn As Boolean)
	Dim saveStr As String = testModeOn & "," & ServerIP
	File.WriteString(File.DirInternal, PREV_TESTMODE_FILENAME, saveStr)
End Sub

' Returns the specified comms response string with everything before the actual XML removed (e.g. command code and XML headers).
' Necessary as the B4i XML deserialiser can't process the standard headers prepended to XML documents (for some reason).
Public Sub TrimToXmlOnly(inputStr As String) As String
	Return inputStr.SubString(inputStr.IndexOf2("<", inputStr.IndexOf("<") + 1))
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines



'' Appends the specified text to the specified externally-accessible log file (creating it if it doesn't already exist).
'' The log files can be found in the phone's Internal Storage > Android > data > arena.Epos > files > eposLogs directory.
'Private Sub lAppendToExtLog(fileName As String, textToAppend As String)
'	Dim logStrToSave As String = ""	' Get the previous text from the existing file so that it won't be overwritten
'	If File.Exists(externalFolder, fileName) Then logStrToSave = File.ReadString(externalFolder, fileName)
'	If logStrToSave <> "" Then logStrToSave = logStrToSave & CRLF & CRLF & "--------------------------------" & CRLF & CRLF
'	DateTime.DateFormat = "HH:mm:ss yyyy/MM/dd"
'	Dim timeDateStr As String = DateTime.Date(DateTime.Now).Replace(" ", " , on ")
'	logStrToSave = logStrToSave & "Log report for " & Application.LabelName & " v" & Application.VersionName & " running on a  " & _
'					"phone using Android SDK " & phoneDetails.SdkVersion & CRLF & "Logged at " & timeDateStr & CRLF & textToAppend
'	File.WriteString(externalFolder, fileName, logStrToSave) ' Save the whole text to the file
'	Log("The following text was saved to the " & fileName & " log file:" & CRLF & textToAppend) ' For test purposes
'End Sub

' Sends disconnect command to Server.
Private Sub lDisconnect
	Dim msg As String = modEposApp.EPOS_DISCONNECT & modEposWeb.ConvertToString(myData.customer.customerId)
	If settings.webOnlyComms Then
		pSendMessage(msg) ' Attempt to send the disconnect message
	Else
#if INCLUDE_SOCKET_CODE		
		If CltSock.Connected Then
			pSendMessage(msg) ' Attempt to send the disconnect message
			Sleep(2000) ' Just wait two seconds and always disconnect, regardless of ability to send the above message
			Astreams.Close()
			CltSock.Close()
		End If
#end if				
	End If
	IsConnected = False
	lStopAntiSleepPhoneModes ' Stop the potentially battery-draining anti-sleep measures
	connect.StopServerChecking ' Stop the regular server pings (as they will cause reconnection)
'	CallSubDelayed(Connection, "pDisconnectedSuccessfully")
End Sub

' Process disconnect command from server
Private Sub lDisconnectedByServer(msg As String)
	Dim apiCustomerId As Int = msg.SubString(modEposApp.EPOS_DISCONNECT.Length)
	If apiCustomerId = modEposWeb.BuildApiCustomerId() Then ' Correct command for this customer?
		IsConnected = False
		lStopAntiSleepPhoneModes ' Stop the potentially battery-draining anti-sleep measures
		connect.StopServerChecking ' Stop the regular server pings (as they will cause reconnection)
		DisconnectedCloseActivities = True
'		CallSubDelayed(Connection, "pDisconnectedByServer")
	End If
End Sub

' Deserialises the specified Balance Check XML string, processes it, and replies to the Server.
Private Sub lHandleBalanceCheckMsg(balanceCheckStr As String)
	Dim xmlStr As String = balanceCheckStr.SubString(modEposApp.EPOS_BALANCECHECK.Length)
	Dim balanceCheckObj As clsEposBalanceCheckRec : balanceCheckObj.initialize
	balanceCheckObj = balanceCheckObj.XmlDeserialize(xmlStr)
	balanceCheckObj.phoneTotal = srvPhoneTotal.phoneTotal
	balanceCheckObj.centreId = myData.centre.centreId
	balanceCheckObj.customerId = myData.customer.customerId
	Dim msg As String = modEposApp.EPOS_BALANCECHECK & balanceCheckObj.XmlSerialize(balanceCheckObj)
	If balanceCheckObj.zeroTotals Then
		CallSub(srvPhoneTotal, "pZeroPhoneTotal")
	End If
	pSendMessage(msg)
End Sub

' Deserialises the specified Customer Details XML string, and updates the global .CustomerDetails structure
Private Sub lHandleCustomerDetailsMsg(openTabCmdResponseStr As String)
	' TODO Duplicated code see connection.pConfirmCustomerDetails()
	Dim xmlStr As String = openTabCmdResponseStr.SubString(modEposApp.EPOS_OPENTAB_REQUEST.Length)
	Dim customerDetailsObj As clsEposCustomerDetails : customerDetailsObj.Initialize
	customerDetailsObj = customerDetailsObj.XmlDeserialize(xmlStr)
	Dim centreSignonOk As Boolean = False
	If customerDetailsObj.customerId <> "0" Then ' Customer ID accepted?
		DisconnectedCloseActivities = False
		IsConnected = True
		lStartAntiSleepPhoneModes ' Now it's connected, prevent the app from sleeping so that all messages get through
		connect.StartServerChecking ' Start the regular polling for server only when connected
		' TODO Test code for EPOS_OPENTAB_REQUEST response
		Log("TODO - Code needs testing starter.lHandleCustomerDetailsMsg()")
		myData.centre.acceptCards = customerDetailsObj.acceptCards
		myData.customer.address = customerDetailsObj.address
		myData.customer.cardAccountEnabled = customerDetailsObj.cardAccountEnabled
		myData.centre.centreId = customerDetailsObj.centreId
		myData.customer.customerId = customerDetailsObj.customerId
		myData.customer.email = customerDetailsObj.email
		myData.customer.name = customerDetailsObj.name
		myData.customer.nickName = customerDetailsObj.nickName
		myData.centre.publishedKey = customerDetailsObj.publishedKey
		myData.customer.rev = customerDetailsObj.rev
		centreSignonOk = True
	End If
			
	CallSubDelayed2(ValidateCentreSelection2, "ConnectToServerResponse", centreSignonOk)
End Sub

' Handles EPOS_GET_LOCATION request and sends a response.
Private Sub HandleGetLocationRequest()
	Dim locationRec As clsEposLocationRec : locationRec.Initialize
	locationRec.ID = myData.customer.customerId
	locationRec.location.latitude = currentLocation.Latitude
	locationRec.location.longitude = currentLocation.Longitude
	Dim msg As String = modEposApp.EPOS_GET_LOCATION & locationRec.XmlSerialize
	pSendMessage(msg)
End Sub

' Handle the Open TAB confirmation 
private Sub lHandleOpenTabConfirm(openTabConfirmResponse As String)
	' TODO Duplicated code see connection.pConfirmCustomerDetails()
	Dim xmlStr As String = openTabConfirmResponse.SubString(modEposApp.EPOS_OPENTAB_CONFIRM.Length)
	Dim customerDetailsObj As clsEposCustomerDetails : customerDetailsObj.Initialize
	customerDetailsObj = customerDetailsObj.XmlDeserialize(xmlStr)
	If customerDetailsObj.authorized Then
		If customerDetailsObj.customerId = myData.customer.customerId Then ' Customer ID correct?
			If customerDetailsObj.centreId = myData.centre.centreId Then ' Centre ID correct?
				myData.centre.signedOn = True ' Flag signed on to this centre.
				CallSubDelayed(ValidateCentreSelection2, "OpenTabConfirmResponse")
			End If
		End If
	End If
End Sub

' Handle payment response string.
private Sub	lHandlePaymentResponse(paymentResponse As String)
#if B4A
	Dim xmlStr As String = paymentResponse.SubString(modEposApp.EPOS_PAYMENT.Length)
#else 'B4I
	Dim xmlStr As String = TrimToXmlOnly(paymentResponse)
#end if
	Dim paymentInfo As clsEposCustomerPayment : paymentInfo.Initialize
	paymentInfo = paymentInfo.XmlDeserialize(xmlStr)
	#if B4A
	CallSubDelayed2( aCardEntry, "ReportPaymentStatus", paymentInfo)
#else ' B4I
'	xShowBill.ReportPaymentStatus(paymentInfo)
	xCardEntry.ReportPaymentStatus(paymentInfo)
#end if
End Sub

' Handles the Server's response to the Get Status List command.
Private Sub lHandleStatusListMsg(statusListMsg As String)
	If svcTestSequence.TestSeqRunning Then ' Original command was a test message
		CallSub(svcTestSequence, "pReceivedResponse")
	Else ' Original command was a genuine "Get Status List" message invoked by the user
'		CallSubDelayed2(aShowOrderStatusList, "pHandleOrderStatusList", statusListMsg)
		CallSubDelayed2(aHome, "pHandleOrderStatusList", statusListMsg)
	End If
End Sub

' Handles the Server's response to the menu (sync data).
Private Sub lHandleSyncDataResponse(syncDataResponse As String)
	CallSubDelayed2(aSyncDatabase, "pHandleSyncDbReponse", syncDataResponse)
End Sub

' Deserialises the specified Update Customer XML string, and uses it to update the locally-stored customer info.
Private Sub lHandleUpdateCustomer(updateCustomerMsg As String)
	Dim xmlStr As String = updateCustomerMsg.SubString(modEposApp.EPOS_UPDATE_CUSTOMER.Length)
	Dim newCustomerInfo As clsEposCustomerInfo : newCustomerInfo.Initialize
	newCustomerInfo.XmlDeserialise(xmlStr)
	'TODO - Needs fully testing
	' Take fields from clsEposeCustomerInfo to update myData (note: customerId, email and house number are skipped)
	myData.customer.address = newCustomerInfo.address
	myData.customer.name = newCustomerInfo.name
	myData.customer.nickName = newCustomerInfo.nickName
	SendCustomerUpdateResponse(newCustomerInfo)
End Sub

' Deserialises the specified Message To Customer XML string, and displays it either on the Task Select form or as a notification.
Private Sub lNotifyMessage(inStrg As String)
	' Deserialise the XML string argument
	Dim xmlStr As String = inStrg.SubString(modEposApp.EPOS_MESSAGE.Length) ' TODO - check if the XML string is valid?
	Dim msgObj As clsEposMessageRec : msgObj.Initialize
	msgObj = msgObj.XmlDeserialize(xmlStr)' TODO - need to determine if the deserialisation was successful?
	Dim messageStr As String = "Received at " & DateTime.Time(DateTime.Now) & CRLF & _
	msgObj.headingTop & CRLF & CRLF & msgObj.headingBottom & CRLF & CRLF & msgObj.message & CRLF
	PrevMessage = messageStr
	If msgObj.messageId <> 0 Then	' Send message delivery confirmation?
		SendDeliveryMessage(msgObj.messageId)
	End If
	ShowMessageNotification(msgObj.headingTop)
End Sub

' Deserialises the specified Message To Customer XML string, and if the user needs to be notified, it will be displayed either
' on the Task Select form or as a notification. Otherwise, the order status form will be updated (if it is active).
Private Sub lNotifyStatus(inStrg As String)
	' Deserialise the XML string argument
	Dim xmlStr As String = inStrg.SubString(modEposApp.EPOS_ORDERSTATUS.Length) ' TODO - check if the XML string is valid?
	Dim responseObj As clsEposOrderStatus :	responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr)
	If responseObj.status <> modConvert.statusUnknown Then ' XML has been deserialised OK
		If responseObj.messageId <> 0 Then	' Send message delivery confirmation?
			SendDeliveryMessage(responseObj.messageId)
		End If
		If responseObj.status = modConvert.statusReady And responseObj.deliverToTable = False Then
			Dim tempStatus(2) As String = Array As String("Order #" & responseObj.orderId, "Your order is now ready. " & _
			"Please go to the counter to collect it.")
			PrevStatusRec = responseObj
			PrevStatus = tempStatus ' Always overwrite status storage with the most recent status
			ShowStatusNotification
		else if responseObj.status = modConvert.statusCollected And responseObj.deliverToTable = True Then ' Delivered to table?
			Dim tempStatus(2) As String = Array As String("Order #" & responseObj.orderId, "Your order has been delivered.")
			PrevStatusRec = responseObj
			PrevStatus = tempStatus ' Always overwrite status storage with the most recent status
			ShowStatusNotification
		Else if IsPaused(aHome) = False Then ' Other status change?
			CallSubDelayed2(aHome, "pUpdateOrderStatus", responseObj)
		End If
	Else ' XML deserialisation failed (or contains Unknown status, which is just as bad)
		'	lAppendToExtLog(ERROR_LIST_FILENAME, "Received bad status message:" & CRLF & inStrg) ' Log the error
		LogFile.LogReport(ERROR_LIST_FILENAME, "Received bad status message:" & CRLF & inStrg) ' Log the error
	End If
End Sub

' Handles the response to a server ping.
Private Sub lPingHandle(txtPing As String)
	' TODO Need to check if customer number is correct
	Dim rxMsg As String
	rxMsg = txtPing.SubString(modEposApp.EPOS_PING.Length)
	Dim fields() As String
	fields = Regex.Split(",", rxMsg)
	If fields.Length = 2 Then ' ping (response required)?
		DateTime.DateFormat = "HH:mm:ss"
		Dim timeStamp As String = "Time:" & DateTime.Date(DateTime.Now)
		Dim txMsg As String = modEposApp.EPOS_PING & _
								 modEposWeb.ConvertToString(myData.customer.customerId) & _
								 "," & connect.GetWifiSignalStrength  & "%" & _
								 "," & timeStamp
		pSendMessage(txMsg)
	Else ' response ping (no resposne expected)
		connect.ServerCheckSuccess
	End If
End Sub

' Send Delivery message
Private Sub SendDeliveryMessage(messageId As Int)
	Dim msg As String = modEposApp.EPOS_DELIVERY & _
						 "," & modEposWeb.ConvertToString(myData.customer.customerId) & _
						 "," & modEposWeb.ConvertToString(messageId)
	pSendMessage(msg)
End Sub

' Sends an open tab message
Private Sub lSendOpenTab
	Dim msg As String = modEposApp.EPOS_OPENTAB_REQUEST & "," & MyIpAddress & _
						 "," & modEposWeb.ConvertToString(myData.customer.customerId) & _
						 "," & myData.customer.BuildUniqueCustomerInfoString & _
						 "," & myData.customer.rev
	pSendMessage(msg)
End Sub

' Sends the message which had been queued to be sent after automatically reconnecting (if any).
Private Sub lSendQueuedMsgAfterReconnect
	If reconnectQueuedMsg <> "" Then
		pSendMessage(reconnectQueuedMsg)
		reconnectQueuedMsg = ""
	End If
End Sub

' Sends a response to the customer update command
Private Sub SendCustomerUpdateResponse(customerInfoRec As clsEposCustomerInfo)
	Dim msg As String = modEposApp.EPOS_MESSAGE & customerInfoRec.XmlSerialize(customerInfoRec)
	pSendMessage(msg)
End Sub

' Shows a message notification
Private Sub ShowMessageNotification(headingTop As String)
	' Show the message directly, if possible, otherwise raise a notification
'	If IsPaused(aTaskSelect) = False Then ' Task Select activity is active - show the message directly
'		CallSubDelayed2(aTaskSelect, "ShowMessageNotificationMsgBox", True)
'	else if IsPaused(aShowBill) = False Then
'		CallSubDelayed2(aShowBill, "ShowMessageNotificationMsgBox", True)
'	else if IsPaused(aHome) = False Then
	If IsPaused(aHome) = False Then
		CallSubDelayed2(aHome, "ShowMessageNotificationMsgBox", True)
	else if IsPaused(aPlaceOrder) = False Then
		CallSubDelayed2(aPlaceOrder, "ShowMessageNotificationMsgBox", True)
	else if IsPaused(aSelectItem) = False Then
		CallSubDelayed2(aSelectItem, "ShowMessageNotificationMsgBox", True)
	Else ' Task Select activity is not currently active - raise a notification instead
		Dim titleContentTag(3) As String = Array As String("You have a new message", headingTop, modEposApp.NOTIFY_MESSAGE_TAG)
		NotificationMessage = CallSub3(srvNotification, "pSimple_Notification", titleContentTag, modEposApp.NOTIFY_MESSAGE_ID)
	End If
End Sub

' Shows a status notification.
Private Sub ShowStatusNotification
	' Either show the message directly or raise a notification as required
'	If IsPaused(aTaskSelect) = False Then ' Task Select activity is active - show the message directly
'		CallSubDelayed2(aTaskSelect, "ShowStatusNotificationMsgBox", True)
'	else if IsPaused(aShowBill) = False Then
'		CallSubDelayed2(aShowBill, "ShowStatusNotificationMsgBox", True)
'	else if IsPaused(aHome) = False Then
	If IsPaused(aHome) = False Then
		CallSubDelayed2(aHome, "ShowStatusNotificationMsgBox", True)
	else if IsPaused(aPlaceOrder) = False Then
		CallSubDelayed2(aPlaceOrder, "ShowStatusNotificationMsgBox", True)
	else if IsPaused(aSelectItem) = False Then
		CallSubDelayed2(aSelectItem, "ShowStatusNotificationMsgBox", True)
	Else ' Task Select activity is not currently active - raise a notification instead
		Dim titleContentTag(3) As String = Array As String(PrevStatus(0), PrevStatus(1), modEposApp.NOTIFY_STATUS_TAG)
		NotificationStatus = CallSub3(srvNotification, "pSimple_Notification", titleContentTag, modEposApp.NOTIFY_STATUS_ID)
	End If
End Sub

' Start the phone modes which prevent the app being 'dozed' by the Android OS.
' Note that lStopAntiSleepPhoneModes() must then always be called before the app closes.
Private Sub lStartAntiSleepPhoneModes
	phoneLock.PartialLock ' Prevent the CPU from sleeping (may be ineffective on newer phones)
	mlWifiObj.holdWifiOn ' Prevent the wifi from turning off
	Dim foregroundNotification As Notification ' Set up the foreground mode notification to be as unobtrusive as possible
	foregroundNotification.Initialize2(NotificationMessage.IMPORTANCE_MIN) ' Prevent sound, vibrate, etc
	foregroundNotification.Icon = "" ' This is a hack to prevent it appearing in the notification bar (on some phones),
	' see - https://www.b4x.com/android/forum/threads/a-way-to-suppress-notification-for-service-startforeground.34658/
	foregroundNotification.OnGoingEvent = False ' Can prevent it appearing in the notification bar (on some phones)
	foregroundNotification.SetInfo("", "", "")
	Service.StartForeground(FOREGROUND_NOTIFICATION_ID, foregroundNotification)
End Sub

' End the phone modes phone modes which prevent the app being 'dozed' by the Android OS.
' Must always be called before the app closes if lStartAntiSleepPhoneModes() has ever been called.
Private Sub lStopAntiSleepPhoneModes
	mlWifiObj.releaseWifiOn
	phoneLock.ReleasePartialLock
	Service.StopForeground(FOREGROUND_NOTIFICATION_ID)
End Sub

' Returns the specified comms buffer contents truncated to the first complete message.
' If any text exists after the first end-of-file marker, it will be logged to file as a comms error.
Private Sub lTruncateCommsBuffer(inputStr As String) As String
	Dim firstMsgEndIndex As Int = inputStr.IndexOf(EOF_STRING) + EOF_STRING.Length
	Dim firstCompleteMsgStr As String = inputStr.SubString2(0, firstMsgEndIndex)
	If inputStr.Length > firstMsgEndIndex Then ' Message has been truncated - log the buffer data
'		lAppendToExtLog(ERROR_COMMS_FILENAME, "The comms buffer was truncated, from its full contents:" & CRLF & inputStr)
		LogFile.LogReport(ERROR_COMMS_FILENAME, "The comms buffer was truncated, from its full contents:" & CRLF & inputStr)
	End If
	Return firstCompleteMsgStr
End Sub

#End Region  Local Subroutines
