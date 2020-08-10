B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=7.8
@EndOfDesignText@
'
' Service which handles the connection to the Server.
'

#Region  Documentation
	'
	' Name......: SrvConnect
	' Release...: 6
	' Date......: 08/01/19
	'
	' History
	' Date......: 06/03/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking	
	'
	' Date......: 23/03/18
	' Release...: 2
	' Amendee...: D Morris
	' Details...:	mod: reconnectInProgress now public
	'             Added: public connectionStatus enum - code changed to support the value.
	'
	' Date......: 08/04/18
	' Release...: 3
	' Overview..: Can enable/disable auto reconnect operation
	' Amendee...: D Morris
	' Details...:	Added: autoReconnect flag.  
	'
	' Date......: 22/05/18
	' Release...: 4
	' Overview..: Fixed compiler warning.
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Commented out all instances of reconnectTimeOut, as it wasn't used anywhere (causing compiler warning)
	'
	' Date......: 10/09/18
	' Release...: 5
	' Overview..: Implemented various comms settings.
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Changes in Service_Create() and lIsWifiSignalOk() to implement the relevant configurable comms settings
	'		Mod: The connectionStatus public variable is now set to the proper constant value in Service_Create
	'				(rather than previous being set to a magic number in Process_Globals)
	'		Mod: Removed obsolete commented-out code, added headers etc, and generally tidied up the module.
	'
	' Date......: 08/01/19
	' Release...: 6
	' Overview..: Changes to experiment using clsConnect class to handle operation. 
	' Amendee...: D Morris
	' Details...: Mod: Most of code is commented out and moved to clsConnect class.
	'			  Removed: This Service and now obsolete and is removed from the project.
	'
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region

#Region  Service Attributes 
	#StartAtBoot: False
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	
'	' Public variables
'	Public connectionStatus As Int ' The current connection status. Should only ever be set to ModEposApp.CONNECTION_* constants.
'	Public reconnectInProgress As Boolean = False ' Whether there is currently a reconnection attempt in progress.
'	Public autoReconnect As Boolean = False ' Whether the app should try to automatically reconnect when the connection is lost.
'	
'	' Local variables
'	Private prevWifiStrengthOk As Boolean = True ' Whether the Wifi strength was OK the previous time it was checked.
'	Private tmrReconnectTimeOut As Timer ' The timer used to time-out reconnection attempts.
'	Private tmrServerCheckTimeout As Timer ' The timer used to time-out server check attempts.
'	Private tmrServerCheckTimer As Timer ' The timer used to invoke server checks at regular intervals.
	
	' code added to support the clsConnect class.
	Public connect As clsConnect	'
'	Public autoReconnect As Boolean = False ' Whether the app should try to automatically reconnect when the connection is lost.
'	Public connectionStatus As Int ' The current connection status. Should only ever be set to ModEposApp.CONNECTION_* constants.
End Sub

Sub Service_Create
'	connectionStatus = ModEposApp.CONNECTION_DISCONNECTED
'	tmrReconnectTimeOut.Initialize("tmrReconnectTimeOut", (Starter.settings.reconnectTimeout * 1000))
'	tmrServerCheckTimeout.Initialize("tmrServerCheckTimeout", (Starter.settings.serverCheckTimeout * 1000))
'	tmrServerCheckTimer.Initialize("tmrServerCheckTimer", (Starter.settings.serverCheckInterval * 1000))
'	tmrServerCheckTimer.Enabled = True

	connect.Initialize
End Sub

Sub Service_Start (StartingIntent As Intent)
	' Currently nothing
End Sub

Sub Service_Destroy
	' Currently nothing
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

