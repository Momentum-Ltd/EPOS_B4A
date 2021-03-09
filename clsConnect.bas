B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
'
' Class to handle the procedures which control checking the connection to the Server.
'

#Region  Documentation
	'
	' Name......: clsConnect
	' Release...: 14
	' Date......: 10/02/21
	'
	' History
	' Date......: 08/01/19
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on srvConnect_v5 (code written as a class).
	'
	' Versions 2 - 9 see v10.
	'
	' Date......: 15/11/19
	' Release...: 10
	' Overview..: Support to check if located in Centre
	' Amendee...: D Morris
	' Details...:  Added: IsServerAvailableOnWifi().
		'
	' Date......: 29/12/19
	' Release...: 11
	' Overview..: Improvement to checking for internet.
	' Amendee...: D Morris
	' Details...: Mod: IsInternetAvailable().
	'			
	' Date......: 26/04/20
	' Release...: 12
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris.
	' Details...:  Mod: IsInternetAvailable(), tmrServerCheckTimer_Tick().
	'
	' Date......: 11/06/20
	' Release...: 13
	' Overview..: Mod: Support for second Server.
	' Amendee...: D Morris.
	' Details...:  Mod: IsInternetAvailable().
	'             		
	' Date......: 10/02/21
	' Release...: 14
	' Overview..: Maintenance fix.
	' Amendee...: D Morris
	' Details...: Mod: 'p' dropped from call to Starter.SendMessage().
	'			  
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
		
	' Public variables
	Public connectionStatus As Int 					' The current connection status. Should only ever be set to ModEposApp.CONNECTION_* constants.
	Public reconnectInProgress As Boolean = False 	' Whether there is currently a reconnection attempt in progress.
	Public autoReconnect As Boolean = False 		' Whether the app should try to automatically reconnect when the connection is lost.
	
	' Local variables
	Private prevWifiStrengthOk As Boolean = True 	' Whether the Wifi strength was OK the previous time it was checked.
	Private tmrReconnectTimeOut As Timer 			' The timer used to time-out reconnection attempts.
	Private tmrServerCheckTimeout As Timer 			' The timer used to time-out server check attempts.
	Private tmrServerCheckTimer As Timer 			' The timer used to invoke server checks at regular intervals.

End Sub

#if B4I
' NOTE: The following code is in relation to IsWifiOn(), and is used during compilation to allow detection of whether the
' phone's Wifi is enabled, and is taken from: https://www.b4x.com/android/forum/threads/get-more-wifi-information.102693/
	#if OBJC
#import <ifaddrs.h>
#import <net/if.h>
- (BOOL) isWiFiEnabled {

    NSCountedSet * cset = [NSCountedSet new];

    struct ifaddrs *interfaces;

    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }

    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}
	#End If
#end if

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Tick event of the Reconnect Timeout timer.
Private Sub tmrReconnectTimeOut_Tick()
	tmrReconnectTimeOut.Enabled = False
	If autoReconnect Then
		reconnectInProgress = False
#if B4A
		CallSub(Starter, "IncrementDisconnectCounter")
#else ' B4I
		Main.IncrementDisconnectCounter
#end if
	End If
End Sub

' Handles the Tick event of the Server Check Timeout timer.
Private Sub tmrServerCheckTimeout_Tick()
	tmrServerCheckTimeout.Enabled = False
	If autoReconnect Then
		ReconnectToServer
	End If
End Sub

' Handles the Tick event of the Server Check Interval timer.
Private Sub tmrServerCheckTimer_Tick()
	If IsWifiSignalOk Then
		If autoReconnect Then
			DateTime.DateFormat = "HH:mm:ss"
			Dim timeStamp As String = "Time:" & DateTime.Date(DateTime.Now)			
			Dim txMsg As String = modEposApp.EPOS_PING & _
									modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
									"," & timeStamp
#if B4A
			CallSub2(Starter, "SendMessage", txMsg )
#else ' B4I
			' Main.comms.SendMessage(txMsg)
			Main.SendMessage(txMsg)
