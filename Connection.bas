B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=7.3
@EndOfDesignText@
'
' This form allows the operator to edit the details of the socket connection to the Server.
'

#Region  Documentation
	'
	' Name......: Connection
	' Release...: 39
	' Date......: 26/04/20
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking (Based on arenaRemote.connection v3)
	'                 Versions 2 - 12 see Connection_v14
	'				           13 - 23 see Connection_v24
	'						   24 - 34 see Connection_v34
	'
	' Date......: 22/10/19
	' Release...: 35
	' Overview..: Support for X platform
	' Amendee...: D Morris
	' Details...:  Mod: lStreamlineConfirmation() subs renamed.
	'
	' Date......: 17/11/19
	' Release...: 36
	' Overview..: Support for testMode as part of settings.
	' Amendee...: D Morris
	' Details...:  Mod: lHandleViewDisplay()
	'			   Mod: lblLocalInfo_Click().
		'
	' Date......: 25/11/19
	' Release...: 37
	' Overview..: Confusing operation when switching centres/accounts.
	' Amendee...: D Morris
	' Details...:  Mod: lSignOnToCentreServer()
		'
	' Date......: 21/03/20
	' Release...: 38
	' Overview..: #315 Issue removed B4A compiler warnings. 
	' Amendee...: D Morris
	' Details...:  Mod: Unused variable mHasBeenDisconnected commented out.
	'			   Mod: References to mHasBeenDisconnected in pDisconnectedByServer() and
	'						commented out pDisconnectedByTimeout() 
	'
	' Date......: 26/04/20
	' Release...: 39
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris.
	' Details...:  Mod:lSignOnToCentreServer(), lStreamlineConfirmation().
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
	Private Const BTNTEXT_CONNECT As String = "Connect to Server" ' Text displayed on the Connect button when not connected.
	Private Const BTNTEXT_DISCONNECT As String = "Disconnect from Server" ' Text displayed on the Connect button when connected.
	
	' Local variables
	Private mIsConnected As Boolean = False	' Indicates whether the device is connected to the Server.
	Private mTestBackdoorCounter As Int ' The counter which allows the Test activity to be shown when it reaches 6.
'	Private mHasBeenDisconnected As Boolean = False ' Stores whether the phone has been disconnected (by the Server or due to timeouts)
	
	' View declarations
	Private btnConnect As Button		' The button which will cause the socket to connect (or disconnect as required).
	Private btnTest As Button 			' The button which invokes the Test activity.
	Private chkWebOnlyComms As CheckBox ' Check box to select HTTP comms.
	Private lblLocalInfo As Label 		' The label which displays the app name, version, and local IP adress.
	Private lblPrivacyPolicy As Label	' Link to Privacy Policy.
	Private lblServerIPCaption As Label ' The label which shows a caption for the Server IP Address textbox.
	Private lblWelcomeStatus As Label 	' The label which shows a welcome message or connection status.
	Private txtServerIP As EditText 	' The textbox into which the Server IP address should be entered.
	
	Private btnSelectCentre As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	
	' Starter.centreID = 1	' HACK to force centreId=1
	
	Activity.LoadLayout("frmConnect")
'	txtServerIP.Text = Starter.ServerIP ' This field must always be populated as it is used during connection procedure
'	lHandleViewDisplay
	
	Sleep(100) ' Process the event queue (if it's been disconnected, mHasBeenDisconnected may change in this time)
' RE-INSERT After testing	
' HACK: Removed as automatic connect on startup - gets in the way of testing.	
'	If Starter.settings.webOnlyComms Then ' Connect via Web
'		CallSub(Starter, "pSendOpenTabRequest")
'	Else ' Wifi connection
'		If Not(Starter.IsConnected) And Not(mHasBeenDisconnected) Then
'			If lValidServerIpAddress(Starter.ServerIP) Then lConnect
'		End If		
'	End If

End Sub

Sub Activity_Resume
	mTestBackdoorCounter = 0
	txtServerIP.Text = Starter.ServerIP ' This field must always be populated as it is used during connection procedure
	lHandleViewDisplay
