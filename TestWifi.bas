B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=7.8
@EndOfDesignText@
'
' Activity which is used to test the Wifi operation.
'

#Region  Documentation
	'
	' Name......: TestWifi
	' Release...: 18
	' Date......: 11/05/20   
	'
	' History
	' Date......: 10/02/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' History Versions 2 - 11 see v14.
	'
	' Date......: 08/01/19
	' Release...: 12
	' Overview..: Changes to support new version of Starter service (using clsConnect) 
	' Amendee...: D Morris
	' Details...: Mod: lDisplayConnectionStatus() - code modified.
	'             Mod: btnTestDisconnect_Click() - code modified.
	'			  Mod: btnTestReconnect_Click() - code modified.
	'
	' Date......: 28/01/19
	' Release...: 13
	' Overview..: Changes to allow the app to determine when it is no longer connected.
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Change in Activity_Pause() to kill this activity if the phone becomes disconnected from the server
	'
	' Date......: 11/06/19
	' Release...: 14
	' Overview..: Changes to register new users with the Web API
	' Amendee...: D Hathway
	' Details...: Mod: Change in btnCustomerInfo_Click() to call the customer info form differently (as it no longer works in the previous manner)
	'
	'
	' Date......: 05/07/19 
	' Release...: 15
	' Overview..: Usage of TestConnection service (now obsolete) dropped.
	' Amendee...: D Morris
	' Details...: Mods: btnPing_Click() and btnTestEvent_Click() code modified.
	'
	' Date......: 13/10/19
	' Release...: 16
	' Overview..: Support for X- platform operation. 
	' Amendee...: D Morris
	' Details...: Mods: Sub renamed.
		'
	' Date......: 21/03/20
	' Release...: 17
	' Overview..: #315 Issue removed B4A compiler warnings. 
	' Amendee...: D Morris
	' Details...:  Mod: btnTestEvent_Click() msgbox() commented out.
	'
	' Date......: 11/05/20
	' Release...: 18
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mod: Activity_Pause().
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'btnTestEvent_Click
#End Region  Documentation

#Region  Activity Attributes
	#FullScreen: False
	#IncludeTitle: False
#End Region  Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	
	' Public variables
	Private tmrWifiSignal As Timer '  Timer used to test the WiFi signal strength.

End Sub

Sub Globals
	
	' Local variables
	Private testStartAtRunning As Boolean ' Stores whether a 'Start AT' test is running.
	Private sampleCount As Int ' Stores the WiFi sample count.
	
	' View declarations
	Private btnTest As Button ' Button which tests the WiFi.
	Private btnClose As Button ' Button which closes the activity.
	Private btnCustomerInfo As Button ' Button which opens the Customer Info activity.
	Private btnPing As Button ' Button which invokes a Ping command.
	Private btnTestDisconnect As Button ' Button which tests the disconnect procedure.
	Private btnTestEvent As Button ' Button which invokes a test event.
	Private btnTestReconnect As Button ' Button which tests the reconnect procedure.
	Private btnTestSequence As Button ' Button which invokes the Comms Test Sequence activity.
	Private btnTestStartAt As Button ' Button which tests the Start AT test.
	Private lblSignalLevel As Label ' Label which displays the WiFi signal level.
	Private lblSampleCount As Label ' Label which displays the WiFi sample count.
	Private lblConnectionStatus As Label ' Label which displays the connection status.
	Private lblPingDuration As Label ' Label which displays the ping response duration.
	Private txtPingIpAddress As EditText ' Textbox used to enter the Ping IP address.
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmTestWifi")
	tmrWifiSignal.Initialize("tmrWifiSignal", 1000)
	txtPingIpAddress.text = "192.168.0.1"
End Sub

Sub Activity_Resume
	tmrWifiSignal.Enabled = False ' ensure timer is stopped
	lblSignalLevel.Text = ""
	btnTest.Text = "Test"
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	tmrWifiSignal.Enabled = False
	If Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Close button.
Private Sub btnClose_Click()
	tmrWifiSignal.Enabled = False ' Stop timer
	Activity.Finish ' Kill this activity, which mean it will return to whichever activity originally called it
End Sub