#end if
			connectionStatus = modEposApp.CONNECTION_CHECK
			tmrServerCheckTimeout.Enabled = True
		End If
	End If
End Sub

#End Region

#Region  Public Subroutines

' Returns the current WiFi signal strength (as a percentage).
Public Sub GetWifiSignalStrength() As Int
#if B4A
	Dim wifiSignal As MLwifi
	Return wifiSignal.WifiSignalPct
#else ' B4I
	Return 100 ' HACK inserted here as it does not appear possible on iOS to get this value.
#end if
End Sub

'Initializes the object. Note that pStartServerChecking() should be called separately to start the automatic server pings.
Public Sub Initialize
	connectionStatus = modEposApp.CONNECTION_DISCONNECTED
	tmrReconnectTimeOut.Initialize("tmrReconnectTimeOut", (Starter.settings.reconnectTimeout * 1000))
	tmrServerCheckTimeout.Initialize("tmrServerCheckTimeout", (Starter.settings.serverCheckTimeout * 1000))
	tmrServerCheckTimer.Initialize("tmrServerCheckTimer", (Starter.settings.serverCheckInterval * 1000))
End Sub



'#if B4A
'' Checks if internet available (timeout on check is 5 seconds).
'' return true if internet available.
'public Sub IsInternetAvailable As ResumableSub
''	Dim wifiConnected As MLwifi
''	Dim internetAvailable As Boolean = False
''	
''	If wifiConnected.isWifiEnabled Or wifiConnected.isMobileConnected Then ' need wifi and/or data connection
''		internetAvailable = wifiConnected.isOnlinePing3(5000)	' ping web Google dns (timeout 5 seconds).
''	End If
'
'' Need to add code something like this (problem with resummable sub) 
'	Dim internetAvailable As Boolean = False
'	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
''	job.Download("https://www.superord.co.uk/api/centre")
''	job.Download( modEposWeb.URL_CENTRE_API)
'	job.Download( Starter.server.URL_CENTRE_API)
'	job.GetRequest.Timeout = 5000
'	Wait For (job) JobDone(job As HttpJob)
'	If job.Success And job.Response.StatusCode = 200 Then
'		internetAvailable = True
'	End If
'	job.release
'	Return internetAvailable
'End Sub
'#else 'B4I
'' Checks if interent is available and our Server is on-line.
'Public Sub IsInternetAvailable As ResumableSub
'	Dim internetOk As Boolean = False
'	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
''	job.Download("https://www.superord.co.uk/api/centre")
''	job.Download( modEposWeb.URL_CENTRE_API)
'	job.Download( Starter.server.URL_CENTRE_API)
'	Wait For (job) JobDone(job As HttpJob)
'	If job.Success And job.Response.StatusCode = 200 Then
'		internetOk = True
'	End If
'	job.Release		' Important: Release.
'	Return internetOk
'End Sub
'#end if

Public Sub IsInternateAvailbleSync As Boolean
	Dim internetAvailable As Boolean = False
	
'	checkingForInternet = True
'	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
'	job.Download("https://www.superord.co.uk/api/centre")
'	'job.GetRequest.Timeout = 4000
'	Wait For (job) JobDone(job As HttpJob)
'	If job.Success And job.Response.StatusCode = 200 Then
'		internetAvailable = True
'	End If
'	
'	job.release
	
	Return internetAvailable 
End Sub

' Check if Server is available by WiFi 
public Sub IsServerAvailableOnWifi As Boolean
	Dim serverOnWifi As Boolean = False
#if B4A
	If IsWifiOn Then
		Dim wifiLocal As MLwifi
		If wifiLocal.isOnlinePing2(Starter.ServerIP) Then
			'
			' TODO - Need a check by attempting to connect to the Server on the correct port
			'			(also could send a EPOS_PING to be sure.
			'
			serverOnWifi = True
		End If
	End If
#else ' B4I

	
#End If

	Return serverOnWifi
End Sub

' Returns whether the WiFi is currently switched-on on the device.
Public Sub IsWifiOn As Boolean
#if B4A
	Dim wifiLocal As MLwifi
	Return wifiLocal.isWifiEnabled