End Sub

Sub Activity_Pause(UserClosed As Boolean)
	' Currently nothing
End Sub

Sub Activity_Keypress(KeyCode As Int) As Boolean
	' This method of preventing the 'Back' button is from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
	If KeyCode = KeyCodes.KEYCODE_BACK And mIsConnected Then
		Return False ' Returning false allows the event to continue	
	Else
		Return True ' Returning true consumes the event, preventing the 'Back' action
	End If
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Connect button.
Private Sub btnConnect_Click
	If Starter.settings.webOnlyComms Then
		If btnConnect.Text = BTNTEXT_CONNECT Then
'			If Starter.settings.newWebStartup Then
'				StartActivity(xSelectPlayCentre)
'			Else ' Old startup.

				CallSub(Starter, "pSendOpenTabRequest")					
'			End If
		else if btnConnect.Text = BTNTEXT_DISCONNECT Then
			ProgressDialogShow("Disconnecting, please wait...")
			CallSub(Starter, "pDisconnectFromServer")
		End If
	Else ' Connect by WIFI
		If btnConnect.Text = BTNTEXT_CONNECT Then
			lConnect
		Else If btnConnect.Text = BTNTEXT_DISCONNECT Then
			ProgressDialogShow("Disconnecting, please wait...")
			CallSub(Starter, "pDisconnectFromServer")
		End If		
	End If
End Sub

' Handles the Click event of the Select Centre button.
Sub btnSelectCentre_Click
	CallSub(Starter, "pDisconnectFromServer")
	CallSubDelayed(xSelectPlayCentre, "SelectCentre")
End Sub

' Handles the Click event of the Test button.
Private Sub btnTest_Click
	StartActivity(TestWifi)
End Sub

' Handle enable/disable HTTP comms.
Private Sub chkWebOnlyComms_Click
	If chkWebOnlyComms.Checked Then
		Starter.settings.webOnlyComms = True
	Else
		Starter.settings.webOnlyComms = False
	End If
	StartActivity("ChangeSettings") ' Hask so the new setting can be changed.
End Sub

' Handles the Click event of the Local Info label.
' This is used to activate the backdoor that shows the button which invokes the Test activity.
Private Sub lblLocalInfo_Click
	mTestBackdoorCounter = mTestBackdoorCounter + 1	
	If mTestBackdoorCounter = 7 Then ' The Test button is shown/hidden by pressing the top label seven times
		mTestBackdoorCounter = 0 ' Reset the counter to allow it to be hidden again
		CallSub2(Starter, "pSetTestMode", Not(Starter.settings.testMode)) ' Invert the current test mode setting
		lHandleViewDisplay ' Update the screen to show the Test button
	End If
End Sub

' Hyperlink to display privacy policy in Browser.
private Sub lblPrivacyPolicy_Click
	Dim p As PhoneIntents
	StartActivity(p.OpenBrowser("http://www.hangar51.co.uk/legal/privacypolicy"))
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Handles the connection confirmation operation.
public Sub pConfirmCustomerDetails(customerDetailsXml As String)
	ProgressDialogHide
	lStreamlineConfirmation(customerDetailsXml)
End Sub

' Updates the activity's display to reflect the successful connection.
Public Sub pConnectedSuccessfully
	lHandleViewDisplay
	Starter.connect.autoReconnect = True
End Sub

' Displays a message box informing the customer that the connect operation has failed.
Public Sub pConnectFailed
	ProgressDialogHide
	MsgboxAsync("Unable to connect to the Server. Please ensure that the IP address is correct, and that this phone is " & _
				"connected to the same Wifi network as the Server, and then try again.", "Failed To Connect")
End Sub

' Display a message box informing the customer that an invalid customer number was entered.
Public Sub pCustomerIdFailed
	ProgressDialogHide
	MsgboxAsync("Please try again.", "Invalid Customer Number")
End Sub