' Handles the Click event of the Customer Info button.
private Sub btnCustomerInfo_Click
'	StartActivity(CustomerInfo)
	CallSubDelayed(CustomerInfo, "pCreateNewCustomer")
End Sub

' Handles the Click event of the Ping button.
private Sub btnPing_Click()
	Dim diff As Int = Starter.connect.PingAddress(txtPingIpAddress.Text)
	lblPingDuration.Text = diff & "ms"
End Sub

' Handles the Click event of the Test WiFi button.
Private Sub btnTest_Click()
	If btnTest.Text = "Test" Then
		sampleCount = 0
		btnTest.Text = "End Test"
		tmrWifiSignal.Enabled = True
		lDisplayWifiSignal
	Else
		btnTest.Text = "Test"
		tmrWifiSignal.Enabled = False
		lblSignalLevel.Text = ""
	End If
End Sub

' Handles the Click event of the Test Disconnect button.
Private Sub btnTestDisconnect_Click()
	lblConnectionStatus.Text = "Disconnecting"
	Sleep(2000) ' This delay appears necessary, otherwise the disconnect message is not sent
	CallSub(Starter, "pDisconnectFromServer")
	lDisplayConnectionStatus
	'SrvConnect.connectionStatus = ModEposApp.CONNECTION_DISCONNECTED
	'SrvConnect.connect.connectionStatus = ModEposApp.CONNECTION_DISCONNECTED ' Not good but will do for testing!
	Starter.connect.connectionStatus = modEposApp.CONNECTION_DISCONNECTED
End Sub

' Handles the Click event of the Test Event button.
Private Sub btnTestEvent_Click()
	' TODO If still required need to replace with an equivalent.
	'CallSub2(TestConnection, "pCheckIfHubConnection", txtPingIpAddress.Text)
'	Msgbox("Text Ping Event!", "Not currently supported")
End Sub

' Handles the Click event of the Test Reconnect button.
Private Sub btnTestReconnect_Click()
'	CallSub(SrvConnect, "pReconnectToServer")
	Starter.connect.ReconnectToServer
End Sub

' Handles the Click event of the Comms Test Sequence button.
Sub btnTestSequence_Click
	StartActivity(TestSequence)
End Sub

' Handles the Click event of the Test Start AT button.
Private Sub btnTestStartAt_click()
	If testStartAtRunning = False Then
		btnTestStartAt.Text = "Stop StartAT"
		testStartAtRunning = True
		StartService(TestStartAt)
	Else
		btnTestStartAt.Text = "Test StartAT"
		testStartAtRunning = False
		StopService(TestStartAt)
	End If
End Sub

' Handles the Tick event of the WiFi signal timer.
Private Sub tmrWifiSignal_Tick
	sampleCount = sampleCount + 1
	lblSampleCount.Text = sampleCount
	lDisplayWifiSignal
	lDisplayConnectionStatus
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Currently none

#End Region  Public Subroutines

#Region  Local Subroutines

' Displays the current connection status.
Private Sub lDisplayConnectionStatus
'	Select SrvConnect.connectionStatus
'	Select SrvConnect.connect.connectionStatus ' Not Good but ok for testing!	
	Select Starter.connect.connectionStatus
		Case modEposApp.CONNECTION_CHECK
			lblConnectionStatus.Text = "Checking"
		Case modEposApp.CONNECTION_OK
			lblConnectionStatus.Text = "Connected"
		Case modEposApp.CONNECTION_RECON
			lblConnectionStatus.Text = "Reconnect"
		Case modEposApp.CONNECTION_LOSTED
			lblConnectionStatus.Text = "Lost"
		Case modEposApp.CONNECTION_DISCONNECTED
			lblConnectionStatus.Text = "Disconnected"
		Case Else
			lblConnectionStatus.Text = "Unknown"
	End Select
End Sub

' Displays the current WiFi signal level.
Private Sub lDisplayWifiSignal
	Dim wifiSignal As Int
	
	wifiSignal = ConnectionHelper.pCheckSocketOperation
	lblSignalLevel.text = wifiSignal
	lblSampleCount.Text = sampleCount
End Sub

#End Region  Local Subroutines