'' Handles the Tick event of the Reconnect Timeout timer.
'Private Sub tmrReconnectTimeOut_Tick()
'	tmrReconnectTimeOut.Enabled = False
'	If autoReconnect Then
'		If reconnectInProgress Then
'			reconnectInProgress = False
'		End If
'	End If
'End Sub
'
'' Handles the Tick event of the Server Check Timeout timer.
'Private Sub tmrServerCheckTimeout_Tick()
'	tmrServerCheckTimeout.Enabled = False 
'	If autoReconnect Then
'		pReconnectToServer		
'	End If
'End Sub
'
'' Handles the Tick event of the Server Check Interval timer.
'Private Sub tmrServerCheckTimer_Tick()
'	If lIsWifiSignalOk Then
'		If autoReconnect Then
'			Dim txMsg As String = Starter.CustomerDetails.customerId & ","
'			DateTime.DateFormat = "HH:mm:ss"
'			Dim timeStamp As String = "Time:" & DateTime.Date(DateTime.Now)
'			txMsg = txMsg & timeStamp
'			CallSub2(Starter, "pSendMessage", ModEposApp.EPOS_PING & txMsg )
'			connectionStatus = ModEposApp.CONNECTION_CHECK
'			tmrServerCheckTimeout.Enabled = True			
'		End If
'	End If
'End Sub

#End Region

#Region  Public Subroutines
'
' Returns the current WiFi signal strength (as a percentage).
Public Sub pGetWifiSignalStrength() As Int
'	Dim wifiSignal As MLwifi
'	Return wifiSignal.WifiSignalPct
	Return connect.pGetWifiSignalStrength()
End Sub
'
'' Returns whether the WiFi is currently switched-on on the device.
Public Sub pIsWifiOn As Boolean
'	Dim wifiLocal As MLwifi
'	Return wifiLocal.isWifiEnabled
	Return connect.pIsWifiOn
End Sub
'
' Returns whether the WiFi is currently switched-on and above the strength threshold configured in the settings.
' Otherwise, will return false (including if a reconnection is in progress).
Public Sub pIsWifiQuickCheckOk As Boolean
'	Dim wifiConnected As MLwifi
'	Dim wifiQuickCheckOk As Boolean = False
'
'	If reconnectInProgress = False Then	' Return false if reconnection is in progress
'		If wifiConnected.isWifiConnected Then
'			If lIsWifiSignalOk Then
'				wifiQuickCheckOk = True
'			End If
'		End If
'	End If
'	Return wifiQuickCheckOk
	Return connect.pIsWifiQuickCheckOk
End Sub
'
' Handles a successful reconnection.
Public Sub pReconnectSuccess
'	reconnectInProgress = False
'	tmrReconnectTimeOut.Enabled = False
'	connectionStatus = ModEposApp.CONNECTION_OK
'	autoReconnect = True ' Re-enable auto reconnect operation
	connect.pReconnectSuccess
End Sub
'
' Invokes a reconnection attempt.
Public Sub pReconnectToServer
'	Starter.reconnectEnabled = True
'	connectionStatus = ModEposApp.CONNECTION_RECON
'	CallSub(Starter, "pConnectToServer")
'	reconnectInProgress = True ' Start reconnection timer
'	tmrReconnectTimeOut.Enabled = True
	connect.pReconnectToServer
End Sub
'
' Restarts the server check interval timer.
Public Sub pRetriggerServerCheck
'	tmrServerCheckTimer.Enabled = False
'	tmrServerCheckTimer.Enabled = True
'	connectionStatus = ModEposApp.CONNECTION_OK
	connect.pRetriggerServerCheck
End Sub
'
' Handles a successful server check.
Public Sub pServerCheckSuccess
'	tmrServerCheckTimeout.Enabled = False
'	connectionStatus = ModEposApp.CONNECTION_OK
	connect.pServerCheckSuccess
End Sub



#End Region  Public Subroutines

#Region  Local Subroutines
'
'' Returns whether the WiFi is currently above the strength threshold configured in the settings.
'Private Sub lIsWifiSignalOk() As Boolean
'	Dim wifiStrength As Int = pGetWifiSignalStrength
'	Dim wifiStrengthOk As Boolean = False 
'	
'	If wifiStrength > (Starter.settings.wifiLowThreshold + Starter.settings.wifiHysteresis) Then
'		wifiStrengthOk = True
'	Else If wifiStrength < Starter.settings.wifiLowThreshold Then
'		wifiStrengthOk = False
'	Else If prevWifiStrengthOk Then ' Level is in hysteresis zone
'		wifiStrengthOk = True
'	End If
'	prevWifiStrengthOk = wifiStrengthOk
'	Return wifiStrengthOk
'End Sub

#End Region  Local Subroutines