' Displays a message box informing the user that they have been disconnected from the Server end.
Public Sub pDisconnectedByServer
'	mHasBeenDisconnected = True
	lHandleViewDisplay
	MsgboxAsync("The Server has disconnected you. If you wish to reconnect, please first make sure that you were " & _
			"disconnected from the Server in error, and then make a new connection attempt.", "Disconnected From Server")
End Sub

' Displays a message box informing the user that they have been disconnected due to multiple timeouts.
Public Sub pDisconnectedByTimeout
'	mHasBeenDisconnected = True
	lHandleViewDisplay
	MsgboxAsync("Connection with the server has been lost due to inactivity. To reconnect, please ensure your " & _
					" Wifi is connected and in range, and then press the Connect button.", "Connection Lost")
End Sub

' Updates the activity's display to show that the device has successfully disconnected from the Server.
Public Sub pDisconnectedSuccessfully
	ProgressDialogHide
	lHandleViewDisplay
End Sub

' Enters the specified centre sign-in information, and starts the connection procedure.
Public Sub pSelectedCentre(centreName As String, ipAddress As String)
	lblWelcomeStatus.Text = "Selected: " & centreName
	txtServerIP.Text = ipAddress
	lConnect
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Invokes the connection procedure using whichever method is currently selected in the settings.
Private Sub lConnect
	' First ensure the IP address is saved
	Dim enteredIp As String = txtServerIP.Text.Trim
	If lValidServerIpAddress(enteredIp) Then
		Starter.ServerIP = enteredIp
		CallSub2(Starter, "pSetTestMode", txtServerIP.Visible)
	End If
	
	' Then start the connection procedure
	Dim wifi As MLwifi
	If wifi.isWifiConnected Then
		lConnectStreamlineSignOn
	Else
		MsgboxAsync("You are not connected to a Wifi network. Please connect to the same Wifi network as the " & _
							"Server, and then try again.", "No Wifi Connection")
	End If
End Sub

' Starts the connection procedure using the streamlined sign-on.
Private Sub lConnectStreamlineSignOn
	If txtServerIP.Text.Trim <> "" Then
		Starter.ServerIP = txtServerIP.Text.Trim
		ProgressDialogShow("Connecting, please wait...")
		CallSub(Starter, "pConnectToServer")
	Else
		MsgboxAsync("Please try again.", "No IP Address Entered")
	End If
End Sub

' Deserialises the customer details XML string, and updates Global starter.CustomerDetails structure
' TODO Duplicated code see starter.lHandleCustomerDetailsMsg()
Private Sub lHandleCustomerDetailsMsg(openTabCmdResponseStr As String) As clsEposCustomerDetails
	Dim xmlStr As String = openTabCmdResponseStr.SubString(modEposApp.EPOS_OPENTAB_REQUEST.Length)
	Dim customerDetailsObj As clsEposCustomerDetails : customerDetailsObj.Initialize
	customerDetailsObj = customerDetailsObj.XmlDeserialize(xmlStr)
	Return customerDetailsObj
End Sub

' Updates the activity's views according to whether the device is connected and whether streamlined sign-on is being used.
Private Sub lHandleViewDisplay
	' Declare/update local copies of variables
	Dim testMode As Boolean = Starter.settings.testMode
	mIsConnected = Starter.IsConnected
	
	' Handle the appearance of most of the views
	Dim welcomeLblText As String = "Welcome to SuperOrder!"
	If mIsConnected Then welcomeLblText = "You are currently connected."
	lblWelcomeStatus.Text = welcomeLblText
	lblServerIPCaption.Visible = testMode
	txtServerIP.Visible = testMode
	lblLocalInfo.Text = Application.LabelName & ", " & Application.VersionName & CRLF & "My local IP: " & Starter.MyIpAddress
	btnTest.Visible = testMode
	Dim infoLblWidthModifier As Int = 0
	If testMode Then infoLblWidthModifier = btnTest.Width
	lblLocalInfo.Width = Activity.Width - (infoLblWidthModifier + 40dip)
	chkWebOnlyComms.Checked = Starter.settings.webOnlyComms
	
	' Handle the appearance of the Connect button
	Dim buttonTop As Int = (lblWelcomeStatus.Top + lblWelcomeStatus.Height + 10dip)
	If testMode Then buttonTop = (txtServerIP.Top + txtServerIP.Height + 20dip)
	btnConnect.Top = buttonTop
	Dim buttonText As String = BTNTEXT_CONNECT
	If mIsConnected Then buttonText = BTNTEXT_DISCONNECT
	btnConnect.Text = buttonText
	
