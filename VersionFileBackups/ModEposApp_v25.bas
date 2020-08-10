B4A=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'
' This module contains constants (especially EPOS commands) that are used throughout the application.
'

#Region  Documentation
	'
	' Name......: ModEposApp
	' Release...: 25
	' Date......: 13/05/20
	'
	' History
	' Date......: 23/12/16
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on ArenaRemote.ModRemote
	'
	'   History 1 - 15 seec ModEposApp_v15
	'			16 - 22 see _v22.
	'
	' Date......: 22/12/19
	' Release...: 23
	' Overview..: General method display selected centr.
	' Amendee...: D Morris
	' Details...: Added: SelectedCentre().
	'
	' Date......: 08/02/20
	' Release...: 24
	' Overview..: Centre displayed name modified.
	' Amendee...: D Morris.
	' Details...:   Mod: FormatSelectedCentre()..
	'		      Added: InitializeStdActionBar().
	'
	' Date......: 13/05/20
	' Release...: 25
	' Overview..:  Added: #0232 - Support EPOS_GET_LOCATION. 
	'			  Bugfix: #0404 - no response to Message or Update Epos commands.
	' Amendee...: D Morris.
	' Details...: Added: EPOS_GET_LOCATION and EPOS_DELIVERY.
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	
	' EPOS remote commands:
	''' <summary>EPOS command (sent by server) Check balances.</summary>
	Public Const EPOS_BALANCECHECK As String = "EposBalanceCheck"
	''' <summary>EPOS command (sent by client) requesting the customers bill.''' </summary>
	Public Const EPOS_BILL As String = "EposBill"
	''' <summary>EPOS command (sent by Server) which notifies the Client that the Server has encountered a Comms Fault.</summary>
	''' <remarks>This command is standalone; no response is expected from the Client, but it should instruct the operator to return to
	''' the Server to carry out a Comms Repair.</remarks>
	Public Const EPOS_COMMSFAULT As String = "EposCommsFault"
	''' <summary>EPOS command (sent by Client/Serve) which instructs the system disconnect, and thus allow new connection attempts.</summary>
	''' <remarks>This command is standalone; no response is expected.</remarks>
	Public Const EPOS_DISCONNECT As String = "EposDisconnect"
	''' <summary>>EPOS command (sent by client) requesting the customers bill in item order.</summary>
	Public Const EPOS_ITEMIZED_BILL As String = "EposItemisedBill"
	''' <summary>EPOS command (Sent by both) send a message</summary>
	Public Const EPOS_MESSAGE As String = "EposMessage"
	''' <summary> EPOS Command (sent by Server) ask customer confirm identity (response to EPOS_OPENTAB_REQUEST)</summary>
	''' <remarks>Response is expected from the Customer - otherwise the Server must retry.</remarks>
	Public Const EPOS_OPENTAB_CONFIRM As String = "EposOpenTabConfirm"
	''' <summary> EPOS command (sent by Client) used to reconnect to server quickly (must have fully connected previously).</summary>
	''' <remarks>Response is expected from the Server - otherwise the client must retry.</remarks>
	Public Const EPOS_OPENTAB_RECONNECT As String = "EposOpenTabReconnect"
	''' <summary>EPOS command (sent by Client) which supplies the Server with the Client's connection details.</summary>
	''' <remarks>This command is appended with the Client's IP address and customer number; the Server should use this to customer tab,
	''' then return customers details to confirm it's now connected properly.</remarks>
	Public Const EPOS_OPENTAB_REQUEST As String = "EposOpenTabRequest"
	''' <summary>EPOS command (sent by Client) which confirms previously placed order (including Server amendments if applicable).</summary>
	''' <remarks>The client provides a customer number and ackn/reject</remarks>
	Public Const EPOS_ORDER_ACKN As String = "EposOrderAckn"
	''' <summary>EPOS command (sent by Client) requesting information about an order.</summary>
	Public Const EPOS_ORDER_QUERY As String = "EposOrderQuery"
	''' <summary>EPOS command (sent by Client) which sends order information to Server.</summary>
	''' <remarks>The client provides a customer number and order details, Server responds with order number (and amendments if necessary).</remarks>
	Public Const EPOS_ORDER_SEND As String = "EposOrderSend"
	''' <summary>EPOS command (sent by Client) which ask server to allow this customer to place an order.</summary>
	''' <remarks>The client provides a customer number.</remarks>
	Public Const EPOS_ORDER_START As String = "EposOrderStart"
	''' <summary>EPOS command (sent by server) indicating the status of an order - i.e. advise customer a order is ready for collection. </summary>
	''' <remarks>If orderId = 0 returns first customer's order in the queue, otherwise it will
	''' return the status of the specified order (i.e. it could have been already completed).</remarks>
	Public Const EPOS_ORDERSTATUS As String = "EposOrderStatus"
	''' <summary>EPOS command (sent by server) Status of all open orders.</summary>
	Public Const EPOS_ORDERSTATUSLIST As String = "EposOrderStatusList"
	''' <summary>EPOS command (sent by client) requesting the status of a specific order</summary>
	Public Const EPOS_ORDERSTATUSQUERY As String = "EposOrderQueryStatus"
	''' <summary>EPOS command (sent by client) Authorise the Bill to be paid.''' </summary>
	Public Const EPOS_PAYMENT As String = "EposPayment"
	''' <summary>EPOS command (sent by both) Ping operation </summary>
	'''<remarks> Receiver responds accordingly.</remarks>
	Public Const EPOS_PING As String = "EposPing"
	''' <summary>EPOS command (sent by Client) which requests the Server to provide Synchronisation data.</summary>
	''' <remarks>The client provides a customer number and a time stamp; the Server will respond with all data updated since that time-stamp.</remarks>
	Public Const EPOS_SYNC_DATA As String = "EposSyncData"
	''' <summary>EPOS command (sent by Server) which instructs the Client to update its customer details file with the specified values.</summary>
	Public Const EPOS_UPDATE_CUSTOMER As String = "EposUpdateCustomer"
	''' <summary>EPOS command get current location.</summary>
	Public Const EPOS_GET_LOCATION As String = "EposGetLocation"
	''' <summary>EPOS command to give delivery indication.</summary>
	Public Const EPOS_DELIVERY As String = "EposDelivery"
	
	' Other constants:
	''' <summary>The port number that we have (arbitrarily) selected for our TCP communications.</summary>
	Public Const TCP_PORT_NUMBER As Int = 51000
	''' <summary>The (arbitrary) fixed IP address given to all normal Server machines.</summary>
	Public Const SERVER_FIXED_IP As String = "192.168.0.240"
	Public Const DFT_PROGRESS_TIMEOUT As Int = 20000	' Default Progress dialog timeout (msecs). 
	
	' Network connection status:
	Public Const CONNECTION_UNKNOWN As Int = 0	' Unknown state  
	Public Const CONNECTION_OK	As Int = 1		' Connected ok
	Public Const CONNECTION_LOSTED As Int = 2 	' Connection to server lost
	Public Const CONNECTION_RECON As Int = 3	' Attempting to reconnect to server (in progress).
	Public Const CONNECTION_CHECK As Int = 4	' Running a check on connection
	Public const CONNECTION_DISCONNECTED As Int = 5 ' Phone is disconnected from the server.
		
	' Notification data
	Public Const NOTIFY_MESSAGE_ID As Int = 1 ' Identifier for Message type notifications
	Public Const NOTIFY_MESSAGE_TAG As String = "notifyMessage" ' Tag assigned to Message type notifications
	Public Const NOTIFY_STATUS_ID As Int = 2 ' Identifier for Order Status type notifications
	Public Const NOTIFY_STATUS_TAG As String = "notifyStatus" ' Tag assigned to Order Status type notifications
	
	' Default ID's
	Public const DFT_CENTRE_ID As Int = 1 		' Default centre ID.
	Public Const DFT_CUSTOMER_ID As Int = 1		' Default customer ID.
	
	' User types: (not good practice but list will only work with user types)
	Type descriptionAbridgedTableRec(key As Int, value As String)
	Type genericTableRec(key As Int, value As String)
	Type sizePriceTableRec(sizePriceKey As Int, sizePrice As String, sizeOptKey As Int, inStock As Boolean)
	
	' File names
	Public const ERROR_COMMS_FILENAME As String = "EposCommsErrors.txt" ' The name of the file used to log comms errors.
	Public Const ERROR_LIST_FILENAME As String = "EposErrorList.txt"	 ' The name of the file used to log exceptions.
	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

