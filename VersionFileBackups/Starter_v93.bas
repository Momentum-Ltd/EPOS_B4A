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
	' Release...: 93
	' Date......: 06/02/21
	'
	' History
	'	For versions 1-15 see Starter_v19.
	'       versions 16-45 see Starter_v48.
	'	    versions 46-54 see Starter_v57.
	'       versions 55-64 see Starter_v65.
	'		versions 65-71 see Starter_v73.
	'       versions 72-78 see Starter_v79.
	' 		versions 79-86 see Starter_v87.
	' 			  			    
	' Date......: 14/11/20
	' Release...: 88
	' Overview..: Investigation into calling activities.
	' Amendee...: D Morris
	' Details...:  Mod: Comments added statements calling activities "Calls an Activity".
	'			   Mod: HandleStatusListMsg() now only shows status list if the Home activity is visiable.
	'		
	' Date......: 28/11/20
	' Release...: 89
	' Overview..: Issue: #0567 Download/sync menu now handled by the Home activity.
	' Amendee...: D Morris
	' Details...: Mod: HandleSyncDataResponse() now calls Home to handle response.
	' 			  			    
	' Date......: 03/01/21
	' Release...: 90
	' Overview..: Handling GPS coordinates changed. 
	' Amendee...: D Morris.
	' Details...: Mod: currentLocation removed.
	'			  New: latestLocation.
	'			  Mod: Service_Create(), HandleGetLocationRequest().
	'		
	' Date......: 24/01/21
	' Release...: 91
	' Overview..: Bugfix: #0562 - Payment with Saved card shows Enter card as background fixed. 
	' Amendee...: D Morris
	' Details...: Mod: HandlePaymentResponse() calls aHome to handle payment.
	'			  Mod: All 'p' and 'l' Prefixes dropped for calls to aHome and aPlaceOrder activities.
	' 			  			    
	' Date......: 30/01/21
	' Release...: 92
	' Overview..: Support for rename modules.
	' Amendee...: D Morris
	' Details...: Mod: HandleOpenTabConfirm(), HandleCustomerDetailsMsg() new name for call modules.
	' 			  			    
	' Date......: 06/02/21
	' Release...: 93
	' Overview..: Maintenance release
	' Amendee...: D Morris
	' Details...:  Mod: All 'p' and 'l' Prefixes dropped.
	'			   Mod: Old commented code removed.
	' 			  			    
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
	' NOTES:
	'	1. Review using CallSub() replacing with CallSubDelayed() in many places.
	'   2. Reference to Astream and CltSocket removed by conditional compiler Symbol "INCLUDE_SOCKET_CODE".
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
'	Public comms As clsCommunications					' Handles Communications.
	
	Public connect As clsConnect 						' Object which handles TCP socket operations.
	Public currentPurchaseOrder As Int 					' The current order number.
	Public customerInfoAvailable As Boolean = False 	' Whether the customer information is currently available.
	Public customerOrderInfo As clsEposCustomerOrder 	' The info of the most recent customer's order.
	Public menuRevision As Int							' Menu revision number
	Public DataBase As clsDataBaseTables 				' Database used to store goods and order information.
	Public DisconnectedCloseActivities As Boolean 		' Whether all activities (other than Connection) should be ended due to a disconnect command.
	Public IsConnected As Boolean 						' Whether the device is currently connected to the Server.
	Public latestLocation As clsLocationCoordinates		' Latest available location (Note: only updated whilst Location device is active)	
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

'	comms.Initialize
	
	settings.Initialize
	settings.LoadSettings
	ServerIP = modEposApp.SERVER_FIXED_IP
	server.Initialize(settings.serverApiUrl)
	DataBase.Initialize
	customerOrderInfo.Initialize
	myData.Initialize
	selectedCentreLocationRec.Initialize
	customerInfoAvailable = myData.load ' Load customer information and set flag accordingly.
	latestLocation.Initialize
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
		Disconnect ' Is this the best way to send a disconnect message?
		NotificationStatus.Cancel(modEposApp.NOTIFY_STATUS_ID) ' Cancel any outstanding status notifications
		NotificationMessage.Cancel(modEposApp.NOTIFY_MESSAGE_ID) ' Cancel any outstanding message notifications
	End If
	StopAntiSleepPhoneModes
	
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
	StopAntiSleepPhoneModes ' Included here as belt-and-braces: this should already have happened in Service_TaskRemoved()
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
		inputStrg = TruncateCommsBuffer(inputStrg) ' TODO - Need to handle multiple messages in the buffer better
		inputStrg = inputStrg.Replace(HEADER_STRING, "").Replace(EOF_STRING, "")
		ProcessInputStrg(inputStrg)
		inputStrg = "" ' Reset the comms input object
	End If