End Sub

' Sign-on to a centre server (using internet).
private Sub lSignOnToCentreServer()As ResumableSub
	Dim signedOnOk As Boolean = False
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	
'	Dim urlStrg As String = "https://www.superord.co.uk/api/customer/" & Starter.myData.customer.customerIdStr 
'	urlStrg = urlStrg & "?setting=centresignon&setting1=" & Starter.myData.centre.centreId & "&setting2=1"
	Dim urlStrg As String = modEposWeb.URL_CUSTOMER_API & "/" & modEposWeb.BuildApiCustomerId() & _
								"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_SET_SIGNON & _
								"&" & modEposWeb.API_SETTING_1 & "=" & Starter.myData.centre.centreId & _
								"&" & modEposWeb.API_SETTING_2 & "=1"
	
	Dim jsonToSend As String = ""
'	Log("Sending the customer details to the Web API:" & CRLF & jsonToSend)
	Dim job As HttpJob : job.Initialize("NewCustomer", Me)
	job.PutString(urlStrg, jsonToSend)
	job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Wait For (job) JobDone(job As HttpJob)
	
'	Dim jsonMenuStrg As String
	If job.Success And job.Response.StatusCode = 200 Then
		signedOnOk = True
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	Return signedOnOk
End Sub

' Processes the response to the sign-on command and continues the streamlined sign-on procedure.
Private Sub lStreamlineConfirmation(customerDetailsXml As String)
	Dim customerDetailsRec As clsEposCustomerDetails: customerDetailsRec.initialize
	
	customerDetailsRec = lHandleCustomerDetailsMsg(customerDetailsXml)
	If customerDetailsRec.authorized = True Then
		mIsConnected = True
		'TODO _ need to check this operation with myData is correct
		Log("Todo - Connection.lStreamlineConfirmation() handles message correctly")
		'Starter.CustomerDetails = customerDetailsRec ' Update the global customer details - they're used below in syncDatabase
		CallSub(srvPhoneTotal, "pGetPrevPhoneTotal") ' Update the phone total because the above may have changed the Centre ID
		Dim msg As String =  modEposApp.EPOS_OPENTAB_CONFIRM & customerDetailsRec.XmlSerialize
' TODO Removed not sure this bit of code is necessary.		
'		If Starter.myData.customer.customerIdStr = "" Then
'		'	Starter.CustomerInfoData.customerIdStr = Starter.CustomerDetails.customerId ' Save the new customer number
'			Starter.myData.Save
'		End If
		CallSub2(Starter, "pSendMessage", msg)
'		CallSubDelayed(SyncDataBase, "pSyncDataBase")
		If Starter.settings.webOnlyComms Then
			lSignOnToCentreServer	
		Else
			CallSubDelayed(aSyncDatabase, "pSyncDataBase")
		End If
	Else ' Not authorised by the Server
		Msgbox2Async("Unable To sign-on", "Please retry.", "OK", "", "", Null, False)
		mIsConnected = False
	End If
End Sub

' Returns whether the entered Server IP address is a valid IP address.
' Note: This is not really reliable, the validation requires more fine-tuning.
Private Sub lValidServerIpAddress(serverIp As String) As Boolean
	Dim ipOk As Boolean = False
	Dim ipSubStr As List = Regex.Split("\.", serverIp) ' "\" is used as the escape character - dot is special character
	If ipSubStr.Size = 4 Then ipOk = True ' Not a good check, but it's a start
	Return ipOk
End Sub

#End Region  Local Subroutines