' Checks the email format (returns true if ok).
Public Sub CheckEmailFormat(email As String) As Boolean
	Dim emailFormatOk As Boolean = False
	' https://www.b4x.com/android/forum/threads/validate-a-correctly-formatted-email-address.39803/
	Dim MatchEmail As Matcher = Regex.Matcher("^(?i)[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])$", email)
	If MatchEmail.Find = True Then ' Email address validation was successful
		emailFormatOk = True
	End If
	Return emailFormatOk
End Sub

' Builds customer's name and returns it as a string.
Public Sub BuildCustomerName() As String ' TODO - may need to support nickname.
#if B4A
	Dim customerName As String = Starter.myData.Customer.name ' & " " & Starter.CustomerDetails.nickName
#Else
'	Dim customerName As String = Starter.CustomerDetails.foreName
	Dim customerName As String = Starter.myData.Customer.name ' & " " & Starter.CustomerDetails.nickName
#End If
	Return customerName
End Sub

' Display a privacy notice.
Public Sub DisplayPrivacyNotice
#if B4A
	Dim p As PhoneIntents
	StartActivity(p.OpenBrowser(modEposWeb.URL_PRIVACY_POLICY))
#else ' B4I
	Main.App.OpenUrl(modEposWeb.URL_PRIVACY_POLICY)
#End If

End Sub

' Returns a currency value (with 2 decimal digits).
Public Sub FormatCurrency(cost As Float) As String
	Return NumberFormat2(cost, 1, 2, 2, False)
End Sub

' Formats the centre name (usually for use in the title bar).
Public Sub FormatSelectedCentre() As String
	Return Starter.myData.centre.name 
End Sub

#if B4A
' Intialize the std action bar (Android only)
Public Sub InitializeStdActionBar(stdBarObj As StdActionBar, stdBarName As String)
	stdBarObj.Initialize(stdBarName)
	stdBarObj.NavigationMode = stdBarObj.NAVIGATION_MODE_STANDARD
	' bar.subtitle = "This is the subtitle if required."
	stdBarObj.ShowUpIndicator = True
End Sub
#end if

#End Region  Public Subroutines

#Region  Local Subroutines

' Currently nothing

#End Region  Local Subroutines