End Sub

' Handles the Terminated event (socket closed from other end) of the asynchronous streams (comms socket) object.
Private Sub AStreams_Terminated()
	' TODO - should something happen if the socket connection is broken from the Server end?
End Sub

' Handles the Connected event of the socket client.
Private Sub Client_Connected(ConnectedSuccessfully As Boolean)
	If reconnectEnabled = False Then ' Normal connect
		reconnectFailed = False
#if INCLUDE_SOCKET_CODE
		Astreams.Initialize(CltSock.InputStream,CltSock.OutputStream, "AStreams")
#end if
		SendOpenTab
	Else ' Reconnection enabled.
		If ConnectedSuccessfully Then
			reconnectFailed = False
#if INCLUDE_SOCKET_CODE
			Astreams.Initialize(CltSock.InputStream,CltSock.OutputStream, "AStreams")
#end if
			Dim msg As String = modEposApp.EPOS_OPENTAB_RECONNECT & BuildEposCustomerDetailsXml
			SendMessage(msg)
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
' If Ok returns true (else a default image returned) 
Public Sub DownloadImage(imageName As String, iv As ImageView) As ResumableSub
	Dim job As HttpJob
	Dim downloadOk As Boolean = False
	job.Initialize("", Me) 'note that the name parameter is no longer needed.
	Dim fullPath As String = server.serverUrlPath & modEposWeb.WEB_DIR_IMG & "/" & imageName
	job.Download(fullPath)
	Wait For (job) JobDone(job As HttpJob) ' (job) is important - See https://www.b4x.com/etp.html?vimeography_gallery=1&vimeography_video=255570732
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
Public Sub ConnectToServer
	If settings.webOnlyComms Then
		SendOpenTab
	Else
#if INCLUDE_SOCKET_CODE
		CltSock.Initialize("Client") ' Connect to server as a client
		CltSock.Connect(ServerIP, modEposApp.TCP_PORT_NUMBER, (settings.connectionTimeout * 1000))
#end if
	End If
End Sub

' Disconnects the socket connection to the Server.
Public Sub DisconnectFromServer
	Disconnect
End Sub

' Adds one to the number of timeouts that have occurred since last successful transmission, and if it
' then matches the disconnection threshold, triggers the app to revert to disconnected state.
Public Sub IncrementDisconnectCounter
	disconnectCounter = disconnectCounter + 1
	If disconnectCounter = DISCONNECT_THRESHOLD Then
#if INCLUDE_SOCKET_CODE
		Astreams.Close ' End the message stream connection
		CltSock.Close ' Kill the socket
#end if
		IsConnected = False ' No longer connected
		StopAntiSleepPhoneModes ' Stop the potentially battery-draining anti-sleep measures
		connect.StopServerChecking ' Stop the regular server pings (as they will cause reconnection)
		DisconnectedCloseActivities = True
	End If
End Sub

' Processes a input communications string.
public Sub ProcessInputStrg(inputCommsStrg As String)
	Try ' Try/Catch added here to investigate crash when receiving a message after being asleep for some time
		If inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_REQUEST) Then
			HandleCustomerDetailsMsg(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_CONFIRM) Then
			HandleOpenTabConfirm(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_OPENTAB_RECONNECT) Then
			connect.ReconnectSuccess
			SendQueuedMsgAfterReconnect
		Else If inputCommsStrg.StartsWith(modEposApp.EPOS_DISCONNECT) Then
			DisconnectedByServer(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_SYNC_DATA) Then
			HandleSyncDataResponse(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_ACKN) Then
			CallSubDelayed2(aPlaceOrder, "HandleOrderAcknResponse", inputCommsStrg) ' Calls an Activity
		Else If inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_QUERY) Then
			CallSubDelayed2(aHome, "HandleOrderInfo", inputCommsStrg) ' Calls an Activity
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_SEND) Then
			CallSubDelayed2(aPlaceOrder, "HandleOrderResponse", inputCommsStrg) ' Calls an Activity
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDERSTATUSLIST) Then
			HandleStatusListMsg(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDERSTATUS) Then
			NotifyStatus(inputCommsStrg)
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_ORDER_START) Then
			CallSubDelayed2(aHome, "HandleOrderStart", inputCommsStrg) ' Calls an Activity
		Else if inputCommsStrg.StartsWith(modEposApp.EPOS_PING) Then
			PingHandle(inputCommsStrg)
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
		LogFile.LogReport(ERROR_COMMS_FILENAME, "A comms error occurred. Exception type:" & LastException.Message & _
								CRLF & CRLF & "Current contents of the comms buffer:" & CRLF & inputCommsStrg)
		ToastMessageShow("An error occurred while communicating with the server. Please try again.", True)
	End Try