#else ' B4I
	' Taken from https://www.b4x.com/android/forum/threads/get-more-wifi-information.102693/
	Dim no As NativeObject = Me
	Dim wiFiEnabled As Boolean = no.RunMethod("isWiFiEnabled", Null).AsBoolean
	Return wiFiEnabled
#end if
End Sub

' Returns whether the WiFi is currently switched-on and above the strength threshold configured in the settings.
' Otherwise, will return false (including if a reconnection is in progress).
Public Sub IsWifiQuickCheckOk As Boolean
#if B4A
	Dim wifiConnected As MLwifi
	Dim wifiQuickCheckOk As Boolean = False

	If reconnectInProgress = False Then	' Return false if reconnection is in progress
		If wifiConnected.isWifiConnected Then
			If IsWifiSignalOk Then
				wifiQuickCheckOk = True
			End If
		End If
	End If
	Return wifiQuickCheckOk
#else ' B4I
	Return True ' Hack for B4I.
#end if
End Sub

' Pings an IP address 
' Returns duration msecs (upto timeout of 5 seconds).
' Problem isOnlinePing4() currently don't appear to detect devices on the LAN so do not use it to detect the Centre Server. 
Public Sub PingAddress(ipAddress As String) As Int
#if B4A
	Dim wifiConnected As MLwifi
	Dim first As Long
	Dim endTime As Long

	first = DateTime.now
	wifiConnected.isOnlinePing4(ipAddress, 5000) ' Allow a maximum of 5seconds.
	endTime = DateTime.Now
	Dim diff As Long
	diff = endTime - first
	Return diff
#else ' B4I
	Return 0	' HAck for B4I.
#end if
End Sub

' Handles a successful reconnection.
Public Sub ReconnectSuccess
	reconnectInProgress = False
	tmrReconnectTimeOut.Enabled = False
	connectionStatus = modEposApp.CONNECTION_OK
	autoReconnect = True ' Re-enable auto reconnect operation
End Sub

' Invokes a reconnection attempt.
Public Sub ReconnectToServer	
#if B4A
	Starter.reconnectEnabled = True
	connectionStatus = modEposApp.CONNECTION_RECON
	CallSub(Starter, "ConnectToServer")
	reconnectInProgress = True ' Start reconnection timer
	tmrReconnectTimeOut.Enabled = True
#else ' B4I
	'TODO Check if B4I code required.
#end if
End Sub

' Restarts the server check interval timer.
Public Sub RetriggerServerCheck
	tmrServerCheckTimer.Enabled = False
	tmrServerCheckTimer.Enabled = True
	connectionStatus = modEposApp.CONNECTION_OK
End Sub

' Handles a successful server check.
Public Sub ServerCheckSuccess
	tmrServerCheckTimeout.Enabled = False
	connectionStatus = modEposApp.CONNECTION_OK
End Sub

' Starts the timer which controls the periodic server pings.
Public Sub StartServerChecking
	tmrServerCheckTimer.Enabled = True
End Sub

' Stops all timers which control the periodic server pings, reconnection, etc.
Public Sub StopServerChecking
	tmrServerCheckTimer.Enabled = False
	tmrServerCheckTimeout.Enabled = False
	tmrReconnectTimeOut.Enabled = False
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Returns whether the WiFi is currently above the strength threshold configured in the settings.
Private Sub IsWifiSignalOk() As Boolean
	Dim wifiStrength As Int = GetWifiSignalStrength
	Dim wifiStrengthOk As Boolean = False
	
	If wifiStrength > (Starter.settings.wifiLowThreshold + Starter.settings.wifiHysteresis) Then
		wifiStrengthOk = True
	Else If wifiStrength < Starter.settings.wifiLowThreshold Then
		wifiStrengthOk = False
	Else If prevWifiStrengthOk Then ' Level is in hysteresis zone
		wifiStrengthOk = True
	End If
	prevWifiStrengthOk = wifiStrengthOk
	Return wifiStrengthOk
End Sub

#End Region  Local Subroutines
