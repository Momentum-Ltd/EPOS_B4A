B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=7.8
@EndOfDesignText@
'
' This service monitors the socket connections
'
#Region  Documentation
	'
	' Name......: TestConnection (Obsolete)
	' Release...: 3
	' Date......: 05/07/19   
	'
	' History
	' Date......: 10/02/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 06/04/18
	' Release...: 2
	' Amendee...: D Morris
	' Details...: Added: wifi global.
		'
	' Date......: 05/07/19
	' Release...: 3
	' Overview..: Obsolete (now use clsConnect - used by Starter service).
	' Amendee...: D Morris
	' Details...: Mod: Made obsolete
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region ' Documentation

#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public wifi As MLwifi
	
	Public hubPingOk As Boolean
	
	Private tmrTestWifi As Timer
End Sub

Sub Service_Create
	tmrTestWifi.Initialize("tmrTestWifi", 10000)
End Sub

Sub Service_Start (StartingIntent As Intent)
	
End Sub

Sub Service_Destroy

End Sub
#End Region

#Region  Event Handlers
public Sub isOnLine_PingDone(isOnline As Boolean)
	If isOnline Then
		hubPingOk = True
	Else
		hubPingOk = False
	End If
End Sub
#end Region

#Region  Public Subroutines

public Sub pCheckIfConnected() As Boolean
	Dim connectedOk As Boolean = False
	Dim wifi As MLwifi
	
'	If wifi.isWifiConnected And Starter.IsConnected Then
	If wifi.isWifiConnected Then
		connectedOk = True
	End If
	Return connectedOk
End Sub

public Sub pGetWifiSignalStrength() As Int
	Dim wifiStrength As MLwifi
	Return wifiStrength.WifiSignalPct
End Sub

public Sub pCheckIfHubConnection(ipAddress As String) As Boolean
	Dim hubConnectionOk As Boolean = False
	
	If wifi.isOnlinePing6(ipAddress, 1000) Then
		hubConnectionOk = True
	End If
	Return hubConnectionOk 
End Sub
#end Region

#Region  Local Subroutines

#end Region