End Sub

' Sends the specified message through the socket to the Server.
Public Sub SendMessage(msg As String) As ResumableSub
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
Public Sub SendMessageAndCheckReconnect(msgToSend As String) As ResumableSub
	Dim statusCodeResult As Int = 200
	If reconnectFailed Then
		reconnectQueuedMsg = msgToSend
		reconnectEnabled = True ' Start a reconnect
		ConnectToServer
	Else
		Wait For (SendMessage(msgToSend)) complete(statusCode As Int)
		statusCodeResult = statusCode
	End If
	Return statusCodeResult
End Sub

' Sends a open tab request to the Server
Public Sub SendOpenTabRequest()
	SendOpenTab
End Sub

' Sets the value of whether Test mode is active, and saves the value for future ease.
' The saved file will also contain the current Server IP address, appended after a comma.
Public Sub SetTestMode(testModeOn As Boolean)
	Dim saveStr As String = testModeOn & "," & ServerIP
	File.WriteString(File.DirInternal, PREV_TESTMODE_FILENAME, saveStr)
End Sub

' Start the phone modes which prevent the app being 'dozed' by the Android OS.
' Note that StopAntiSleepPhoneModes() must then always be called before the app closes.
Public Sub StartAntiSleepPhoneModes
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
Private Sub Disconnect
	Dim msg As String = modEposApp.EPOS_DISCONNECT & modEposWeb.ConvertToString(myData.customer.customerId)
	If settings.webOnlyComms Then
		SendMessage(msg) ' Attempt to send the disconnect message
	Else
#if INCLUDE_SOCKET_CODE		
		If CltSock.Connected Then
			SendMessage(msg) ' Attempt to send the disconnect message
			Sleep(2000) ' Just wait two seconds and always disconnect, regardless of ability to send the above message
			Astreams.Close()
			CltSock.Close()
		End If
#end if				
	End If
	IsConnected = False
	StopAntiSleepPhoneModes ' Stop the potentially battery-draining anti-sleep measures
	connect.StopServerChecking ' Stop the regular server pings (as they will cause reconnection)
'	CallSubDelayed(Connection, "pDisconnectedSuccessfully")
End Sub

' Process disconnect command from server
Private Sub DisconnectedByServer(msg As String)
	Dim apiCustomerId As Int = msg.SubString(modEposApp.EPOS_DISCONNECT.Length)
	If apiCustomerId = modEposWeb.BuildApiCustomerId() Then ' Correct command for this customer?
		IsConnected = False
		StopAntiSleepPhoneModes ' Stop the potentially battery-draining anti-sleep measures
		connect.StopServerChecking ' Stop the regular server pings (as they will cause reconnection)
		DisconnectedCloseActivities = True
	End If
End Sub

' Deserialises the specified Balance Check XML string, processes it, and replies to the Server.
Private Sub HandleBalanceCheckMsg(balanceCheckStr As String)
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
	SendMessage(msg)
End Sub

' Deserialises the specified Customer Details XML string, and updates the global .CustomerDetails structure
Private Sub HandleCustomerDetailsMsg(openTabCmdResponseStr As String)
	' TODO Duplicated code see connection.pConfirmCustomerDetails()
	Dim xmlStr As String = openTabCmdResponseStr.SubString(modEposApp.EPOS_OPENTAB_REQUEST.Length)
	Dim customerDetailsObj As clsEposCustomerDetails : customerDetailsObj.Initialize
	customerDetailsObj = customerDetailsObj.XmlDeserialize(xmlStr)
	Dim centreSignonOk As Boolean = False
	If customerDetailsObj.customerId <> "0" Then ' Customer ID accepted?
		DisconnectedCloseActivities = False
		IsConnected = True
		StartAntiSleepPhoneModes ' Now it's connected, prevent the app from sleeping so that all messages get through
		connect.StartServerChecking ' Start the regular polling for server only when connected
		' TODO Test code for EPOS_OPENTAB_REQUEST response
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
			
	CallSubDelayed2(aValidateCentreSelection2, "ConnectToServerResponse", centreSignonOk) ' Calls an Activity
End Sub

' Handles EPOS_GET_LOCATION request and sends a response.
Private Sub HandleGetLocationRequest()
	Dim locationRec As clsEposLocationRec : locationRec.Initialize
	locationRec.ID = myData.customer.customerId
	locationRec.location.latitude = latestLocation.Latitude
	locationRec.location.longitude = latestLocation.Longitude
	Dim msg As String = modEposApp.EPOS_GET_LOCATION & locationRec.XmlSerialize
	SendMessage(msg)
End Sub

' Handle the Open TAB confirmation 
private Sub HandleOpenTabConfirm(openTabConfirmResponse As String)
	' TODO Duplicated code see connection.pConfirmCustomerDetails()
	Dim xmlStr As String = openTabConfirmResponse.SubString(modEposApp.EPOS_OPENTAB_CONFIRM.Length)
	Dim customerDetailsObj As clsEposCustomerDetails : customerDetailsObj.Initialize
	customerDetailsObj = customerDetailsObj.XmlDeserialize(xmlStr)
	If customerDetailsObj.authorized Then
		If customerDetailsObj.customerId = myData.customer.customerId Then ' Customer ID correct?
			If customerDetailsObj.centreId = myData.centre.centreId Then ' Centre ID correct?
				myData.centre.signedOn = True ' Flag signed on to this centre.
				CallSubDelayed(aValidateCentreSelection2, "OpenTabConfirmResponse") ' Calls an Activity
			End If
		End If
	End If
End Sub

' Handle payment response string.
private Sub	HandlePaymentResponse(paymentResponse As String)
#if B4A
	Dim xmlStr As String = paymentResponse.SubString(modEposApp.EPOS_PAYMENT.Length)
#else 'B4I
	Dim xmlStr As String = TrimToXmlOnly(paymentResponse)
#end if
	Dim paymentInfo As clsEposCustomerPayment : paymentInfo.Initialize
	paymentInfo = paymentInfo.XmlDeserialize(xmlStr)
#if B4A
	CallSubDelayed2( aHome, "ReportPaymentStatus", paymentInfo) 
#else ' B4I
	xHome.ReportPaymentStatus(paymentInfo)
#end if

End Sub

' Handles the Server's response to the Get Status List command.
Private Sub HandleStatusListMsg(statusListMsg As String)
	If svcTestSequence.TestSeqRunning Then ' Original command was a test message
		CallSub(svcTestSequence, "pReceivedResponse")
	Else 
		If Not(IsPaused(aHome)) Then ' Only show Status list if Home is visible.
			CallSubDelayed2(aHome, "HandleOrderStatusList", statusListMsg) ' Calls an Activity			
		End If
	End If
End Sub

' Handles the Server's response to the menu (sync data).
Private Sub HandleSyncDataResponse(syncDataResponse As String)
	CallSubDelayed2(aHome, "HandleSyncDbResponse", syncDataResponse) ' Calls Home Activity
End Sub

' Deserialises the specified Update Customer XML string, and uses it to update the locally-stored customer info.
Private Sub HandleUpdateCustomer(updateCustomerMsg As String)
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
Private Sub NotifyMessage(inStrg As String)
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
Private Sub NotifyStatus(inStrg As String)
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
		Else if IsPaused(aHome) = False Then ' Other - Only change status if Home screen shown?
			CallSubDelayed2(aHome, "UpdateOrderStatus", responseObj) ' Calls an Activity
		End If
	Else ' XML deserialisation failed (or contains Unknown status, which is just as bad)
		LogFile.LogReport(ERROR_LIST_FILENAME, "Received bad status message:" & CRLF & inStrg) ' Log the error
	End If
End Sub

' Handles the response to a server ping.
Private Sub PingHandle(txtPing As String)
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
		SendMessage(txMsg)
	Else ' response ping (no resposne expected)
		connect.ServerCheckSuccess
	End If
End Sub

' Send Delivery message
Private Sub SendDeliveryMessage(messageId As Int)
	Dim msg As String = modEposApp.EPOS_DELIVERY & _
						 "," & modEposWeb.ConvertToString(myData.customer.customerId) & _
						 "," & modEposWeb.ConvertToString(messageId)
	SendMessage(msg)
End Sub

' Sends an open tab message
Private Sub SendOpenTab
	Dim msg As String = modEposApp.EPOS_OPENTAB_REQUEST & "," & MyIpAddress & _
						 "," & modEposWeb.ConvertToString(myData.customer.customerId) & _
						 "," & myData.customer.BuildUniqueCustomerInfoString & _
						 "," & myData.customer.rev
	SendMessage(msg)
End Sub

' Sends the message which had been queued to be sent after automatically reconnecting (if any).
Private Sub SendQueuedMsgAfterReconnect
	If reconnectQueuedMsg <> "" Then
		SendMessage(reconnectQueuedMsg)
		reconnectQueuedMsg = ""
	End If
End Sub

' Sends a response to the customer update command
Private Sub SendCustomerUpdateResponse(customerInfoRec As clsEposCustomerInfo)
	Dim msg As String = modEposApp.EPOS_MESSAGE & customerInfoRec.XmlSerialize(customerInfoRec)
	SendMessage(msg)
End Sub

' Shows a message notification
Private Sub ShowMessageNotification(headingTop As String)
	' Show the message directly, if possible, otherwise raise a notification
	If IsPaused(aHome) = False Then
		CallSubDelayed2(aHome, "ShowMessageNotificationMsgBox", True) ' Calls an Activity
	else if IsPaused(aPlaceOrder) = False Then
		CallSubDelayed2(aPlaceOrder, "ShowMessageNotificationMsgBox", True) ' Calls an Activity
	else if IsPaused(aSelectItem) = False Then
		CallSubDelayed2(aSelectItem, "ShowMessageNotificationMsgBox", True) ' Calls an Activity
	Else ' Task Select activity is not currently active - raise a notification instead
		Dim titleContentTag(3) As String = Array As String("You have a new message", headingTop, modEposApp.NOTIFY_MESSAGE_TAG)
		NotificationMessage = CallSub3(srvNotification, "pSimple_Notification", titleContentTag, modEposApp.NOTIFY_MESSAGE_ID)
	End If
End Sub

' Shows a status notification.
Private Sub ShowStatusNotification
	' Either show the message directly or raise a notification as required
	If IsPaused(aHome) = False Then
		CallSubDelayed2(aHome, "ShowStatusNotificationMsgBox", True) ' Calls an Activity
	else if IsPaused(aPlaceOrder) = False Then
		CallSubDelayed2(aPlaceOrder, "ShowStatusNotificationMsgBox", True) ' Calls an Activity
	else if IsPaused(aSelectItem) = False Then
		CallSubDelayed2(aSelectItem, "ShowStatusNotificationMsgBox", True) ' Calls an Activity
	Else ' Task Select activity is not currently active - raise a notification instead
		Dim titleContentTag(3) As String = Array As String(PrevStatus(0), PrevStatus(1), modEposApp.NOTIFY_STATUS_TAG)
		NotificationStatus = CallSub3(srvNotification, "pSimple_Notification", titleContentTag, modEposApp.NOTIFY_STATUS_ID)
	End If
End Sub


' End the phone modes phone modes which prevent the app being 'dozed' by the Android OS.
' Must always be called before the app closes if StartAntiSleepPhoneModes() has ever been called.
Private Sub StopAntiSleepPhoneModes
	mlWifiObj.releaseWifiOn
	phoneLock.ReleasePartialLock
	Service.StopForeground(FOREGROUND_NOTIFICATION_ID)
End Sub

' Returns the specified comms buffer contents truncated to the first complete message.
' If any text exists after the first end-of-file marker, it will be logged to file as a comms error.
Private Sub TruncateCommsBuffer(inputStr As String) As String
	Dim firstMsgEndIndex As Int = inputStr.IndexOf(EOF_STRING) + EOF_STRING.Length
	Dim firstCompleteMsgStr As String = inputStr.SubString2(0, firstMsgEndIndex)
	If inputStr.Length > firstMsgEndIndex Then ' Message has been truncated - log the buffer data
		LogFile.LogReport(ERROR_COMMS_FILENAME, "The comms buffer was truncated, from its full contents:" & CRLF & inputStr)
	End If
	Return firstCompleteMsgStr
End Sub

#End Region  Local Subroutines
